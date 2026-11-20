#!/usr/bin/env bash
# Umschalten auf das Replikat (Promote) in beiden Systemen. Im Test fällt der Primär durch Beenden des Dienstes aus (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up pri 3311 1 || exit 1; maria_up rep 3312 2 || exit 1; pg_up pri 5441 || exit 1
PGB=/usr/lib/postgresql/16/bin
step "MariaDB 1. Replikation einrichten, Testdaten"
maria pri -e "create user 'repl'@'127.0.0.1' identified by 'Test-Repl-12345'; grant replication slave on *.* to 'repl'@'127.0.0.1'; create database shop; create table shop.kunde (id int primary key, name varchar(40)); insert into shop.kunde values (1,'Muster GmbH'),(2,'Test AG')"
maria rep -e "change master to master_host='127.0.0.1', master_port=3311, master_user='repl', master_password='Test-Repl-12345', master_use_gtid=slave_pos; start slave; set global read_only=1"
sleep 2; echo "Replikat hat $(maria rep -N -e 'select count(*) from shop.kunde') Zeilen"
step "MariaDB 2. Ausfall des Primärs, Replikat zum neuen Primär machen"
maria_down pri
maria rep -e "stop slave; reset slave all; set global read_only=0"
maria rep -e "insert into shop.kunde values (3,'Nach Umschaltung KG')"
echo "Neuer Primär hat $(maria rep -N -e 'select count(*) from shop.kunde') Zeilen und nimmt Schreibvorgänge an."
echo "Wichtig: Anwendungen müssen auf die neue Adresse umgestellt werden; der alte Primär darf nicht unkontrolliert wieder starten (zwei Primärserver = Split-Brain)."
step "PostgreSQL 1. Standby einrichten"
pg 5441 -q -c "create role repl with replication login password 'Test-Repl-12345'" -c "create database shop"
pg 5441 -d shop -q -c "create table kunde (id int primary key, name text); insert into kunde values (1,'Muster GmbH'),(2,'Test AG')"
mkdir -p $W/stby; chown postgres:postgres $W/stby; chmod 700 $W/stby
su postgres -c "PGPASSWORD=Test-Repl-12345 pg_basebackup -h 127.0.0.1 -p 5441 -U repl -D $W/stby/data -R -X stream" >/dev/null 2>&1
su postgres -c "$PGB/pg_ctl -D $W/stby/data -o '-p 5442 -c config_file=/etc/postgresql/16/pri/postgresql.conf -c data_directory=$W/stby/data -c unix_socket_directories=/tmp -c hba_file=/etc/postgresql/16/pri/pg_hba.conf -c ident_file=/etc/postgresql/16/pri/pg_ident.conf -c external_pid_file=$W/stby/pid' -l $W/stby/log -w start" >/dev/null 2>&1
SB() { su postgres -c "psql -X -h /tmp -p 5442 -d shop $(printf '%q ' "$@")"; }
sleep 1; echo "Standby im Wiederherstellungsmodus: $(SB -At -c 'select pg_is_in_recovery()')"
step "PostgreSQL 2. Ausfall des Primärs, Standby befördern (pg_promote)"
pg_ctlcluster 16 pri stop -m immediate
SB -c "select pg_promote(wait => true)"
SB -At -c "select 'im Wiederherstellungsmodus: ' || pg_is_in_recovery()"
SB -c "insert into kunde values (3,'Nach Umschaltung KG')"
SB -c "select count(*) as zeilen from kunde"
SB -q -c "checkpoint"
echo "Zeitleiste (timeline) des neuen Primärs: $(SB -At -c 'select timeline_id from pg_control_checkpoint()') (vor der Umschaltung: 1)"
su postgres -c "$PGB/pg_ctl -D $W/stby/data stop -m fast" >/dev/null 2>&1
lab_down
