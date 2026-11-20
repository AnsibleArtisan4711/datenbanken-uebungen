#!/usr/bin/env bash
# PostgreSQL: Wiederherstellung bis zu einem benannten Zeitpunkt (PITR) mit Basissicherung + WAL-Archiv (erfundene Daten).
# Die Einstellungen kommen in conf.d, damit postgresql.conf unverändert bleibt.
# Hinweis: ALTER SYSTEM würde in postgresql.auto.conf schreiben; hier wird bewusst conf.d verwendet.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; pg_up demo 5441 || exit 1
mkdir -p $W/arch $W/sich; chown postgres:postgres $W/arch $W/sich
step "1. WAL-Archivierung einschalten (benötigt Neustart) und Basissicherung ziehen"
cat > /etc/postgresql/16/demo/conf.d/archiv.conf <<CONF
archive_mode = on
archive_command = 'test ! -f $W/arch/%f && cp %p $W/arch/%f'
CONF
pg_ctlcluster 16 demo restart
pg 5441 -q -c "create database shop"
pg 5441 -d shop -q -c "create table bestellung (id int primary key, betrag numeric(8,2)); insert into bestellung values (1,10),(2,20)"
su postgres -c "pg_basebackup -p 5441 -D $W/sich/basis -Fp -X stream" 2>&1
echo "Basissicherung angelegt: $(ls $W/sich/basis | wc -l) Einträge, backup_label vorhanden: $([ -f $W/sich/basis/backup_label ] && echo ja)"
step "2. Weitere Änderungen, benannter Wiederherstellungspunkt, dann der Fehler"
pg 5441 -d shop -q -c "insert into bestellung values (3,30),(4,40)"
pg 5441 -d shop -c "select pg_create_restore_point('vor_fehler') is not null as punkt_gesetzt"
pg 5441 -d shop -q -c "drop table bestellung"
pg 5441 -q -c "select pg_switch_wal()" >/dev/null
sleep 2
echo "WAL-Dateien im Archiv: $(ls $W/arch | grep -vc history) (Anzahl variiert)"
step "3. Wiederherstellung: Cluster stoppen, Basissicherung als Datenverzeichnis, Wiederherstellungsziel setzen"
pg_ctlcluster 16 demo stop
rm -rf /var/lib/postgresql/16/demo; mkdir -m 700 /var/lib/postgresql/16/demo
cp -a $W/sich/basis/. /var/lib/postgresql/16/demo/
cat > /etc/postgresql/16/demo/conf.d/wiederherstellung.conf <<CONF
restore_command = 'cp $W/arch/%f %p'
recovery_target_name = 'vor_fehler'
recovery_target_action = 'promote'
CONF
touch /var/lib/postgresql/16/demo/recovery.signal
chown -R postgres:postgres /var/lib/postgresql/16/demo
pg_ctlcluster 16 demo start; for i in $(seq 1 60); do pg_isready -q -p 5441 && break; sleep 0.5; done
sleep 2
step "4. Ergebnis: Stand genau vor dem DROP TABLE"
pg 5441 -d shop -c "select * from bestellung order by id"
grep -E 'recovery stopping at restore point|redo done|archive recovery complete' /var/log/postgresql/postgresql-16-demo.log | sed -E 's/^[0-9-]+ [0-9:.]+ [A-Z]+ \[[0-9]+\] //; s/, time .*//; s/ system usage.*//' | head -4
rm -f /etc/postgresql/16/demo/conf.d/archiv.conf /etc/postgresql/16/demo/conf.d/wiederherstellung.conf
lab_down
