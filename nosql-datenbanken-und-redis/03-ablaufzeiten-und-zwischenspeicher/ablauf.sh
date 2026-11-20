#!/usr/bin/env bash
# Modul 3: Ablaufzeiten (TTL), Sitzungen und Zwischenspeicher mit Redis. Wartezeiten wenige Sekunden.
. "$(dirname "$0")/../lab.sh"
lab_up; start $P1
step "1. Schlüssel mit Ablauf setzen (SET ... EX) und TTL lesen"
r set sitzung:abc "benutzer=anna" ex 2; rr ttl sitzung:abc | awk '{print ($1>0 && $1<=2) ? "TTL liegt zwischen 1 und 2 Sekunden: ja" : "nein"}'
step "2. Ohne Ablauf: TTL = -1; nicht vorhanden: TTL = -2"
r set dauerhaft 1; r ttl dauerhaft; r ttl gibtesnicht
step "3. Ablauf nachträglich setzen und wieder aufheben (EXPIRE, PERSIST)"
r expire dauerhaft 100; rr ttl dauerhaft | awk '{print ($1>0 && $1<=100) ? "TTL liegt zwischen 1 und 100: ja" : "nein"}'; r persist dauerhaft; r ttl dauerhaft
step "4. Warten bis zum Ablauf der Sitzung (2,5 Sekunden)"
sleep 2.5; r get sitzung:abc; r exists sitzung:abc
step "5. Zwischenspeicher-Muster (Cache-Aside) im Bash-Modell"
holen() { w=$(rr get "cache:$1"); if [ -n "$w" ]; then echo "Treffer  $1 = $w"; else echo "Fehlt    $1: berechne neu (langsam) und speichere für 60 s"; rr set "cache:$1" "wert-$1" ex 60 >/dev/null; fi; }
holen preis; holen preis; holen lager
step "6. Ablauf bei Änderung: SET ohne EX löscht den Ablauf"
r set sitzung:x 1 ex 100; r set sitzung:x 2; r ttl sitzung:x
