#!/usr/bin/env bash
# Rechte-Bericht: sucht riskante Konten in beiden Systemen (Testdaten mit absichtlichen Schwächen, alles erfunden).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1; pg_up demo 5441 || exit 1
maria demo <<'SQL'
create user 'bericht'@'%' identified by 'Test-Bericht-1';
grant all privileges on *.* to 'bericht'@'%' with grant option;
create user 'ohnepw'@'localhost';
create user 'lesen'@'10.31.0.%' identified by 'Test-Lesen-1';
grant select on *.* to 'lesen'@'10.31.0.%';
SQL
pg 5441 -q <<'SQL'
create role bericht login superuser password 'Test-Bericht-1';
create role ohnepw login;
create role lesen login password 'Test-Lesen-1';
SQL
step "MariaDB: Konten mit Host-Platzhalter oder allen globalen Rechten"
maria demo -t -e "
select user, host,
  if(host='%' ,'Host %','') as host_hinweis,
  if(json_value(priv,'\$.access')=18446744073709551615 or json_value(priv,'\$.access')>=1073741823,'alle globalen Rechte','') as rechte
from mysql.global_priv where user not in ('mariadb.sys','root') order by user;" | sed 's/ *$//'
echo "-- Konten ohne Kennwort (laut mysql.user):"
maria demo -t -e "select user, host from mysql.user where user<>'' and coalesce(authentication_string,'')='' and plugin in ('mysql_native_password','') and user not in ('mariadb.sys','root','mysql')"
step "PostgreSQL: Rollen mit Superuser-Recht, ohne Kennwort und Mitgliedschaften"
pg 5441 -c "select r.rolname, r.rolsuper as superuser, r.rolcanlogin as login, (a.rolpassword is not null) as hat_kennwort from pg_roles r join pg_authid a using (oid) where r.rolname !~ '^pg_' order by 1"
lab_down
