#!/usr/bin/env bash
# Modul 2: Logische Sicherung in der Praxis: Formate von pg_dump, Teilmengen, mariadb-dump-Optionen. Im Container ausgeführt (PostgreSQL 16, MariaDB 10.11).
. "$(dirname "$0")/../lab.sh"
lab_up; pg_up s1 5481 >/dev/null; pg_daten 5481 500; maria_up m1 3381 11 >/dev/null; maria_daten m1 500
D="$W/dump"; mkdir -p "$D"; chown postgres "$D"; chmod 777 "$D"
pgd() { su postgres -c "pg_dump -p 5481 $*"; }
step "1. pg_dump in vier Formaten (Datei, Custom, Verzeichnis mit 2 Prozessen, tar)"
pgd "-Fp shop -f $D/shop.sql"; pgd "-Fc shop -f $D/shop.dump"; pgd "-Fd -j 2 shop -f $D/shop.dir"; pgd "-Ft shop -f $D/shop.tar"
for f in shop.sql shop.dump shop.dir shop.tar; do printf '%-10s %s\n' "$f" "$([ -d $D/$f ] && echo Verzeichnis || file -b $D/$f | cut -c1-31)"; done
echo "Custom kleiner als Klartext: $([ $(stat -c %s $D/shop.dump) -lt $(stat -c %s $D/shop.sql) ] && echo ja || echo nein)"
step "2. Inhaltsverzeichnis einer Sicherung lesen (pg_restore -l): Anzahl Tabellen und Daten-Einträge"
su postgres -c "pg_restore -l $D/shop.dump" | grep -c ' TABLE DATA ' | sed 's/^/Einträge TABLE DATA: /'
su postgres -c "pg_restore -l $D/shop.dump" | grep ' TABLE DATA ' | awk "{print \"  Tabelle \" \$(NF-1) \", Eigentümer \" \$NF}" | sort
step "3. Nur Schema und nur Daten"
pgd "-Fp -s shop" | grep -c '^CREATE TABLE' | sed 's/^/CREATE TABLE im Schema-Dump: /'; pgd "-Fp -s shop" | grep -c '^COPY' | sed 's/^/COPY im Schema-Dump: /'
pgd "-Fp -a shop" | grep -c '^COPY' | sed 's/^/COPY im Daten-Dump: /'
step "4. Nur eine Tabelle zurückholen (pg_restore -t) in eine neue Datenbank"
pg 5481 -c 'create database teil' >/dev/null; pg 5481 -d teil -q -c 'create table kunden (id serial primary key, name text not null, ort text)' 
su postgres -c "pg_restore -p 5481 -d teil -t kunden --data-only $D/shop.dump"; pg 5481 -d teil -Atc 'select count(*) from kunden' | sed 's/^/Zeilen in teil.kunden: /'
step "5. MariaDB: mariadb-dump mit Optionen"
md() { mariadb-dump --no-defaults -S $W/m1/s.sock -uroot "$@"; }
md --single-transaction --routines --triggers shop > $D/maria.sql; grep -c '^CREATE TABLE' $D/maria.sql | sed 's/^/CREATE TABLE: /'; grep -c '^INSERT INTO' $D/maria.sql | sed 's/^/INSERT-Anweisungen: /'
md --no-data shop | grep -c '^INSERT INTO' | sed 's/^/INSERT bei --no-data: /'
md --single-transaction shop bestellungen --where='kunde_id<=10' | grep -o 'INSERT INTO `bestellungen` VALUES' | wc -l | sed 's/^/INSERT-Anweisungen mit Filter (kunde_id<=10): /'
step "6. Hinweise (Text)"
cat <<'T'
--single-transaction liefert nur bei transaktionalen Tabellen (InnoDB) einen konsistenten Stand ohne Sperren.
pg_dump liest in einer einzigen Transaktion; ein Dump ist ein Stand zum Beginn des Dumps.
Dumps enthalten keine Rollen: pg_dumpall --globals-only (siehe Übungsreihe MariaDB und PostgreSQL Administration).
T
