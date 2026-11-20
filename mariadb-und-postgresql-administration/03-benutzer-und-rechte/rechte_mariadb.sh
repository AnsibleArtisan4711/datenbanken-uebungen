#!/usr/bin/env bash
# MariaDB: Benutzer (Name@Host), Rollen und Rechte; Prinzip der geringsten Rechte. Alle Namen und Kennwörter sind erfunden.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1
step "1. Datenbank, Tabelle und Beispieldaten anlegen"
maria demo <<'SQL'
create database shop;
create table shop.kunde (id int primary key, name varchar(40), ort varchar(40));
insert into shop.kunde values (1,'Muster GmbH','Beispielstadt'),(2,'Test AG','Musterdorf');
SQL
step "2. Rollen statt Einzelrechte: lesen und schreiben getrennt"
maria demo <<'SQL'
create role auswertung;
grant select on shop.* to auswertung;
create role anwendung;
grant select, insert, update, delete on shop.* to anwendung;
create user 'anna'@'127.0.0.1' identified by 'Test-Anna-12345';
create user 'app'@'127.0.0.1' identified by 'Test-App-12345';
grant auswertung to 'anna'@'127.0.0.1';
grant anwendung to 'app'@'127.0.0.1';
set default role auswertung for 'anna'@'127.0.0.1';
set default role anwendung for 'app'@'127.0.0.1';
SQL
step "3. Was dürfen die Benutzer? (Anmeldung über TCP als Benutzer)"
echo "-- anna (Rolle auswertung): lesen geht"
mariadb --no-defaults -h127.0.0.1 -P3311 -uanna -pTest-Anna-12345 -e "select * from shop.kunde"
echo "-- anna: schreiben ist verboten"
mariadb --no-defaults -h127.0.0.1 -P3311 -uanna -pTest-Anna-12345 -e "insert into shop.kunde values (3,'X','Y')" 2>&1 | grep ERROR
echo "-- app (Rolle anwendung): schreiben geht"
mariadb --no-defaults -h127.0.0.1 -P3311 -uapp -pTest-App-12345 -e "insert into shop.kunde values (3,'Neu KG','Testhausen'); select count(*) as anzahl from shop.kunde"
echo "-- app: Tabelle löschen ist verboten"
mariadb --no-defaults -h127.0.0.1 -P3311 -uapp -pTest-App-12345 -e "drop table shop.kunde" 2>&1 | grep ERROR
step "4. Rechte anzeigen"
maria demo -e "show grants for 'anna'@'127.0.0.1'; show grants for auswertung;" | sed "s/PASSWORD '[^']*'/PASSWORD '<Hash>'/"
echo "(Die Fehlermeldungen nennen den Host als 'localhost': der Server löst 127.0.0.1 in einen Namen auf. Das Konto 'anna'@'127.0.0.1' hat trotzdem gepasst.)"
step "5. Falscher Host / falsches Kennwort"
mariadb --no-defaults -h127.0.0.1 -P3311 -uanna -pfalsch -e "select 1" 2>&1 | sed "s/'[^']*'@'[^']*'/'anna'@'host'/"
lab_down
