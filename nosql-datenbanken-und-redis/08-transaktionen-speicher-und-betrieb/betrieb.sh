#!/usr/bin/env bash
# Modul 8: Transaktionen, Pub/Sub, Speichergrenze mit Verdrängung, Überwachung und Abschlussprojekt (Sitzungsspeicher). Erfundene Daten.
. "$(dirname "$0")/../lab.sh"
lab_up; start $P1
step "1. Transaktion mit MULTI/EXEC: alle Befehle werden gemeinsam ausgeführt"
redis-cli -p $P1 set konto:a 100 >/dev/null; redis-cli -p $P1 set konto:b 0 >/dev/null
printf 'MULTI\nDECRBY konto:a 30\nINCRBY konto:b 30\nEXEC\n' | redis-cli -p $P1 --no-raw | tr -d '\r'
echo "konto:a=$(rr get konto:a) konto:b=$(rr get konto:b)"
step "2. Fehler in der Transaktion: unbekannter Befehl verwirft alles (beim Einreihen erkannt)"
printf 'MULTI\nINCR konto:a\nFALSCHER_BEFEHL\nEXEC\n' | redis-cli -p $P1 --no-raw 2>&1 | tr -d '\r'; echo "konto:a=$(rr get konto:a)"
step "3. Pub/Sub: eine Nachricht an einen wartenden Abonnenten"
( redis-cli -p $P1 subscribe kanal1 > "$W/abo.txt" 2>&1 & echo $! > "$W/abo.pid" ); sleep 0.5
echo "Empfänger erreicht: $(rr publish kanal1 'Beispiel-Nachricht')"; sleep 0.3; kill $(cat "$W/abo.pid") 2>/dev/null
grep -v '^$' "$W/abo.txt" | tr '\n' ' '; echo
step "4. Speichergrenze mit Verdrängung (maxmemory 2mb, allkeys-lru): ältere Schlüssel werden entfernt"
rr config set maxmemory 2mb >/dev/null; rr config set maxmemory-policy allkeys-lru >/dev/null
for i in $(seq 1 50); do redis-cli -p $P1 set "gross:$i" "$(head -c 60000 /dev/zero | tr '\0' x)" >/dev/null; done
n=$(rr dbsize); echo "Geschriebene Schlüssel: 50, vorhanden: $([ $n -lt 50 ] && echo 'weniger als 50' || echo 50); verdrängt laut INFO: $(rr info stats | tr -d '\r' | awk -F: '/^evicted_keys/ {print ($2>0?"ja":"nein")}')"
step "5. Ohne Verdrängung (noeviction) werden Schreibvorgänge abgelehnt"
rr config set maxmemory-policy noeviction >/dev/null; echo "OOM-Fehler bei weiterem Schreiben: $(redis-cli -p $P1 set gross:neu "$(head -c 60000 /dev/zero | tr '\0' x)" 2>&1 | grep -c '^OOM')"
step "6. Überwachung: Speicher und langsame Befehle"
rr info memory | tr -d '\r' | grep -E '^(maxmemory_human|maxmemory_policy):'
rr config set slowlog-log-slower-than 0 >/dev/null; rr slowlog reset >/dev/null; rr ping >/dev/null; echo "Einträge im Slowlog (Schwelle 0 µs): $(rr slowlog len | awk '{print ($1>0?"mindestens 1":"0")}')"
step "7. Abschlussprojekt (Aufgabenliste)"
cat <<'T'
1 Sitzungsspeicher entwerfen: Schlüsselnamen, Hash je Sitzung, Ablauf (Modul 3)
2 Persistenz wählen und begründen (Modul 4)
3 Replikat und Übernahme von Hand testen (Modul 5)
4 Zugriff mit Kennwort und ACL-Benutzern absichern (Modul 6)
5 Speichergrenze und Verdrängung festlegen
6 Bericht: was getestet, was nicht (zum Beispiel TLS, Sentinel, Cluster)
T
