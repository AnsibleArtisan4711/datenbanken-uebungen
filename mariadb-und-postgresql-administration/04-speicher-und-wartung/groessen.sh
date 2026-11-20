#!/usr/bin/env bash
# Größenübersicht: Datenbanken, Tabellen und Indizes in beiden Systemen (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1; pg_up demo 5441 || exit 1
maria demo <<'SQL'
create database lager; use lager;
create table posten (id int primary key auto_increment, text varchar(100), menge int, index(menge)) engine=InnoDB;
insert into posten (text, menge) select repeat('x',80), seq from seq_1_to_20000;
create table klein (id int primary key, name varchar(20));
analyze table posten; analyze table klein;
SQL
pg 5441 -q -c "create database lager"
pg 5441 -d lager -q <<'SQL'
create table posten (id serial primary key, text varchar(100), menge int);
create index on posten (menge);
insert into posten (text, menge) select repeat('x',80), g from generate_series(1,20000) g;
create table klein (id int primary key, name varchar(20));
analyze;
SQL
step "MariaDB: Größe je Tabelle (Daten + Index) aus information_schema"
maria demo -t -e "select table_name as tabelle, round(data_length/1024) as daten_kb, round(index_length/1024) as index_kb from information_schema.tables where table_schema='lager' order by data_length+index_length desc"
step "PostgreSQL: Größe je Datenbank und je Tabelle"
pg 5441 -d lager -c "select datname, pg_size_pretty(pg_database_size(datname)) as groesse from pg_database where datname in ('lager','postgres') order by 1" \
  -c "select relname as tabelle, pg_size_pretty(pg_table_size(oid)) as tabelle_ohne_index, pg_size_pretty(pg_indexes_size(oid)) as indizes, pg_size_pretty(pg_total_relation_size(oid)) as gesamt from pg_class where relname in ('posten','klein') and relkind='r' order by pg_total_relation_size(oid) desc"
lab_down
