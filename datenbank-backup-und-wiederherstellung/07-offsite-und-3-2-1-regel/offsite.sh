#!/usr/bin/env bash
# Modul 7 (Priorität 2): 3-2-1-Prüfung und Modell einer schreibgeschützten Kopie. Alles lokal im Container; Offsite und Objektsperre sind nur modelliert.
. "$(dirname "$0")/../lab.sh"
mkdir -p "$W/o"; cd "$W/o"; rm -rf *
step "1. Bestand beschreiben (Modell, Orte erfunden)"
cat > bestand.csv <<'T'
daten,kopie,medium,ort
shop-db,original,SSD-Server,rechenzentrum-a
shop-db,sicherung-1,NAS,rechenzentrum-a
shop-db,sicherung-2,Objektspeicher,anbieter-extern
buchhaltung,original,SSD-Server,rechenzentrum-a
buchhaltung,sicherung-1,NAS,rechenzentrum-a
T
cat bestand.csv
step "2. 3-2-1 prüfen: mindestens 3 Kopien, 2 Medien, 1 anderer Ort"
python3 - <<'P'
import csv, collections
d = collections.defaultdict(list)
for z in csv.DictReader(open("bestand.csv")): d[z["daten"]].append(z)
for n, k in d.items():
    kop = len(k); med = len({z["medium"] for z in k}); orte = len({z["ort"] for z in k})
    ok = kop >= 3 and med >= 2 and orte >= 2
    print(f"{n:12} Kopien={kop} Medien={med} Orte={orte} -> {'erfüllt' if ok else 'NICHT erfüllt'}")
P
step "3. Schreibgeschützte Kopie (Modell): Dateirecht chmod 444"
echo "Sicherung 2026-11-20" > kopie.txt; chmod 444 kopie.txt
echo "neuer Inhalt" > kopie.txt 2>/dev/null && echo "überschrieben (als root möglich)" || echo "Schreiben verweigert"
echo "Hinweis: root umgeht Dateirechte. Eine Objektsperre beim Anbieter oder eine getrennte Zugangskennung leistet das, was chmod nicht kann (nicht ausgeführt)."
step "4. Angriffsmodell: Wer darf Sicherungen löschen?"
cat <<'T'
Rolle              Sicherung schreiben  Sicherung löschen
Sicherungskonto    ja                   nein (nur Anbieterseitige Aufbewahrungsfrist)
Datenbankadmin     nein                 nein
Sicherungsleitung  nein                 ja, mit zweiter Person
T
