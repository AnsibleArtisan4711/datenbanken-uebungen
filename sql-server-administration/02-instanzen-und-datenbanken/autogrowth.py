#!/usr/bin/env python3
"""Autogrowth-Einstellung vergleichen: Wachstum in Prozent gegen feste Größe (Modell, erfundene Zahlen).
Zeigt, wie oft eine Datei wächst und wie groß die einzelnen Schritte werden."""
def schritte(start_mb, ziel_mb, prozent=None, fest_mb=None):
    mb, ereignisse = start_mb, []
    while mb < ziel_mb:
        add = mb * prozent / 100 if prozent else fest_mb
        mb += add; ereignisse.append(add)
    return ereignisse

START, ZIEL = 100, 100_000   # MB: von 100 MB auf rund 100 GB
for name, kw in (('10 %', dict(prozent=10)), ('256 MB fest', dict(fest_mb=256)), ('1024 MB fest', dict(fest_mb=1024))):
    e = schritte(START, ZIEL, **kw)
    print(f"Wachstum {name:12}: {len(e):>4} Vergrößerungen von {START} MB auf {ZIEL} MB; kleinster Schritt {min(e):.0f} MB, größter {max(e):.0f} MB")
print()
print("Bewertung (Fachwissen, nicht bestätigt): Viele kleine Schritte bedeuten viele Wartezeiten bei Schreibvorgängen und Fragmentierung;")
print("Prozentwachstum führt bei großen Dateien zu sehr großen Schritten. Eine feste, vernünftig gewählte Größe und regelmäßiges Vorab-Vergrößern sind üblich.")
print("Hinweis: Das Modell kennt weder Sofort-Initialisierung noch Protokolldateien (dort wirkt das Wachstum anders).")
