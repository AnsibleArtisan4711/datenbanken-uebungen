#!/usr/bin/env bash
# Modul 3: SQLite sichern: .backup, VACUUM INTO, Kopieren der Datei im laufenden Betrieb, Integritätsprüfung. Im Container ausgeführt (sqlite3).
. "$(dirname "$0")/../lab.sh"
lab_up; mkdir -p "$W"; cd "$W"
step "1. Beispieldatenbank (WAL-Modus, 2000 Zeilen)"
sqlite3 app.db "PRAGMA journal_mode=WAL; create table t (id integer primary key, wert text); with recursive z(i) as (select 1 union all select i+1 from z where i<2000) insert into t select i, 'wert ' || i from z;"
sqlite3 app.db "select count(*) from t" | sed 's/^/Zeilen: /'; ls | tr '\n' ' '; echo
step "2. Sichere Methode 1: .backup (Online-Sicherung über die SQLite-Schnittstelle)"
sqlite3 app.db ".backup 'sicher1.db'"; sqlite3 sicher1.db "select count(*) from t; pragma integrity_check" | tr '\n' ' '; echo
step "3. Sichere Methode 2: VACUUM INTO (kompakte Kopie)"
sqlite3 app.db "VACUUM INTO 'sicher2.db'"; sqlite3 sicher2.db "select count(*) from t; pragma integrity_check" | tr '\n' ' '; echo
step "4. Unsichere Methode: Hauptdatei kopieren, während eine andere Verbindung geöffnet ist und Änderungen nur im WAL stehen"
python3 - <<'PY'
import sqlite3, shutil
c = sqlite3.connect('app.db'); c.execute('insert into t select id + 10000, "neu" from t limit 100'); c.commit()   # Verbindung bleibt offen, kein Checkpoint
shutil.copy('app.db', 'kopie_ohne_wal.db')
import os
print('Dateien app.db* während der offenen Verbindung:', ', '.join(sorted(f for f in os.listdir('.') if f.startswith('app.db'))))
print('Zeilen in der Datenbank:', c.execute('select count(*) from t').fetchone()[0])
c.close()
PY
sqlite3 kopie_ohne_wal.db "select count(*) from t" | sed 's/^/Zeilen in der kopierten Hauptdatei: /'
step "5. Beschädigung erkennen: Prüfsumme und integrity_check"
cp sicher1.db kaputt1.db; printf 'XXXXXXXXXXXX' | dd of=kaputt1.db bs=1 seek=3000 conv=notrunc 2>/dev/null
cp sicher1.db kaputt2.db; printf 'XXXXXXXXXXXX' | dd of=kaputt2.db bs=1 seek=0 conv=notrunc 2>/dev/null
echo "Prüfsumme gleich (Änderung in der Mitte): $([ "$(sha256sum < sicher1.db)" = "$(sha256sum < kaputt1.db)" ] && echo ja || echo nein)"
echo "integrity_check (Änderung in der Mitte): $(sqlite3 kaputt1.db 'pragma integrity_check' 2>&1 | head -1)"
echo "integrity_check (Änderung am Dateikopf): $(sqlite3 kaputt2.db 'pragma integrity_check' 2>&1 | head -1)"
step "6. Hinweis (Text)"
echo "Eine Prüfsumme erkennt jede Änderung; integrity_check prüft die Struktur, nicht jeden Dateninhalt."
echo "Für Sicherungen im laufenden Betrieb .backup oder VACUUM INTO verwenden; reines Kopieren nur bei geschlossener Datenbank oder mit allen zugehörigen Dateien."
