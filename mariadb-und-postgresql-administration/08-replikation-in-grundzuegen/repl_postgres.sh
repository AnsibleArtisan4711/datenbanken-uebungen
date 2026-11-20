#!/usr/bin/env bash
# PostgreSQL: Streaming-Replikation Primär -> Standby mit pg_basebackup und Replikationsslot (zwei Instanzen auf einem Rechner; erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; pg_up pri 5441 || exit 1
PGB=/usr/lib/postgresql/16/bin
step "1. Primär: Replikationsrolle, Testdaten (wal_level ist in PostgreSQL 16 standardmäßig replica)"
pg 5441 -c "show wal_level" -c "show max_wal_senders"
pg 5441 -q -c "create role repl with replication login password 'Test-Repl-12345'" -c "create database shop"
pg 5441 -d shop -q -c "create table kunde (id int primary key, name text); insert into kunde values (1,'Muster GmbH'),(2,'Test AG')"
step "2. Standby: Basissicherung mit -R (schreibt primary_conninfo und standby.signal) und Replikationsslot"
mkdir -p $W/stby; chown postgres:postgres $W/stby; chmod 700 $W/stby
su postgres -c "PGPASSWORD=Test-Repl-12345 pg_basebackup -h 127.0.0.1 -p 5441 -U repl -D $W/stby/data -R -X stream -C -S slot_stby" 2>&1
echo "Dateien: standby.signal vorhanden: $([ -f $W/stby/data/standby.signal ] && echo ja)"
grep -E '^primary_slot_name' $W/stby/data/postgresql.auto.conf
su postgres -c "$PGB/pg_ctl -D $W/stby/data -o '-p 5442 -c config_file=/etc/postgresql/16/pri/postgresql.conf -c data_directory=$W/stby/data -c unix_socket_directories=/tmp -c hba_file=/etc/postgresql/16/pri/pg_hba.conf -c ident_file=/etc/postgresql/16/pri/pg_ident.conf -c external_pid_file=$W/stby/pid' -l $W/stby/log -w start" >/dev/null 2>&1
step "3. Zustand prüfen: Primär sieht den Standby, Standby ist im Wiederherstellungsmodus"
pg 5441 -c "select state, sync_state, client_addr from pg_stat_replication" -c "select slot_name, active from pg_replication_slots"
SB() { su postgres -c "psql -X -h /tmp -p 5442 -d shop $(printf '%q ' "$@")"; }
SB -c "select pg_is_in_recovery() as standby"
step "4. Änderung auf dem Primär, Kontrolle auf dem Standby; Schreiben auf dem Standby ist verboten"
pg 5441 -d shop -q -c "insert into kunde values (3,'Beispiel KG')"; sleep 1
SB -c "select * from kunde order by id"
SB -c "insert into kunde values (9,'verboten')" 2>&1
step "5. Verzögerung messen (Byte-Abstand und Zeit)"
pg 5441 -c "select pg_wal_lsn_diff(sent_lsn, replay_lsn) as rueckstand_bytes from pg_stat_replication"
su postgres -c "$PGB/pg_ctl -D $W/stby/data stop -m fast" >/dev/null 2>&1
lab_down
