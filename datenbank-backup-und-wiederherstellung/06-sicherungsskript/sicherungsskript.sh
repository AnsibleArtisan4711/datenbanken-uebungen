#!/usr/bin/env bash
# Modul 6: Sicherungsskript mit Sperrdatei, Protokoll, Rückgabecodes und Fehlermeldung (Datei statt E-Mail). Im Container gegen PostgreSQL, MariaDB und SQLite ausgeführt.
. "$(dirname "$0")/../lab.sh"
lab_up; pg_up s1 5481 >/dev/null; pg_daten 5481 300; maria_up m1 3381 11 >/dev/null; maria_daten m1 300
S="$W/ziel"; mkdir -p "$S"; chown postgres "$S"; chmod 777 "$S"; sqlite3 "$W/app.db" "create table t(x); insert into t values (1),(2),(3);"
cat > "$W/sichern.sh" <<'SKRIPT'
#!/usr/bin/env bash
# Parameter: ZIELORDNER ; Rückgabecodes: 0 ok, 1 Fehler bei mindestens einer Sicherung, 2 läuft bereits
set -u; ZIEL=$1; LOG=$ZIEL/protokoll.txt; SPERRE=$ZIEL/sperre; FEHLER=0
exec 9>"$SPERRE"; flock -n 9 || { echo "läuft bereits" >&2; exit 2; }
log() { echo "$1" >> "$LOG"; }
sichere() {  # sichere NAME BEFEHL... (schreibt nach $ZIEL/NAME.tmp, benennt nur bei Erfolg um)
  local n=$1; shift
  if "$@" > "$ZIEL/$n.tmp" 2>/dev/null && [ -s "$ZIEL/$n.tmp" ]; then mv "$ZIEL/$n.tmp" "$ZIEL/$n.sicherung"; log "OK      $n"; else rm -f "$ZIEL/$n.tmp"; log "FEHLER  $n"; echo "Sicherung $n fehlgeschlagen" >> "$ZIEL/meldung.txt"; FEHLER=1; fi
}
sichere postgres-shop su postgres -c "pg_dump -p ${PGPORT:-5481} -Fc shop"
sichere maria-shop mariadb-dump --no-defaults -S "${MARIA_SOCK}" -uroot --single-transaction shop
sichere sqlite-app sqlite3 "${SQLITE_DB}" ".backup /dev/stdout"
( cd "$ZIEL" && sha256sum *.sicherung > pruefsummen.txt 2>/dev/null )
[ $FEHLER -eq 0 ] && log "GESAMT  ok" || log "GESAMT  Fehler"
exit $FEHLER
SKRIPT
chmod +x "$W/sichern.sh"; export MARIA_SOCK="$W/m1/s.sock" SQLITE_DB="$W/app.db"
step "1. Erster Lauf: alle drei Sicherungen"
"$W/sichern.sh" "$S"; echo "Rückgabecode: $?"; cat "$S/protokoll.txt"; ls "$S" | grep -c sicherung | sed 's/^/Sicherungsdateien: /'
step "2. Prüfsummen prüfen"
( cd "$S" && sha256sum -c pruefsummen.txt 2>&1 | sed 's/^/  /' )
step "3. Zweiter Lauf während der erste noch läuft: die Sperre verhindert den doppelten Start"
exec 8>"$S/sperre"; flock -n 8; "$W/sichern.sh" "$S"; echo "Rückgabecode: $?"; flock -u 8; exec 8>&-
step "4. Fehlerfall: MariaDB ist nicht erreichbar (Socket falsch)"
rm -f "$S/protokoll.txt"; MARIA_SOCK=/nirgends "$W/sichern.sh" "$S"; echo "Rückgabecode: $?"; cat "$S/protokoll.txt"; echo "Meldung:"; cat "$S/meldung.txt"
echo "Die fehlgeschlagene Sicherung hinterlässt keine unvollständige Datei: $(ls "$S" | grep -c 'tmp$') .tmp-Dateien"
echo "Die letzte gute Sicherung von maria-shop bleibt erhalten: $(ls "$S" | grep -c '^maria-shop.sicherung$')"
step "5. Einplanung (Text, nicht ausgeführt)"
cat <<'T'
# Beispielzeile für cron (täglich 02:30), Pfade erfunden:
30 2 * * * /opt/sicherung/sichern.sh /srv/sicherung >> /var/log/sicherung.log 2>&1
Zusätzlich: Meldung bei Rückgabecode ungleich 0 und regelmäßiger Wiederherstellungstest (Modul 4).
T
