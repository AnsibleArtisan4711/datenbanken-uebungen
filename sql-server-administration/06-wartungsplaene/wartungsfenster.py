#!/usr/bin/env python3
"""Wartungsplan prüfen: überlappen sich Aufgaben im Wartungsfenster? (Modell mit erfundenen Aufgaben und Laufzeiten.)
Eingabe sind Startzeit und geschätzte Dauer je Aufgabe in Minuten; Ausgabe sind Überschneidungen und das Ende des Fensters."""
AUFGABEN = [  # Name, Start (Minuten ab 00:00), Dauer
    ('Vollsicherung', 22*60, 90), ('Konsistenzprüfung (DBCC CHECKDB)', 23*60, 120),
    ('Indexpflege', 23*60 + 30, 90), ('Statistiken aktualisieren', 1*60 + 30 + 24*60, 30), ('Protokollsicherung', 22*60 + 30, 10),
]
FENSTER_ENDE = 24*60 + 3*60   # Fenster bis 03:00 am Folgetag
def zeit(m): return f"{(m//60) % 24:02d}:{m % 60:02d}"
print(f"{'Aufgabe':36} {'Start':>6} {'Ende':>6}")
for n, s, d in sorted(AUFGABEN, key=lambda a: a[1]): print(f"{n:36} {zeit(s):>6} {zeit(s+d):>6}")
print()
for i, (n1, s1, d1) in enumerate(AUFGABEN):
    for n2, s2, d2 in AUFGABEN[i+1:]:
        if s1 < s2 + d2 and s2 < s1 + d1: print(f"Überschneidung: {n1} ({zeit(s1)}-{zeit(s1+d1)}) und {n2} ({zeit(s2)}-{zeit(s2+d2)})")
ende = max(s + d for _, s, d in AUFGABEN)
print(f"\nLetzte Aufgabe endet {zeit(ende)}; Fenster endet {zeit(FENSTER_ENDE)}: {'im Fenster' if ende <= FENSTER_ENDE else 'ÜBER das Fenster hinaus'}")
print("Hinweis: Fachwissen (nicht bestätigt): Sicherung und Konsistenzprüfung gleichzeitig belasten die Platten; Protokollsicherungen dürfen auch während der Wartung nicht ausfallen.")
