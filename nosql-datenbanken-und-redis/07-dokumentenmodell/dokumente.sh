#!/usr/bin/env bash
# Modul 7 (Priorität 2): Dokumentenmodell am Python-Modell (kein MongoDB im Test). Die Befehle in mongodb_beispiel.txt wurden NICHT ausgeführt.
. "$(dirname "$0")/../lab.sh"
lab_up; D="$(dirname "$0")"
python3 - "$D" <<'PY'
import sys, json; sys.path.insert(0, sys.argv[1])
from dokumente import Sammlung
k = Sammlung()
k.einfuegen({'name': 'Anna', 'alter': 31, 'adresse': {'ort': 'Musterstadt', 'plz': '12345'}, 'tags': ['a', 'b']})
k.einfuegen({'name': 'Ben', 'alter': 24, 'adresse': {'ort': 'Beispielort'}})
k.einfuegen({'name': 'Cara', 'alter': 45, 'adresse': {'ort': 'Musterstadt'}, 'newsletter': True})
p = lambda t, x: print('%s -> %s' % (t, json.dumps(x, ensure_ascii=False)))
print('\n## 1. Dokumente verschieden aufgebaut (flexible Felder): Anzahl und Felder je Dokument')
for d in k.docs: print('  _id=%d Felder: %s' % (d['_id'], ', '.join(sorted(d))))
print('\n## 2. Suchen mit Gleichheit, Vergleich und Liste')
p('alter > 30', [d['name'] for d in k.finde({'alter': {'$gt': 30}})])
p('ort = Musterstadt', [d['name'] for d in k.finde({'adresse.ort': 'Musterstadt'})])
p('name in [Ben, Cara]', [d['name'] for d in k.finde({'name': {'$in': ['Ben', 'Cara']}})])
print('\n## 3. Projektion (nur bestimmte Felder, auch verschachtelt)')
p('name, adresse.plz', k.finde({}, ['name', 'adresse.plz']))
print('\n## 4. Ändern (auch verschachtelt) und fehlende Felder')
print('  geändert:', k.aendere({'name': 'Ben'}, {'adresse.plz': '54321', 'newsletter': False}))
p('Ben', [d for d in k.finde({'name': 'Ben'})][0]['adresse'])
p('newsletter vorhanden (Wert nicht None)', [d['name'] for d in k.docs if d.get('newsletter') is not None])
print('\n## 5. Operator, den das Modell nicht kennt')
try: k.finde({'alter': {'$regex': 'x'}})
except ValueError as e: print('  Fehler:', e)
PY
step "6. Gegenüberstellung mit dem relationalen Modell (Text)"
cat <<'T'
Relational: feste Spalten, Verknüpfungen (JOIN), Schema im Voraus, starke Konsistenzregeln
Dokument  : Daten eines Objekts zusammen in einem Dokument, flexible Felder; Verknüpfungen sind aufwendiger
Nicht ausgeführt: MongoDB, Indizes, Aggregation, Transaktionen, Replikation von Dokumentendatenbanken
T
step "7. Beispielbefehle (Datei, nicht ausgeführt)"
sed -n 1,4p "$D/mongodb_beispiel.txt"
