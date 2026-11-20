#!/usr/bin/env python3
"""Rechte-Übersicht (CSV) auf riskante Muster prüfen. Die CSV ist ERFUNDEN; sie bildet vereinfacht Anmeldungen, Serverrollen und
Datenbankrollen nach (Spalten: anmeldung, typ, aktiv, serverrolle, datenbank, datenbankrolle, kennwortrichtlinie). Reine Textprüfung, kein SQL Server."""
import csv, sys
daten = list(csv.DictReader(open(sys.argv[1] if len(sys.argv) > 1 else 'beispiel_rechte.csv', encoding='utf-8')))
hinweise = []
sysadmins = {d['anmeldung'] for d in daten if d['serverrolle'].lower() == 'sysadmin'}
for d in daten:
    n = d['anmeldung']
    if n.lower() == 'sa' and d['aktiv'].lower() == 'ja': hinweise.append((n, 'Konto `sa` ist aktiv (üblich: umbenennen oder deaktivieren)'))
    if d['typ'] == 'sql' and d['kennwortrichtlinie'].lower() == 'nein': hinweise.append((n, 'SQL-Anmeldung ohne Kennwortrichtlinie'))
    if d['datenbankrolle'].lower() == 'db_owner' and d['typ'] == 'sql' and d['serverrolle'] == '-': hinweise.append((n, f"`db_owner` in {d['datenbank']}: volle Rechte in der Datenbank (prüfen, ob nötig)"))
if len(sysadmins) > 2: hinweise.append(('(Rolle sysadmin)', f'{len(sysadmins)} Anmeldungen mit sysadmin: {", ".join(sorted(sysadmins))} (Annahme: höchstens 2 nötig)'))
print(f'{len(daten)} Zeilen gelesen')
for n, t in hinweise: print(f'  {n:18} {t}')
print(f'-> {len(hinweise)} Hinweis(e)')
