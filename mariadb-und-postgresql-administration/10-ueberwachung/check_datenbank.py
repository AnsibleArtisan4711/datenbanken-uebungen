#!/usr/bin/env python3
"""Überwachungs-Plugin im Stil von Nagios/Icinga: prüft Erreichbarkeit und Verbindungsauslastung.
Rückgabecodes: 0 = OK, 1 = WARNUNG, 2 = KRITISCH, 3 = UNBEKANNT.
Aufrufe:
  python3 check_datenbank.py mariadb  SOCKET-PFAD WARN% KRIT%
  python3 check_datenbank.py postgres PORT        WARN% KRIT%   (Anmeldung als Betriebssystembenutzer postgres über Socket)
Die Prüfung ist ein einfaches Beispiel und ersetzt kein Überwachungssystem."""
import subprocess, sys

def lauf(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, timeout=15)

def mariadb(sock):
    q = "select (select variable_value from information_schema.global_status where variable_name='THREADS_CONNECTED'), @@max_connections"
    r = lauf(['mariadb', '--no-defaults', '-S', sock, '-uroot', '-N', '-e', q])
    if r.returncode != 0:
        return None
    a, b = r.stdout.split(); return int(a), int(b)

def postgres(port):
    q = "select count(*), current_setting('max_connections')::int from pg_stat_activity where backend_type='client backend'"
    r = lauf(['su', 'postgres', '-c', f'psql -X -At -F" " -p {port} -d postgres -c "{q}"'])
    if r.returncode != 0:
        return None
    a, b = r.stdout.split(); return int(a), int(b)

def main(argv):
    if len(argv) != 5 or argv[1] not in ('mariadb', 'postgres'):
        print('UNBEKANNT - falscher Aufruf'); return 3
    art, ziel, warn, krit = argv[1], argv[2], float(argv[3]), float(argv[4])
    try:
        wert = mariadb(ziel) if art == 'mariadb' else postgres(ziel)
    except Exception as e:
        print(f'UNBEKANNT - Prüfung fehlgeschlagen: {e}'); return 3
    if wert is None:
        print(f'KRITISCH - {art} nicht erreichbar ({ziel})'); return 2
    n, mx = wert
    proz = 100 * n / mx
    text = f'{n} von {mx} Verbindungen ({proz:.0f} %) | verbindungen={n};{warn};{krit};0;{mx}'
    if proz >= krit: print('KRITISCH - ' + text); return 2
    if proz >= warn: print('WARNUNG - ' + text); return 1
    print('OK - ' + text); return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
