#!/usr/bin/env python3
"""Wartezeiten (Wait Statistics) aus einer CSV auswerten und deuten (Beispieldaten ERFUNDEN; Spalten: wait_type, wait_ms, anzahl).
Die Deutung der Wait-Typen ist Fachwissen und NICHT bestätigt; Namen echter Wait-Typen können abweichen oder fehlen."""
import csv, sys
DEUTUNG = {
    'PAGEIOLATCH_SH': 'wartet auf Lesen von Datenseiten von der Platte (Speicher-Leistung, fehlende Indizes, zu wenig RAM)',
    'WRITELOG': 'wartet auf Schreiben ins Transaktionsprotokoll (Platte des Protokolls, sehr viele kleine Transaktionen)',
    'LCK_M_X': 'wartet auf eine Sperre (Blockierung durch andere Sitzung)',
    'SOS_SCHEDULER_YIELD': 'CPU-Druck: Aufgaben warten auf Rechenzeit',
    'CXPACKET': 'Wartezeit bei paralleler Ausführung (Parallelität, Pläne prüfen)',
    'ASYNC_NETWORK_IO': 'Client holt Ergebnisse langsam ab (Anwendung oder Netzwerk)',
}
GUTARTIG = {'SLEEP_TASK', 'LAZYWRITER_SLEEP', 'XE_TIMER_EVENT', 'CHECKPOINT_QUEUE'}   # Hintergrundwarten, im Modell ignoriert
daten = list(csv.DictReader(open(sys.argv[1] if len(sys.argv) > 1 else 'beispiel_waits.csv', encoding='utf-8')))
nutz = [d for d in daten if d['wait_type'] not in GUTARTIG]
gesamt = sum(int(d['wait_ms']) for d in nutz)
print(f"{len(daten)} Zeilen, davon {len(daten)-len(nutz)} Hintergrund-Waits ignoriert; Summe der übrigen Wartezeit {gesamt} ms\n")
print(f"{'Wait-Typ':22} {'ms':>9} {'Anteil':>7} {'Anzahl':>8} {'ms/Wait':>8}  Deutung")
for d in sorted(nutz, key=lambda d: -int(d['wait_ms'])):
    ms, n = int(d['wait_ms']), int(d['anzahl'])
    print(f"{d['wait_type']:22} {ms:>9} {ms/gesamt:>6.0%} {n:>8} {ms/n:>8.1f}  {DEUTUNG.get(d['wait_type'], 'unbekannt: nachschlagen')}")
print("\nHinweis: Wait-Statistiken zeigen Symptome, keine Ursache; sie gelten seit dem letzten Start der Instanz (Fachwissen, nicht bestätigt).")
