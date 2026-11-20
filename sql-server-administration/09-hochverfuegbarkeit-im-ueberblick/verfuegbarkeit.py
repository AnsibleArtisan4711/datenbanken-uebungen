#!/usr/bin/env python3
"""Verfügbarkeit und Ausfallzeit rechnen; Verfahren für Hochverfügbarkeit im Überblick (Modell, Fachwissen, NICHT bestätigt).
Die Verfahren sind Beschreibungen aus Fachwissen; Edition und Lizenzbedarf der Verfahren wurden nicht geprüft."""
def ausfall_pro_jahr(prozent):
    minuten = 365 * 24 * 60 * (1 - prozent / 100)
    return minuten
print(f"{'Verfügbarkeit':>14} {'Ausfall pro Jahr':>18}")
for p in (99.0, 99.9, 99.95, 99.99):
    m = ausfall_pro_jahr(p)
    print(f"{p:>13}% {m/60:>10.1f} h = {m:>7.0f} min")
print()
print("Serielle Abhängigkeit: Gesamtverfügbarkeit = Produkt der Einzelwerte (Annahme: unabhängige Ausfälle)")
for teile in ([99.9, 99.9], [99.9, 99.9, 99.5]):
    g = 1
    for t in teile: g *= t / 100
    print(f"  {' x '.join(str(t)+'%' for t in teile):26} = {g*100:.2f}% -> {ausfall_pro_jahr(g*100)/60:.1f} h/Jahr")
print()
print(f"{'Verfahren':36} {'Wirkung':56} Hinweis")
for v, w, h in [
    ('Sicherung und Wiederherstellung', 'Schutz vor Datenverlust, langer Ausfall', 'Grundlage, ersetzt nichts'),
    ('Log Shipping', 'Sicherungskopie auf zweitem Server, Umschaltung von Hand', 'Verzögerung durch Intervall'),
    ('Failover-Cluster-Instanz', 'Instanz zieht auf anderen Knoten um, gemeinsamer Speicher', 'braucht Windows-Cluster'),
    ('Always On Verfügbarkeitsgruppe', 'Datenbanken werden auf Replikate synchronisiert', 'Edition und Lizenz prüfen'),
]: print(f"{v:36} {w:56} {h}")
