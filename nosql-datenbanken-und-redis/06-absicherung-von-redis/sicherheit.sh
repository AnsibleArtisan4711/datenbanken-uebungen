#!/usr/bin/env bash
# Modul 6: Absicherung von Redis: Bindung an Loopback, Kennwort (requirepass), ACL-Benutzer mit Rechten. Nur erfundene Kennwörter.
. "$(dirname "$0")/../lab.sh"
lab_up; start $P1
step "1. Ohne Schutz: jeder, der den Port erreicht, darf alles (hier nur Loopback)"
echo "Bindung: $(rr config get bind | tr '\n' ' ')"; r set a 1; echo "requirepass: '$(rr config get requirepass | tail -1)' (leer = kein Kennwort)"
step "2. Kennwort setzen (requirepass): Zugriff ohne Anmeldung wird abgelehnt"
rr config set requirepass 'Beispiel-Pw-1' >/dev/null; r get a
echo "> auth (mit Kennwort)"; redis-cli -p $P1 -a 'Beispiel-Pw-1' --no-auth-warning get a
step "3. ACL-Benutzer mit eingeschränkten Rechten: nur Lesen auf Schlüssel mit Präfix kunde:"
export REDISCLI_AUTH='Beispiel-Pw-1'
redis-cli -p $P1 acl setuser leser on '>Beispiel-Pw-2' '~kunde:*' +get +hget +ping >/dev/null && echo "Benutzer leser angelegt"
redis-cli -p $P1 set kunde:1 anna >/dev/null; redis-cli -p $P1 set intern:1 geheim >/dev/null
unset REDISCLI_AUTH
L() { echo "> (als leser) $*"; redis-cli -p $P1 --user leser --pass 'Beispiel-Pw-2' --no-auth-warning --no-raw "$@" 2>&1; }
L ping; L get kunde:1; L get intern:1; L set kunde:2 x; L flushall
step "4. Rechte anzeigen (ohne Kennwort-Hashes)"
REDISCLI_AUTH='Beispiel-Pw-1' redis-cli -p $P1 acl getuser leser | tr -d '\r' | grep -A1 -E '^(flags|commands|keys)' | grep -v '^--'
step "5. Hinweise (Text)"
cat <<'T'
Redis nicht an öffentliche Adressen binden; Zugriff über Firewall begrenzen.
Kennwörter in der Konfiguration sind nur so sicher wie die Dateirechte der Konfigurationsdatei.
Gefährliche Befehle (FLUSHALL, CONFIG) nur für Verwaltungsbenutzer erlauben.
Kennwörter als Argument (`--pass`) sind in der Prozessliste sichtbar (siehe Übungsreihe Passwort- und Secrets-Verwaltung); hier nur erfundene Werte.
Verschlüsselung der Verbindung (TLS) wurde nicht ausgeführt.
T
