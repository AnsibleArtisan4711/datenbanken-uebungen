#!/usr/bin/env bash
# PostgreSQL: Rollen, GRANT, Schema public und pg_hba.conf. Alle Namen und Kennwörter sind erfunden.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; pg_up demo 5441 || exit 1
PQ() { PGPASSWORD=$2 psql -X -h 127.0.0.1 -p 5441 -U $1 -d shop -c "$3" 2>&1; }
step "1. Datenbank, Schema, Tabelle und Rollen anlegen"
pg 5441 <<'SQL'
create database shop;
\c shop
create role auswertung nologin;
create role anwendung nologin;
create role anna login password 'Test-Anna-12345' in role auswertung;
create role app login password 'Test-App-12345' in role anwendung;
create schema fach;
create table fach.kunde (id int primary key, name text, ort text);
insert into fach.kunde values (1,'Muster GmbH','Beispielstadt'),(2,'Test AG','Musterdorf');
grant usage on schema fach to auswertung, anwendung;
grant select on all tables in schema fach to auswertung;
grant select, insert, update, delete on all tables in schema fach to anwendung;
SQL
step "2. Was dürfen die Rollen?"
echo "-- anna (Mitglied von auswertung): lesen"; PQ anna Test-Anna-12345 "select * from fach.kunde"
echo "-- anna: schreiben ist verboten";           PQ anna Test-Anna-12345 "insert into fach.kunde values (3,'X','Y')"
echo "-- app (Mitglied von anwendung): schreiben";  PQ app Test-App-12345 "insert into fach.kunde values (3,'Neu KG','Testhausen')"
echo "-- app: Tabelle löschen ist verboten";        PQ app Test-App-12345 "drop table fach.kunde"
step "3. Das Schema public: seit PostgreSQL 15 dürfen normale Benutzer dort nichts anlegen"
PQ anna Test-Anna-12345 "create table public.t (id int)"
step "4. Rechte anzeigen (\\dp und Rollenmitgliedschaft)"
pg 5441 -d shop -c "\dp fach.kunde" -c "\du anna" -c "\du app"
step "5. pg_hba.conf: wer darf sich von wo mit welcher Methode anmelden"
grep -vE '^\s*(#|$)' /etc/postgresql/16/demo/pg_hba.conf
step "6. Falsches Kennwort"
PGPASSWORD=falsch psql -X -h 127.0.0.1 -p 5441 -U anna -d shop -c "select 1" 2>&1
lab_down
