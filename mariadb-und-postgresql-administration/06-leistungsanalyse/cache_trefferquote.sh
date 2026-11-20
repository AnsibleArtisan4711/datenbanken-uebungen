#!/usr/bin/env bash
# Cache-Trefferquote: wie oft kommen Daten aus dem Arbeitsspeicher statt von der Platte? (erfundene Daten)
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 --innodb-buffer-pool-size=8M || exit 1; pg_up demo 5441 || exit 1
maria demo <<'SQL'
create database shop; use shop;
create table bestellung (id int primary key auto_increment, text varchar(100)) engine=InnoDB;
insert into bestellung (text) select repeat('x', 90) from seq_1_to_150000;
SQL
pg 5441 -q -c "create database shop"
pg 5441 -d shop -q -c "create table bestellung (id serial primary key, text text); insert into bestellung (text) select repeat('x',90) from generate_series(1,150000)"
step "MariaDB: Pufferpool absichtlich klein (8 MB); die Zähler gelten seit dem Start, also inklusive des Befüllens der Tabelle"
maria demo -N -e "select count(*) from shop.bestellung; select count(*) from shop.bestellung" >/dev/null
maria demo -t -e "
select variable_name, variable_value from information_schema.global_status
 where variable_name in ('INNODB_BUFFER_POOL_READ_REQUESTS','INNODB_BUFFER_POOL_READS')"
maria demo -N -e "select concat('Trefferquote: ', round(100*(1 - (select variable_value from information_schema.global_status where variable_name='INNODB_BUFFER_POOL_READS') / (select variable_value from information_schema.global_status where variable_name='INNODB_BUFFER_POOL_READ_REQUESTS')),2), ' %')"
step "PostgreSQL: Trefferquote je Datenbank aus pg_stat_database"
pg 5441 -d shop -q -c "select count(*) from bestellung" >/dev/null
pg 5441 -d shop -c "select datname, blks_hit, blks_read, round(100.0*blks_hit/nullif(blks_hit+blks_read,0),2) as trefferquote_prozent from pg_stat_database where datname='shop'" | sed 's/ *$//'
echo "(Die Zahlen hängen von der Größe des Caches und vom Ablauf ab; Zielwerte hängen von der Anwendung ab, ein fester Grenzwert wird hier nicht behauptet.)"
lab_down
