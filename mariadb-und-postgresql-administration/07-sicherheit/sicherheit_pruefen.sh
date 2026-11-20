#!/usr/bin/env bash
# Kleine Sicherheitsprüfung gegen zwei Test-Instanzen mit absichtlichen Schwächen (erfundene Konten). Gibt je Prüfung OK oder WARNUNG aus.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1; pg_up demo 5441 || exit 1
ok()   { printf '  OK       %s\n' "$1"; }
warn() { printf '  WARNUNG  %s\n' "$1"; }
M() { maria demo -N -e "$1"; }
P() { pg 5441 -At -c "$1"; }
maria demo -e "create user 'alt'@'%' identified by 'Test-Alt-1'; create user ''@'localhost'; create user 'leer'@'localhost'; create database test_alt;"
pg 5441 -q -c "create role alt login superuser password 'Test-Alt-1'" -c "create role leer login"
step "MariaDB"
[ "$(M "select count(*) from mysql.user where user=''")" = 0 ] && ok "keine anonymen Konten" || warn "anonyme Konten vorhanden: $(M "select count(*) from mysql.user where user=''")"
[ "$(M "select count(*) from mysql.user where host='%'")" = 0 ] && ok "keine Konten mit Host %" || warn "Konten mit Host %: $(M "select group_concat(user) from mysql.user where host='%'")"
[ "$(M "select count(*) from information_schema.schemata where schema_name like 'test%'")" = 0 ] && ok "keine Testdatenbank" || warn "Testdatenbank vorhanden: $(M "select group_concat(schema_name) from information_schema.schemata where schema_name like 'test%'")"
[ "$(M "select @@have_ssl")" = YES ] && ok "TLS verfügbar" || warn "TLS nicht verfügbar (have_ssl=$(M 'select @@have_ssl'))"
[ "$(M "select @@bind_address")" = 127.0.0.1 ] && ok "lauscht nur auf 127.0.0.1" || warn "bind_address=$(M 'select @@bind_address')"
[ "$(M "select @@local_infile")" = 0 ] && ok "local_infile aus" || warn "local_infile an"
step "PostgreSQL"
[ "$(P "select count(*) from pg_roles where rolsuper and rolname not in ('postgres')")" = 0 ] && ok "keine zusätzlichen Superuser" || warn "zusätzliche Superuser: $(P "select string_agg(rolname, ',') from pg_roles where rolsuper and rolname <> 'postgres'")"
[ "$(P "select count(*) from pg_authid where rolcanlogin and rolpassword is null and rolname <> 'postgres'")" = 0 ] && ok "alle Login-Rollen haben ein Kennwort" || warn "Login-Rollen ohne Kennwort: $(P "select string_agg(rolname, ',') from pg_authid where rolcanlogin and rolpassword is null and rolname <> 'postgres'")"
[ "$(P "show password_encryption")" = scram-sha-256 ] && ok "Kennwörter mit scram-sha-256 gespeichert" || warn "password_encryption=$(P 'show password_encryption')"
[ "$(P "show ssl")" = on ] && ok "ssl=on" || warn "ssl=$(P 'show ssl') (Verbindungen nicht verschlüsselt)"
[ "$(P "select count(*) from pg_hba_file_rules where auth_method='trust' and type like 'host%'")" = 0 ] && ok "keine trust-Regeln für Netzwerkverbindungen" || warn "trust-Regeln für Netzwerk vorhanden"
[ "$(P "show listen_addresses")" = localhost ] && ok "lauscht nur auf localhost" || warn "listen_addresses=$(P 'show listen_addresses')"
lab_down
