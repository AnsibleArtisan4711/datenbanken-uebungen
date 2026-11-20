#!/usr/bin/env python3
"""Prüft eine Konfigurationsdatei (MariaDB .cnf oder postgresql.conf) auf riskante Einstellungen.
Aufruf: python3 konfig_pruefen.py DATEI. Rückgabecode 0 = keine Hinweise, 1 = Hinweise.
Die Regeln sind eine kleine Auswahl aus Fachwissen und kein vollständiges Härtungsprofil."""
import re, sys

def lies(pfad):
    werte = {}
    for z in open(pfad, encoding='utf-8'):
        z = z.split('#')[0].strip()
        if not z or z.startswith('['):
            continue
        if '=' in z:
            k, v = z.split('=', 1)
            werte[k.strip().replace('-', '_')] = v.strip().strip("'\"")
        else:
            werte[z.replace('-', '_')] = True
    return werte

def zahl(v):
    m = re.match(r'(\d+)', str(v)); return int(m.group(1)) if m else 0

# (Schlüssel, Bedingung, Stufe, Hinweis)
REGELN = [
    ('skip_grant_tables', lambda v: v is True or str(v).lower() in ('1', 'on', 'true'), 'KRITISCH', 'Rechteprüfung ist abgeschaltet: jeder kann sich ohne Kennwort als Administrator anmelden'),
    ('bind_address', lambda v: v in ('0.0.0.0', '*', '::'), 'WARNUNG', 'Dienst lauscht auf allen Schnittstellen; Zugriff nur bewusst und mit Firewall zulassen'),
    ('listen_addresses', lambda v: '*' in str(v) or str(v) == '0.0.0.0', 'WARNUNG', 'Dienst lauscht auf allen Schnittstellen; zusätzlich pg_hba.conf und Firewall prüfen'),
    ('max_connections', lambda v: zahl(v) > 1000, 'WARNUNG', 'sehr viele Verbindungen: Speicherbedarf je Verbindung beachten, ggf. Verbindungspool einsetzen'),
    ('local_infile', lambda v: str(v).lower() in ('1', 'on', 'true'), 'WARNUNG', 'Dateien des Clients können geladen werden; nur bei Bedarf aktivieren'),
    ('fsync', lambda v: str(v).lower() in ('off', '0', 'false'), 'KRITISCH', 'Daten können nach einem Absturz beschädigt sein; nur für Wegwerf-Testsysteme vertretbar'),
    ('ssl', lambda v: str(v).lower() in ('off', '0', 'false'), 'WARNUNG', 'Verbindungen werden nicht verschlüsselt'),
    ('log_connections', lambda v: str(v).lower() in ('off', '0', 'false'), 'HINWEIS', 'Anmeldungen werden nicht protokolliert'),
]

def main(pfad):
    w = lies(pfad); n = 0
    for k, bed, stufe, text in REGELN:
        if k in w and bed(w[k]):
            print(f'{stufe:9} {k} = {w[k]}: {text}'); n += 1
    print(f'{n} Hinweis(e) in {pfad}')
    return 1 if n else 0

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(__doc__); sys.exit(2)
    sys.exit(main(sys.argv[1]))
