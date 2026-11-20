#!/usr/bin/env python3
"""Hilfsmodell: Ist ein Versionssprung ein Minor- oder ein Major-Update? (Fachwissen, nicht gegen die Herstellerdokumentation geprüft)
Regeln im Modell:
  PostgreSQL ab Version 10: Major = erste Zahl (16.4 -> 16.15 Minor, 16.x -> 17.x Major); vor Version 10: Major = erste zwei Zahlen (9.6 -> 10 Major)
  MariaDB: Hauptversion = erste zwei Zahlen (10.11.8 -> 10.11.14 Minor, 10.11 -> 11.4 Major).
Aufruf: python3 update_planer.py"""

def teile(v):
    return [int(x) for x in v.split('.')]

def art(produkt, alt, neu):
    a, n = teile(alt), teile(neu)
    if produkt == 'postgresql':
        ka = tuple(a[:2]) if a[0] < 10 else (a[0],)
        kn = tuple(n[:2]) if n[0] < 10 else (n[0],)
    elif produkt == 'mariadb':
        ka, kn = tuple(a[:2]), tuple(n[:2])
    else:
        raise ValueError(produkt)
    if (a > n):
        return 'Downgrade (nicht vorgesehen)'
    return 'Minor-Update' if ka == kn else 'Major-Update'

ABLAUF = {
    'Minor-Update': ['Release-Hinweise lesen', 'Sicherung anlegen und Wiederherstellung kennen', 'Paket aktualisieren, Dienst neu starten', 'Prüfen: Version, Fehlerprotokoll, Anwendung'],
    'Major-Update': ['Release-Hinweise und Inkompatibilitäten lesen', 'Sicherung anlegen und Wiederherstellung testen', 'Update in einer Kopie der Umgebung üben', 'Daten umstellen (Dump/Restore, pg_upgrade bzw. mariadb-upgrade)', 'Statistiken neu erzeugen, Anwendung testen', 'Rückfallplan: alte Version und Sicherung bis zur Abnahme behalten'],
}

if __name__ == '__main__':
    fälle = [('postgresql', '16.4', '16.15'), ('postgresql', '16.15', '17.2'), ('postgresql', '9.6.24', '10.5'),
             ('mariadb', '10.11.8', '10.11.14'), ('mariadb', '10.11.14', '11.4.3'), ('mariadb', '11.4.3', '10.11.14')]
    for p, a, n in fälle:
        k = art(p, a, n)
        print(f'{p:11} {a:8} -> {n:8}: {k}')
        for i, s in enumerate(ABLAUF.get(k, []), 1):
            print(f'      {i}. {s}')
