#!/usr/bin/env python3
"""Edition anhand von Anforderungen auswählen (Modell mit Werten aus Microsoft Learn, Abruf 20.11.2026, SQL Server 2025).
„None“ bedeutet: Wert nicht gelesen. Lizenz- und Editionsstand ändern sich; vor dem Einsatz die aktuelle Seite prüfen."""
# Name: (max. Datenbankgröße GB, Sockel, Kerne, RAM GB je Instanz, produktiv erlaubt, Hinweis)
EDITIONEN = {
    'Enterprise':          (None, None, None, None, True,  'Grenzen nicht gelesen'),
    'Standard':            (None, 4, 32, 256,      True,  '2025: 4 Sockel, 32 Kerne, 256 GB (2022: 24 Kerne, 128 GB)'),
    'Enterprise Developer':(None, None, None, None, False, 'Funktionsumfang wie Enterprise, nur Entwicklung und Test (Fachwissen)'),
    'Standard Developer':  (None, 4, 32, 256,      False, 'nur Entwicklung und Test (Fachwissen)'),
    'Evaluation':          (None, None, None, None, False, 'zeitlich begrenzt auf 180 Tage'),
    'Express':             (50,   1, 4,  None,     True,  '2025: 50 GB je Datenbank (2022 und früher: 10 GB); 1 Sockel, 4 Kerne; Pufferpool 1.410 MB'),
}
def passt(name, db_gb, kerne, produktiv):
    gb, sockel, k, ram, prod, _ = EDITIONEN[name]
    grund = []
    if produktiv and not prod: grund.append('nicht für den Produktivbetrieb')
    if gb is not None and db_gb > gb: grund.append(f'Datenbank {db_gb} GB über Grenze {gb} GB')
    if k is not None and kerne > k: grund.append(f'{kerne} Kerne über Grenze {k}')
    return grund

FAELLE = [
    ('Lernlabor, 5 GB, 2 Kerne, nicht produktiv', 5, 2, False),
    ('Kleine Firma, 30 GB, 4 Kerne, produktiv', 30, 4, True),
    ('Abteilung, 200 GB, 16 Kerne, produktiv', 200, 16, True),
    ('Großes System, 2000 GB, 48 Kerne, produktiv', 2000, 48, True),
]
for text, gb, kerne, prod in FAELLE:
    print(f'## {text}')
    for n in EDITIONEN:
        g = passt(n, gb, kerne, prod)
        unbekannt = EDITIONEN[n][0] is None or EDITIONEN[n][2] is None
        print(f"  {n:22} {('passt' + (' (Grenzen nicht gelesen)' if unbekannt else '')) if not g else 'passt nicht: ' + '; '.join(g)}")
    print()
print('Hinweis: Die Tabelle ist unvollständig (Enterprise-Grenzen und weitere Funktionsunterschiede wurden nicht gelesen).')
