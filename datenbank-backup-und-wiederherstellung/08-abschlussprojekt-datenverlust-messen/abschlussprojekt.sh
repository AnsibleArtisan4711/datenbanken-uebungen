#!/usr/bin/env bash
# Modul 8: Abschlussprojekt: RPO und RTO an PostgreSQL messen. Sicherung, Änderungen, Datenbank gelöscht, Wiederherstellung.
. "$(dirname "$0")/../lab.sh"
lab_up; pg_up s1 5481 >/dev/null; pg_daten 5481 500
Z="$W/proj"; mkdir -p "$Z"; chmod 777 "$Z"
step "1. Ausgangslage"
pg 5481 -d shop -Atc "select 'kunden='||count(*) from kunden; select 'bestellungen='||count(*) from bestellungen;"
step "2. Vollsicherung (Format custom)"
su postgres -c "pg_dump -p 5481 -Fc shop -f $Z/shop.dump"; [ -s "$Z/shop.dump" ] && echo "Sicherungsdatei vorhanden und nicht leer"
step "3. Nach der Sicherung kommen 40 neue Bestellungen dazu"
pg 5481 -d shop -Atc "insert into bestellungen(kunde_id,betrag) select 1, 10 from generate_series(1,40); select 'bestellungen='||count(*) from bestellungen;"
step "4. Unfall: Datenbank wird gelöscht"
pg 5481 -c "drop database shop" ; pg 5481 -Atc "select count(*) from pg_database where datname='shop'" | sed 's/^/Datenbank shop vorhanden (0=nein): /'
step "5. Wiederherstellung und Zeitmessung"
T0=$(date +%s.%N)
pg 5481 -c "create database shop" >/dev/null
su postgres -c "pg_restore -p 5481 -d shop $Z/shop.dump"
T1=$(date +%s.%N)
NACH=$(pg 5481 -d shop -Atc "select count(*) from bestellungen"); pg 5481 -d shop -Atc "select 'kunden='||count(*) from kunden; select 'bestellungen='||count(*) from bestellungen;"
step "6. Ergebnis: RPO und RTO"
python3 - "$T0" "$T1" "$NACH" <<'P'
import sys
rto = float(sys.argv[2]) - float(sys.argv[1])
print(f"Bestellungen vor dem Unfall: 1540, nach der Wiederherstellung: {sys.argv[3]}, verloren: {1540-int(sys.argv[3])} (RPO-Folge)")
print(f"Gemessene Wiederherstellungsdauer (RTO) kleiner als 60 Sekunden: {'ja' if rto < 60 else 'nein'}")
print("Die genaue Sekundenzahl schwankt von Lauf zu Lauf und wird deshalb nicht festgehalten.")
P
step "7. Verbesserung (Text): Sicherung öfter oder fortlaufendes Archiv (siehe P31, PITR)"
