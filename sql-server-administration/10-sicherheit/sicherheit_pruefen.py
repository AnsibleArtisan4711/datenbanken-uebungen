#!/usr/bin/env python3
"""Sicherheits-Checkliste auswerten (Modell mit erfundenen Antworten in beispiel_stand.csv; Spalten: pruefpunkt, ergebnis).
Die Prüfpunkte sind Fachwissen und NICHT bestätigt; sie ersetzen weder ein Härtungs-Handbuch noch eine Prüfung der Instanz."""
import csv, sys
PUNKTE = {
    'sa_deaktiviert': ('Konto sa deaktiviert oder umbenannt', 'hoch'),
    'windows_authentifizierung': ('Windows-Authentifizierung bevorzugt', 'mittel'),
    'verbindung_verschluesselt': ('Verbindungen verschlüsselt (Zertifikat)', 'hoch'),
    'daten_verschluesselt': ('Datenbank verschlüsselt (z. B. TDE) oder Datenträger verschlüsselt', 'mittel'),
    'sicherung_verschluesselt': ('Sicherungen verschlüsselt oder an geschütztem Ort', 'hoch'),
    'audit_aktiv': ('Anmeldungen und Rechteänderungen werden protokolliert', 'mittel'),
    'patchstand_aktuell': ('Aktualisierungen innerhalb von 30 Tagen eingespielt (Annahme)', 'hoch'),
    'dienstkonto_minimal': ('Dienstkonto ohne Administratorrechte', 'hoch'),
}
erg = {r['pruefpunkt']: r['ergebnis'] for r in csv.DictReader(open(sys.argv[1] if len(sys.argv) > 1 else 'beispiel_stand.csv', encoding='utf-8'))}
offen = 0
for k, (text, risiko) in PUNKTE.items():
    e = erg.get(k, 'unbekannt')
    if e != 'ja': offen += 1
    print(f"{'OK  ' if e == 'ja' else 'OFFEN'} [{risiko:6}] {text}" + ('' if e in ('ja', 'nein') else ' (nicht geprüft)'))
print(f"\n{offen} von {len(PUNKTE)} Punkten offen; Reihenfolge der Behebung: zuerst Risiko hoch.")
