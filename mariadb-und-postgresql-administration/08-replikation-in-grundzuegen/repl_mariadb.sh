#!/usr/bin/env bash
# MariaDB: Replikation Primär -> Replikat mit GTID (zwei Instanzen auf einem Rechner; erfundene Daten und Kennwörter).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up pri 3311 1 || exit 1; maria_up rep 3312 2 || exit 1
step "1. Primär: Benutzer für die Replikation, Testdaten"
maria pri <<'SQL'
create user 'repl'@'127.0.0.1' identified by 'Test-Repl-12345';
grant replication slave on *.* to 'repl'@'127.0.0.1';
create database shop; use shop;
create table kunde (id int primary key, name varchar(40));
insert into kunde values (1,'Muster GmbH'),(2,'Test AG');
SQL
maria pri -t -e "show variables where Variable_name in ('server_id','log_bin','binlog_format','gtid_strict_mode')"
step "2. Replikat: auf den Primär zeigen lassen und starten (gtid_slave_pos, MariaDB-GTID)"
maria rep -e "change master to master_host='127.0.0.1', master_port=3311, master_user='repl', master_password='Test-Repl-12345', master_use_gtid=slave_pos; start slave"
sleep 2
maria rep -e "show slave status\\G" | grep -E 'Slave_IO_Running|Slave_SQL_Running:|Using_Gtid|Seconds_Behind_Master|Last_.*Error:' | sed 's/^ *//'
step "3. Änderung auf dem Primär, Kontrolle auf dem Replikat"
maria pri -e "insert into shop.kunde values (3,'Beispiel KG')"
sleep 1
maria rep -t -e "select * from shop.kunde"
echo "-- Schreiben auf dem Replikat ist möglich, aber nicht erwünscht: read_only schützt davor (nicht für Benutzer mit SUPER/READ_ONLY ADMIN)"
maria rep -e "set global read_only = 1"; maria rep -N -e "select @@read_only"
step "4. GTID-Position vergleichen"
echo "Primär  gtid_binlog_pos: $(maria pri -N -e 'select @@gtid_binlog_pos')"
echo "Replikat gtid_slave_pos:  $(maria rep -N -e 'select @@gtid_slave_pos')"
step "5. Fehlerbild: Replikat stoppen, Primär schreibt weiter, Verzögerung entsteht, Replikat holt auf"
maria rep -e "stop slave"
maria pri -e "insert into shop.kunde values (4,'Neu AG'),(5,'Spät KG')"
echo "Replikat ohne laufende Replikation: $(maria rep -N -e 'select count(*) from shop.kunde') Zeilen; Primär: $(maria pri -N -e 'select count(*) from shop.kunde') Zeilen"
maria rep -e "start slave"; sleep 2
echo "Replikat nach start slave: $(maria rep -N -e 'select count(*) from shop.kunde') Zeilen"
lab_down
