#!/usr/bin/env bash
# Modul 1: NoSQL-Überblick und erster Redis-Server (Loopback, Port 6399). Erfundene Daten.
. "$(dirname "$0")/../lab.sh"
lab_up; start $P1
step "1. Version und Erreichbarkeit"
echo "Version: $(redis-server --version | sed -E 's/.*v=([0-9.]+).*/\1/')"
cmd redis-cli -p $P1 ping
rr info server | grep -E '^(redis_mode|tcp_port):' | tr -d '\r'
step "2. Schlüssel setzen und lesen (Schlüssel-Wert-Modell)"
r set kunde:1:name "Anna Beispiel"; r get kunde:1:name; r set kunde:2:name "Ben Beispiel"
step "3. Schlüsselnamen mit Doppelpunkt als Konvention; Suche mit SCAN statt KEYS im Betrieb"
echo "> --scan --pattern kunde:*"; rr --scan --pattern "kunde:*" | sort
echo "Anzahl Schlüssel: $(rr dbsize)"
step "4. Schlüssel löschen und prüfen"
r del kunde:2:name; r exists kunde:2:name; r exists kunde:1:name
step "5. Gegenüberstellung (Text, aus Fachwissen)"
cat <<'T'
Relational  : Tabellen, feste Spalten, SQL, Verknüpfungen
Schlüssel-Wert: Wert zu einem Schlüssel, sehr schnell, wenig Abfragemöglichkeiten (Redis)
Dokument    : verschachtelte Dokumente, flexible Felder (zum Beispiel MongoDB, Modul 7)
T
