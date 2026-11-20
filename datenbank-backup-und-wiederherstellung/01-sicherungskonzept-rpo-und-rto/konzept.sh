#!/usr/bin/env bash
# Modul 1: Sicherungskonzept für Datenbanken: Anforderungen (RPO/RTO) in Verfahren übersetzen. Modellrechnung mit erfundenen Zahlen.
. "$(dirname "$0")/../lab.sh"
python3 - <<'PY'
daten = [  # (Datenbank, Größe GB, Änderungen je Stunde in MB, RPO Minuten, RTO Minuten)
    ('shop', 20, 300, 15, 60), ('wiki', 2, 5, 1440, 480), ('berichte', 150, 50, 720, 240),
]
DURCHSATZ = 100  # MB/s Annahme für Sichern und Wiederherstellen
print('\n## 1. Anforderungen und Datenmengen (Annahmen)')
print('  %-9s %8s %10s %9s %9s' % ('System', 'GB', 'MB/Std', 'RPO min', 'RTO min'))
for n, g, c, rpo, rto in daten: print('  %-9s %8d %10d %9d %9d' % (n, g, c, rpo, rto))
print('\n## 2. Wiederherstellungsdauer aus der Größe (Annahme %d MB/s, ohne Vorbereitung)' % DURCHSATZ)
for n, g, c, rpo, rto in daten:
    dauer = g * 1024 / DURCHSATZ / 60
    print('  %-9s %6.1f Minuten -> %s' % (n, dauer, 'passt in RTO' if dauer <= rto else 'RTO verfehlt'))
print('\n## 3. Verfahren nach RPO wählen (Regel des Modells)')
for n, g, c, rpo, rto in daten:
    if rpo <= 60: v = 'Voll + fortlaufende Protokollsicherung (Binlog oder WAL)'
    elif rpo <= 720: v = 'Voll täglich + Protokollsicherung stündlich'
    else: v = 'Voll täglich'
    print('  %-9s RPO %4d min -> %s' % (n, rpo, v))
print('\n## 4. Menge der Protokolle zwischen zwei Vollsicherungen (täglich), Annahme gleichmäßige Änderungen')
for n, g, c, rpo, rto in daten: print('  %-9s %5.1f GB je Tag' % (n, c * 24 / 1024))
print('\n## 5. Hinweis')
print('  Alle Zahlen sind erfundene Annahmen; die Regeln des Modells sind kein Standard.')
PY
