#!/usr/bin/env bash
# MariaDB: Wiederherstellung bis kurz vor einem Fehler (Point-in-Time) mit Sicherung + Binärprotokoll (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1
mkdir -p $W/sich; chmod 777 $W/sich
step "1. Daten anlegen und Vollsicherung mit Binärprotokoll-Position (--master-data=2)"
maria demo <<'SQL'
create database shop; use shop;
create table bestellung (id int primary key, betrag decimal(8,2));
insert into bestellung values (1, 10.00), (2, 20.00);
SQL
mariadb-dump --no-defaults -S $W/demo/s.sock -uroot --single-transaction --master-data=2 --databases shop > $W/sich/voll.sql
grep -m1 'CHANGE MASTER' $W/sich/voll.sql
step "2. Danach laufen weitere Änderungen, dann der Fehler (Tabelle versehentlich gelöscht)"
maria demo -e "insert into shop.bestellung values (3, 30.00), (4, 40.00)"
maria demo -e "drop table shop.bestellung"
maria demo -e "flush binary logs"
step "3. Im Binärprotokoll die Position des DROP TABLE suchen"
mariadb-binlog --no-defaults $W/demo/binlog.000001 2>/dev/null > $W/sich/binlog.txt
POS=$(awk '/^# at /{p=$3} /DROP TABLE/{print p; exit}' $W/sich/binlog.txt)
START=$(grep -m1 'CHANGE MASTER' $W/sich/voll.sql | sed -E 's/.*MASTER_LOG_POS=([0-9]+).*/\1/')
echo "Startposition der Sicherung: $START   Position des DROP TABLE: (gefunden: $([ -n "$POS" ] && echo ja))"
step "4. Wiederherstellung: Vollsicherung einspielen, dann das Protokoll von der Startposition bis vor den Fehler"
maria demo < $W/sich/voll.sql
echo "Nach der Vollsicherung:"; maria demo -t -e "select * from shop.bestellung"
mariadb-binlog --no-defaults --start-position=$START --stop-position=$POS $W/demo/binlog.000001 2>/dev/null | maria demo
echo "Nach dem Einspielen des Protokolls bis vor den Fehler:"; maria demo -t -e "select * from shop.bestellung"
lab_down
