#!/usr/bin/env bash
# PostgreSQL: MVCC, tote Zeilen, VACUUM, ANALYZE, Autovacuum (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; pg_up demo 5441 || exit 1
Q() { pg 5441 -d lager -c "$1"; }
pg 5441 -q -c "create database lager"
step "1. Tabelle mit 60000 Zeilen; Autovacuum für diese Tabelle abschalten, damit der Ablauf sichtbar bleibt"
pg 5441 -d lager -q <<'SQL'
create table posten (id serial primary key, text varchar(200), menge int) with (autovacuum_enabled = false);
insert into posten (text, menge) select repeat('x',150), g from generate_series(1,60000) g;
SQL
SZ="select pg_size_pretty(pg_relation_size('posten')) as tabellengroesse, n_live_tup as lebend, n_dead_tup as tot from pg_stat_user_tables where relname='posten'"
pg 5441 -d lager -q -c "analyze posten"; sleep 1
Q "$SZ"
step "2. 80 % der Zeilen löschen: Zeilen werden nur als tot markiert, die Datei bleibt gleich groß"
pg 5441 -d lager -q -c "delete from posten where id % 5 <> 0"; sleep 1
Q "$SZ"
step "3. VACUUM gibt den Platz innerhalb der Datei zur Wiederverwendung frei (Datei wird meist nicht kleiner)"
Q "vacuum (verbose off) posten"
sleep 1; Q "$SZ"
step "4. VACUUM FULL schreibt die Tabelle neu und verkleinert die Datei (sperrt die Tabelle exklusiv)"
Q "vacuum full posten"
sleep 1; Q "$SZ"
step "5. Autovacuum: Einstellungen"
pg 5441 -c "select name, setting from pg_settings where name in ('autovacuum','autovacuum_naptime','autovacuum_vacuum_scale_factor','autovacuum_vacuum_threshold') order by name"
lab_down
