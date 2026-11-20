#!/usr/bin/env python3
"""SQL-Server-Agent-Aufträge als CSV prüfen und die nächsten Ausführungen berechnen (Modell, ERFUNDENE Aufträge).
Spalten: auftrag, intervall (taeglich|woechentlich|stuendlich), start (HH:MM), wochentag (Mo..So oder -), aktiv, benachrichtigung."""
import csv, sys
from datetime import datetime, timedelta
JETZT = datetime(2026, 11, 20, 8, 15)
WT = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
def naechster(z):
    h, m = map(int, z['start'].split(':'))
    if z['intervall'] == 'stuendlich':
        t = JETZT.replace(minute=m, second=0, microsecond=0)
        return t if t > JETZT else t + timedelta(hours=1)
    t = JETZT.replace(hour=h, minute=m, second=0, microsecond=0)
    if z['intervall'] == 'woechentlich':
        t += timedelta(days=(WT.index(z['wochentag']) - t.weekday()) % 7)
    return t if t > JETZT else t + timedelta(days=1 if z['intervall'] == 'taeglich' else 7)
daten = list(csv.DictReader(open(sys.argv[1] if len(sys.argv) > 1 else 'beispiel_jobs.csv', encoding='utf-8')))
print(f"Stand (angenommen): {JETZT:%a %d.%m.%Y %H:%M}")
print(f"{'Auftrag':26} {'Intervall':13} {'nächster Lauf':18} Hinweise")
for z in daten:
    hin = []
    if z['aktiv'] != 'ja': hin.append('deaktiviert')
    if z['benachrichtigung'] == 'nein' and z['aktiv'] == 'ja': hin.append('keine Benachrichtigung bei Fehler')
    n = naechster(z) if z['aktiv'] == 'ja' else None
    print(f"{z['auftrag']:26} {z['intervall']:13} {n.strftime('%d.%m. %H:%M') if n else '-':18} {'; '.join(hin)}")
