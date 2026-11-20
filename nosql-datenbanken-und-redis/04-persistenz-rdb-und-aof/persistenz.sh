#!/usr/bin/env bash
# Modul 4: Persistenz: ohne Speicherung, mit RDB-Abbild und mit AOF-Protokoll; Neustart und Prüfung der Daten.
. "$(dirname "$0")/../lab.sh"
lab_up
step "1. Ohne Persistenz: nach dem Neustart sind die Daten weg"
start $P1; r set a 1 >/dev/null; echo "vor Neustart: $(rr dbsize) Schlüssel"; stop $P1; sleep 0.5; start $P1; echo "nach Neustart: $(rr dbsize) Schlüssel"
step "2. RDB: Abbild mit SAVE schreiben, Datei prüfen, Neustart"
r set b 2 >/dev/null; r save; ls "$W/$P1" | grep -c '^dump.rdb$' | sed 's/^/Dateien dump.rdb: /'
stop $P1; sleep 0.5; start $P1 ; echo "nach Neustart (Abbild wird geladen): $(rr dbsize) Schlüssel, b=$(rr get b)"
step "3. Änderungen nach dem letzten Abbild gehen bei hartem Ende verloren"
r set c 3 >/dev/null; kill -9 $(tail -1 "$W/pids"); sleep 0.5; start $P1; echo "c nach hartem Ende: '$(rr get c)' (leer = verloren), b=$(rr get b)"
stop $P1; sleep 0.3
step "4. AOF: jeder Schreibbefehl wird protokolliert (appendfsync always)"
rm -rf "$W/$P1"; start $P1 --appendonly yes --appendfsync always
r set x 1 >/dev/null; r set y 2 >/dev/null; r incr x >/dev/null
echo "AOF-Dateien vorhanden: $(ls "$W/$P1/appendonlydir" | wc -l)"; echo "Befehle im Protokoll (Zeilen mit SET oder INCR): $(cat "$W/$P1"/appendonlydir/*.incr.aof | tr -d '\r' | grep -ciE '^(set|incr)$')"
kill -9 $(tail -1 "$W/pids"); sleep 0.5; start $P1 --appendonly yes --appendfsync always
echo "nach hartem Ende: x=$(rr get x) y=$(rr get y)"
step "5. Vergleich (Text)"
cat <<'T'
RDB : kompakte Abbilder in Abständen, schnell zu laden, Änderungen seit dem letzten Abbild gehen verloren
AOF : Protokoll aller Schreibbefehle, kleinere Verlustspanne, größere Datei, langsamerer Neustart
Beides ersetzt keine Datensicherung auf ein anderes System.
T
