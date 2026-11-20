#!/usr/bin/env python3
"""Welche Wiederherstellungen sind je Recovery-Modell möglich? Modell der Regeln (Fachwissen, nicht bestätigt) plus Beispielrechnung
für Sicherungsvolumen und Verlustzeit. Zahlen sind erfunden."""
MODELLE = {
    'SIMPLE':      dict(log_sicherung=False, zeitpunkt=False, text='Protokoll wird automatisch gekürzt; nur Voll- und Differenz-Sicherungen; Wiederherstellung nur auf den Sicherungszeitpunkt'),
    'FULL':        dict(log_sicherung=True,  zeitpunkt=True,  text='Protokoll bleibt bis zur Protokollsicherung; Wiederherstellung auf einen Zeitpunkt möglich'),
    'BULK_LOGGED': dict(log_sicherung=True,  zeitpunkt=False, text='wie FULL, aber Massenvorgänge minimal protokolliert; Zeitpunkt-Wiederherstellung eingeschränkt (Fachwissen)'),
}
for n, m in MODELLE.items():
    print(f"{n:12} Protokollsicherung: {'ja' if m['log_sicherung'] else 'nein'}  Zeitpunkt: {'ja' if m['zeitpunkt'] else 'eingeschränkt/nein'}  -> {m['text']}")
print()
print('## Verlustzeit und Volumen (erfundene Zahlen: Datenbank 200 GB, Änderungen 5 GB/Tag, Protokoll 0,4 GB/Stunde)')
voll_tag, diff_gb, log_stunde = 200, 5, 0.4
print(f"{'Strategie':44} {'max. Verlust':>13} {'Volumen/Woche GB':>17}")
plan = [
    ('FULL täglich (SIMPLE)', '24 h', voll_tag * 7),
    ('FULL wöchentlich + DIFF täglich (SIMPLE)', '24 h', voll_tag + 6 * diff_gb * 2),
    ('FULL wöchentlich + DIFF täglich + LOG alle 15 Min', '15 Min', voll_tag + 6 * diff_gb * 2 + log_stunde * 24 * 7),
]
for t, v, g in plan: print(f'{t:44} {v:>13} {g:>17.0f}')
print('Hinweis: Die DIFF-Größe wächst im Modell nicht über die Woche (vereinfacht: 2 × Tageszuwachs je Tag).')
