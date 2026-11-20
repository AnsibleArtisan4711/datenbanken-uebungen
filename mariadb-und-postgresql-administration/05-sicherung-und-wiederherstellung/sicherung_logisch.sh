#!/usr/bin/env bash
# Logische Sicherung und Wiederherstellung: mariadb-dump und pg_dump/pg_restore (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1; pg_up demo 5441 || exit 1
mkdir -p $W/sich; chmod 777 $W/sich
step "1. Testdaten anlegen"
maria demo <<'SQL'
create database shop; use shop;
create table kunde (id int primary key, name varchar(40));
insert into kunde values (1,'Muster GmbH'),(2,'Test AG'),(3,'Beispiel KG');
SQL
pg 5441 -q -c "create database shop"
pg 5441 -d shop -q <<'SQL'
create table kunde (id int primary key, name text);
insert into kunde values (1,'Muster GmbH'),(2,'Test AG'),(3,'Beispiel KG');
SQL
step "2. MariaDB: mariadb-dump mit --single-transaction (konsistent bei InnoDB, ohne Tabellen zu sperren)"
mariadb-dump --no-defaults -S $W/demo/s.sock -uroot --single-transaction --routines --databases shop > $W/sich/shop.sql
grep -vE '^(/\*|--|$)' $W/sich/shop.sql | grep -vE '^(LOCK|UNLOCK)' | head -12
echo "Zeilen in der Sicherungsdatei: $(wc -l < $W/sich/shop.sql)"
step "3. MariaDB: Datenbank löschen und wiederherstellen"
maria demo -e "drop database shop"
maria demo < $W/sich/shop.sql
maria demo -t -e "select count(*) as kunden from shop.kunde"
step "4. PostgreSQL: pg_dump im Custom-Format (-Fc), danach pg_restore"
su postgres -c "pg_dump -p 5441 -Fc -d shop -f $W/sich/shop.dump"
ls -l $W/sich/shop.dump | awk '{print "Größe der Sicherung: "$5" Bytes"}'
echo "-- Inhaltsverzeichnis der Sicherung (pg_restore -l, Auszug):"
su postgres -c "pg_restore -l $W/sich/shop.dump" | grep -E 'TABLE|TABLE DATA|DATABASE|PK'
pg 5441 -q -c "drop database shop"
pg 5441 -q -c "create database shop"
su postgres -c "pg_restore -p 5441 -d shop $W/sich/shop.dump"
pg 5441 -d shop -c "select count(*) as kunden from kunde"
step "5. Nur eine Tabelle zurückholen und Rollen/Globale Objekte sichern (pg_dumpall --globals-only)"
pg 5441 -d shop -q -c "drop table kunde"
su postgres -c "pg_restore -p 5441 -d shop -t kunde $W/sich/shop.dump"
pg 5441 -d shop -c "select count(*) as kunden from kunde"
su postgres -c "pg_dumpall -p 5441 --globals-only" | grep -E '^(CREATE|ALTER) ROLE' | sed -E "s/PASSWORD '[^']*'/PASSWORD '<Hash>'/" | head -3
lab_down
