#!/usr/bin/env bash
# Modul 5: Sicherungen komprimieren, mit age verschlüsseln, Prüfsummen führen und nach Generationen aufbewahren. Erfundene Schlüssel; Dateien unter /tmp/p68.
. "$(dirname "$0")/../lab.sh"
lab_up; pg_up s1 5481 >/dev/null; pg_daten 5481 500
D="$W/dump"; mkdir -p "$D"; chown postgres "$D"; chmod 777 "$D"; export GNUPGHOME="$W/gnupg"
step "1. Dump erzeugen, komprimieren und Größen vergleichen"
su postgres -c "pg_dump -p 5481 -Fp shop -f $D/shop.sql"; gzip -k "$D/shop.sql"
echo "komprimiert kleiner als Klartext: $([ $(stat -c %s $D/shop.sql.gz) -lt $(stat -c %s $D/shop.sql) ] && echo ja || echo nein)"
step "2. Mit age verschlüsseln (Schlüsselpaar erzeugen, nur öffentlicher Schlüssel auf dem Sicherungsserver)"
age-keygen -o "$W/schluessel.txt" 2>/dev/null; chmod 600 "$W/schluessel.txt"; grep '^# public key' "$W/schluessel.txt" | awk '{print $4}' > "$W/oeffentlich.txt"
age -r "$(cat $W/oeffentlich.txt)" -o "$D/shop.sql.gz.age" "$D/shop.sql.gz"
echo "Klartext 'CREATE TABLE' in der verschlüsselten Datei: $(zcat -f "$D/shop.sql.gz.age" 2>/dev/null | grep -ac 'CREATE TABLE')"
step "3. Entschlüsseln, entpacken und die Prüfsumme gegen das Original vergleichen"
age -d -i "$W/schluessel.txt" "$D/shop.sql.gz.age" | gunzip | sha256sum | cut -c1-16 > "$W/a.txt"; sha256sum < "$D/shop.sql" | cut -c1-16 > "$W/b.txt"
echo "Prüfsumme gleich: $([ "$(cat $W/a.txt)" = "$(cat $W/b.txt)" ] && echo ja || echo nein)"
step "4. Falscher Schlüssel (anderes Schlüsselpaar) kann nicht entschlüsseln"
age-keygen -o "$W/fremd.txt" 2>/dev/null; age -d -i "$W/fremd.txt" "$D/shop.sql.gz.age" 2>&1 >/dev/null | head -1
step "5. Aufbewahrung nach Generationen (täglich 7, wöchentlich 4, monatlich 3), 120 Tagesdateien als Modell"
A="$W/archiv"; mkdir -p "$A"
for i in $(seq 0 119); do d=$(date -d "2026-11-20 - $i days" +%F); : > "$A/$d.sql.gz.age"; done
python3 - "$A" <<'PY'
import os, sys, datetime
dateien = sorted(os.listdir(sys.argv[1]), reverse=True); tage = [datetime.date.fromisoformat(f[:10]) for f in dateien]
heute = max(tage); behalten = set()
behalten.update(t for t in tage if (heute - t).days < 7)                                        # täglich 7
wochen = {}; [wochen.setdefault(t.isocalendar()[:2], t) for t in sorted(tage, reverse=True)]   # je Woche der jüngste Tag
behalten.update(sorted(wochen.values(), reverse=True)[:4])                                       # wöchentlich 4
monate = {}; [monate.setdefault((t.year, t.month), t) for t in sorted(tage, reverse=True)]     # je Monat der jüngste Tag
behalten.update(sorted(monate.values(), reverse=True)[:3])                                       # monatlich 3
loeschen = [t for t in tage if t not in behalten]
print('Dateien: %d, behalten: %d, löschbar: %d' % (len(tage), len(behalten), len(loeschen)))
print('Älteste behaltene Datei:', min(behalten)); print('Jüngste löschbare Datei:', max(loeschen))
PY
step "6. Hinweise (Text)"
cat <<'T'
Der private Schlüssel gehört nicht auf den Sicherungsserver und braucht eine eigene, getrennte Sicherung.
Ohne den privaten Schlüssel sind die Sicherungen unbrauchbar.
Die Aufbewahrungsregeln sind ein Beispiel; rechtliche Fristen wurden nicht geprüft.
T
