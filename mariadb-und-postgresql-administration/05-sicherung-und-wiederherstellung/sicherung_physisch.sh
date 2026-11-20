#!/usr/bin/env bash
# Physische Sicherung: mariabackup und pg_basebackup (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1; pg_up demo 5441 || exit 1
mkdir -p $W/sich; chmod 777 $W/sich
maria demo <<'SQL'
create database shop; use shop;
create table kunde (id int primary key, name varchar(40));
insert into kunde values (1,'Muster GmbH'),(2,'Test AG'),(3,'Beispiel KG');
SQL
step "1. MariaDB: mariabackup --backup (kopiert die Dateien im laufenden Betrieb)"
mariabackup --no-defaults --backup --socket=$W/demo/s.sock --user=root --target-dir=$W/sich/mb 2>&1 | grep -E 'completed OK|\] ERROR|Error:' | sed -E 's/^\[[0-9]+\] [0-9-]+ [0-9:]+ /  /'
ls $W/sich/mb | head -12
step "2. mariabackup --prepare (Protokoll einspielen, Sicherung konsistent machen)"
mariabackup --no-defaults --prepare --target-dir=$W/sich/mb 2>&1 | grep -E 'completed OK|\] ERROR|Error:' | sed -E 's/^\[[0-9]+\] [0-9-]+ [0-9:]+ /  /'
step "3. Wiederherstellen: Dienst stoppen, Datenverzeichnis leeren, --copy-back, Besitzer setzen, starten"
maria demo -e "drop database shop"
maria_down demo
mv $W/demo/data $W/demo/data.alt; mkdir $W/demo/data
mariabackup --no-defaults --copy-back --datadir=$W/demo/data --target-dir=$W/sich/mb 2>&1 | grep -E 'completed OK|\] ERROR|Error:' | sed -E 's/^\[[0-9]+\] [0-9-]+ [0-9:]+ /  /'
chown -R mysql:mysql $W/demo/data
rm -f $W/demo/pid
su mysql -s /bin/bash -c "mariadbd --no-defaults --datadir=$W/demo/data --socket=$W/demo/s.sock --port=3311 --bind-address=127.0.0.1 --pid-file=$W/demo/pid --log-error=$W/demo/error.log --server-id=1 </dev/null >/dev/null 2>&1 &"
for i in $(seq 1 60); do maria demo -e 'select 1' >/dev/null 2>&1 && break; sleep 0.5; done
maria demo -t -e "select count(*) as kunden from shop.kunde"
step "4. PostgreSQL: pg_basebackup (gesamter Cluster, Format tar, komprimiert; -X fetch legt die nötigen WAL-Dateien mit in die Sicherung)"
pg 5441 -q -c "create database shop"; pg 5441 -d shop -q -c "create table kunde (id int primary key, name text); insert into kunde values (1,'Muster GmbH'),(2,'Test AG'),(3,'Beispiel KG')"
su postgres -c "pg_basebackup -p 5441 -D $W/sich/pgb -Ft -z -X fetch -P" 2>&1 | tail -1
ls $W/sich/pgb
echo "-- Inhalt von backup_label (Auszug):"; tar -xzOf $W/sich/pgb/base.tar.gz backup_label | head -3
step "5. PostgreSQL: Wiederherstellung = Cluster anhalten, Datenverzeichnis ersetzen, starten"
pg 5441 -q -c "drop database shop"
pg_ctlcluster 16 demo stop
mv /var/lib/postgresql/16/demo /var/lib/postgresql/16/demo.alt; mkdir -m 700 /var/lib/postgresql/16/demo; chown postgres:postgres /var/lib/postgresql/16/demo
tar -xzf $W/sich/pgb/base.tar.gz -C /var/lib/postgresql/16/demo
chown -R postgres:postgres /var/lib/postgresql/16/demo
pg_ctlcluster 16 demo start; for i in $(seq 1 40); do pg_isready -q -p 5441 && break; sleep 0.5; done
pg 5441 -d shop -c "select count(*) as kunden from kunde"
rm -rf /var/lib/postgresql/16/demo.alt
lab_down
