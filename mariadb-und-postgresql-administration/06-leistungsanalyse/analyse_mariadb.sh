#!/usr/bin/env bash
# MariaDB: langsame Abfragen finden, EXPLAIN lesen, Index anlegen (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 --slow-query-log=1 --long-query-time=0.01 --slow-query-log-file=$W/demo/slow.log || exit 1
step "1. Tabelle mit 200000 Zeilen"
maria demo <<'SQL'
create database shop; use shop;
create table bestellung (id int primary key auto_increment, kunde_id int, betrag decimal(8,2), status varchar(10)) engine=InnoDB;
insert into bestellung (kunde_id, betrag, status) select seq % 5000, (seq % 997) / 10, if(seq % 10 = 0, 'offen', 'fertig') from seq_1_to_200000;
analyze table bestellung;
SQL
Q="select count(*), sum(betrag) from shop.bestellung where kunde_id = 4242"
step "2. EXPLAIN ohne Index: vollständiger Tabellenscan (type=ALL)"
maria demo -t -e "explain $Q" | sed 's/ *$//'
step "3. Die Abfrage ausführen, Dauer messen und im Slow-Query-Log finden"
maria demo -e "set profiling=1; $Q; show profiles" | tail -2 | sed 's/\t/  /g'
echo "-- Auszug aus dem Slow-Query-Log (Zeitwerte variieren):"
awk '/^# Query_time/{t=$3} /where kunde_id = 4242/{print "Query_time: " t " s  " $0; exit}' $W/demo/slow.log
step "4. Index anlegen und erneut mit EXPLAIN prüfen (type=ref, wenige Zeilen)"
maria demo -e "create index idx_kunde on shop.bestellung (kunde_id)"
maria demo -t -e "explain $Q" | sed 's/ *$//'
step "5. Gelesene Zeilen vergleichen (Handler_read_*, vorher/nachher je Abfrage)"
maria demo -N -e "flush status; $Q; show session status like 'Handler_read_next'" | tail -1
lab_down
