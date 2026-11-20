#!/usr/bin/env bash
# Nach einem Update: mariadb-upgrade ausführen und prüfen; Major-Wechsel bei PostgreSQL als Dump/Restore in einen zweiten Cluster (erfundene Daten).
# Im Container ist je Produkt nur eine Version installiert; ein echter Versionssprung wurde NICHT getestet.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1; pg_up alt 5441 || exit 1; pg_up neu 5442 || exit 1
step "1. MariaDB: Versionen und mariadb-upgrade (prüft und aktualisiert Systemtabellen)"
maria demo -N -e "select version()"
mariadb-upgrade --no-defaults -S $W/demo/s.sock -uroot 2>&1 | grep -E 'Phase|OK|already|upgrade' | head -12
echo "Upgrade-Info-Datei: $(cat $W/demo/data/mysql_upgrade_info)"
step "2. PostgreSQL: Cluster und installierte Programmversionen"
pg_lsclusters | grep -v main
ls /usr/lib/postgresql/
step "3. PostgreSQL: Daten von Cluster alt (Port 5441) nach Cluster neu (Port 5442) per Dump und Restore"
pg 5441 -q -c "create database shop"
pg 5441 -d shop -q -c "create table kunde (id int primary key, name text); insert into kunde values (1,'Muster GmbH'),(2,'Test AG')"
su postgres -c "pg_dumpall -p 5441 --globals-only" | su postgres -c "psql -X -q -p 5442 -d postgres" 2>&1 | grep -v -e 'already exists' -e set_config -e '^-*$' -e '^ *$' -e '(1 row)'
su postgres -c "pg_dump -p 5441 -C -d shop" | su postgres -c "psql -X -q -p 5442 -d postgres" >/dev/null
pg 5442 -d shop -c "select count(*) as kunden from kunde"
step "4. Nach dem Wechsel: ANALYZE ausführen (Planer-Statistiken werden bei Dump/Restore nicht mit übernommen)"
pg 5442 -d shop -c "select last_analyze is not null as analyze_gelaufen from pg_stat_user_tables where relname='kunde'"
pg 5442 -d shop -q -c "analyze"
pg 5442 -d shop -c "select last_analyze is not null as analyze_gelaufen from pg_stat_user_tables where relname='kunde'"
lab_down
