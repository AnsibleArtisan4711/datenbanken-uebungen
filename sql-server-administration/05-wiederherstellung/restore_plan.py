#!/usr/bin/env python3
"""Wiederherstellungsplan aus einer Sicherungskette berechnen (Modell mit ERFUNDENEN Sicherungen).
Vereinfachung: Die Folgenummern der Protokollsicherungen zählen lückenlos ab der Vollsicherung vom Sonntag; Zeitstempel stehen für das Ende der Sicherung.
Reihenfolge nach Microsoft Learn (Abruf 20.11.2026): Protokollfragment sichern (wenn möglich), letzte Vollsicherung, letzte passende
Differenzsicherung, danach alle Protokollsicherungen lückenlos bis zum Ziel (STOPAT). Das Skript führt nichts aus und prüft keine .bak-Dateien."""
from datetime import datetime as D
KETTE = [  # (Art, Datei, Zeitpunkt, Basis-Voll, Folge-Nr)
    ('FULL', 'voll_so.bak',  D(2026,11,15,2,0),  None, None),
    ('DIFF', 'diff_mo.bak',  D(2026,11,16,2,0),  'voll_so.bak', None),
    ('DIFF', 'diff_di.bak',  D(2026,11,17,2,0),  'voll_so.bak', None),
    ('LOG',  'log_001.trn',  D(2026,11,17,6,0),  None, 1),
    ('LOG',  'log_002.trn',  D(2026,11,17,10,0), None, 2),
    ('LOG',  'log_004.trn',  D(2026,11,17,18,0), None, 4),   # Lücke: log_003 fehlt
    ('LOG',  'log_005.trn',  D(2026,11,17,22,0), None, 5),
]
def plan(ziel):
    voll = max((k for k in KETTE if k[0] == 'FULL' and k[2] <= ziel), key=lambda k: k[2])
    diffs = [k for k in KETTE if k[0] == 'DIFF' and k[3] == voll[1] and k[2] <= ziel]
    diff = max(diffs, key=lambda k: k[2]) if diffs else None
    start = (diff or voll)[2]
    logs = sorted((k for k in KETTE if k[0] == 'LOG' and k[2] > start), key=lambda k: k[4])
    schritte = [f"1. Protokollfragment sichern (BACKUP LOG ... WITH NORECOVERY), falls die Datenbank noch erreichbar ist",
                f"2. RESTORE DATABASE aus {voll[1]} WITH NORECOVERY"]
    if diff: schritte.append(f"3. RESTORE DATABASE aus {diff[1]} WITH NORECOVERY")
    n, letzte, warn = 4 if diff else 3, None, []
    for l in logs:
        if letzte is not None and l[4] != letzte + 1:
            warn.append(f"LÜCKE: nach log_{letzte:03d} fehlt log_{letzte+1:03d}; Wiederherstellung nur bis {logs[logs.index(l)-1][2]:%d.%m. %H:%M}")
            break
        schritte.append(f"{n}. RESTORE LOG aus {l[1]} WITH NORECOVERY" + (f", STOPAT '{ziel:%Y-%m-%d %H:%M}'" if l[2] >= ziel else ''))
        n += 1; letzte = l[4]
        if l[2] >= ziel: break
    schritte.append(f"{n}. RESTORE DATABASE ... WITH RECOVERY")
    return schritte, warn
for ziel in (D(2026,11,17,9,0), D(2026,11,17,20,0), D(2026,11,16,12,0)):
    s, w = plan(ziel)
    print(f"## Ziel: {ziel:%d.%m.%Y %H:%M}")
    for z in s: print('  ' + z)
    for x in w: print('  !! ' + x)
    print()
