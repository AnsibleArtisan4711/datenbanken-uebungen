#!/usr/bin/env bash
# MariaDB/InnoDB: Dateien, Größen, Fragmentierung, ANALYZE und OPTIMIZE (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1
step "1. Testtabelle mit 60000 Zeilen anlegen, danach 80 % löschen"
maria demo <<'SQL'
create database lager;
use lager;
create table posten (id int primary key auto_increment, text varchar(200), menge int) engine=InnoDB;
insert into posten (text, menge) select repeat('x', 150), seq from seq_1_to_60000;
SQL
maria demo -e "analyze table lager.posten" >/dev/null
maria demo -t -e "select table_name, table_rows, round(data_length/1024/1024,1) as daten_mb, round(data_free/1024/1024,1) as frei_mb from information_schema.tables where table_schema='lager'"
maria demo -e "delete from lager.posten where id % 5 <> 0"
step "2. Nach dem Löschen: Zeilen weniger, Datei gleich groß (Platz bleibt reserviert)"
maria demo -t -e "analyze table lager.posten; select table_name, round(data_length/1024/1024,1) as daten_mb, round(data_free/1024/1024,1) as frei_mb from information_schema.tables where table_schema='lager'"
echo "Dateien im Datenverzeichnis (Auszug):"; ls -l $W/demo/data/lager | awk 'NR>1{print "  "$5" Bytes  "$9}'
step "3. OPTIMIZE TABLE baut die Tabelle neu auf (bei InnoDB: Neuaufbau mit ALTER)"
maria demo -t -e "optimize table lager.posten; select table_name, round(data_length/1024/1024,1) as daten_mb, round(data_free/1024/1024,1) as frei_mb from information_schema.tables where table_schema='lager'"
ls -l $W/demo/data/lager | awk 'NR>1{print "  "$5" Bytes  "$9}'
step "4. Tabelle prüfen (CHECK TABLE)"
maria demo -t -e "check table lager.posten"
lab_down
