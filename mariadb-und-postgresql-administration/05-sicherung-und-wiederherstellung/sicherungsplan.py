#!/usr/bin/env python3
"""Modell: Datenverlust (RPO) und Wiederherstellungsdauer (RTO) verschiedener Sicherungsvarianten.
Alle Zahlen sind ANNAHMEN (Datenmenge, Durchsatz) und keine Messwerte. Aufruf: python3 sicherungsplan.py"""
DATEN_GB = 50          # Annahme: Größe der Datenbank
LESEN_MB_S = 150       # Annahme: Durchsatz beim Zurückkopieren einer physischen Sicherung
LOGISCH_MB_S = 40      # Annahme: logische Wiederherstellung (SQL einspielen, Indizes bauen)
PROTOKOLL_MIN_PRO_H = 2  # Annahme: Minuten Wiederholung je Stunde Protokoll (Binärprotokoll/WAL)

def dauer_min(gb, mb_s):
    return gb * 1024 / mb_s / 60

# (Name, RPO in Minuten, Wiederherstellungsdauer in Minuten)
def varianten():
    taeglich_logisch = (24 * 60, dauer_min(DATEN_GB, LOGISCH_MB_S))
    taeglich_physisch = (24 * 60, dauer_min(DATEN_GB, LESEN_MB_S))
    # Physische Sicherung + laufend archivierte Protokolle (WAL/Binärprotokoll): im Mittel bis zu 5 Minuten verloren,
    # im ungünstigsten Fall bis zum Wechsel der Protokolldatei (Annahme 5 Minuten); Wiederholung bis zu 24 h Protokoll
    mit_archiv = (5, dauer_min(DATEN_GB, LESEN_MB_S) + 24 * PROTOKOLL_MIN_PRO_H)
    return [('Täglich logisch (Dump)', *taeglich_logisch),
            ('Täglich physisch (Basissicherung)', *taeglich_physisch),
            ('Physisch + Protokollarchiv', *mit_archiv)]

def pruefe(rpo_ziel_min, rto_ziel_min):
    print(f'Ziele: RPO höchstens {rpo_ziel_min} min, RTO höchstens {rto_ziel_min} min; Datenbank {DATEN_GB} GB (Annahme)')
    print(f'{"Variante":38}{"RPO min":>9}{"RTO min":>9}  Ergebnis')
    for name, rpo, rto in varianten():
        ok_rpo, ok_rto = rpo <= rpo_ziel_min, rto <= rto_ziel_min
        erg = 'erfüllt' if ok_rpo and ok_rto else 'verfehlt: ' + ', '.join(n for n, o in (('RPO', ok_rpo), ('RTO', ok_rto)) if not o)
        print(f'{name:38}{rpo:>9.0f}{rto:>9.0f}  {erg}')

if __name__ == '__main__':
    pruefe(15, 120)
    print()
    pruefe(24 * 60, 480)
