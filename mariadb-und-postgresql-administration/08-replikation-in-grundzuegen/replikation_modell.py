#!/usr/bin/env python3
"""Modell: asynchrone und synchrone Replikation, Verzögerung und Datenverlust bei einem Ausfall des Primärservers.
Vereinfachtes Zufallsmodell mit festem Startwert (erfundene Zahlen). Aufruf: python3 replikation_modell.py"""
import random

def simuliere(modus, n=1000, verzoegerung_ms=(5, 400), ausfall_bei=800, seed=42):
    """Primär schreibt n Transaktionen (je 1 ms Abstand). Jede wird nach 'verzoegerung' beim Replikat bestätigt.
    modus 'async': der Primär bestätigt dem Client sofort; modus 'sync': erst nach Bestätigung des Replikats.
    Ausfall des Primärservers bei Transaktion 'ausfall_bei'. Gezählt wird, was der Client als bestätigt kennt, aber das Replikat nicht hat."""
    r = random.Random(seed)
    zeit_primaer = [i for i in range(n)]
    ankunft = [t + r.randint(*verzoegerung_ms) for t in zeit_primaer]       # wann das Replikat die Transaktion hat
    t_ausfall = ausfall_bei
    bestaetigt = [i for i in range(n) if (zeit_primaer[i] < t_ausfall if modus == 'async' else ankunft[i] < t_ausfall)]
    beim_replikat = {i for i in range(n) if ankunft[i] <= t_ausfall}
    verloren = [i for i in bestaetigt if i not in beim_replikat]
    return len(bestaetigt), len(verloren)

if __name__ == '__main__':
    print('Modell (erfundene Verzögerungen 5 bis 400 ms, Ausfall nach 800 ms, 1 Transaktion je ms):')
    for modus in ('async', 'sync'):
        best, verl = simuliere(modus)
        print(f'  {modus:5}: dem Client bestätigt: {best:4}, davon nach dem Ausfall auf dem Replikat nicht vorhanden: {verl:4}')
    print('Folge: Asynchrone Replikation kann bestätigte Transaktionen verlieren (RPO > 0); synchrone nicht, kostet aber Wartezeit je Schreibvorgang.')
    for v in (5, 50, 400):
        best, verl = simuliere('async', verzoegerung_ms=(v, v))
        print(f'  async, feste Verzögerung {v:3} ms: verloren {verl}')
