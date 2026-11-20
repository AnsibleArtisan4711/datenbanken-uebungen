# 08 Replikation

Übung **08.1** (Priorität 2, Vertiefung, kann bei Zeitmangel entfallen). Geschätzte Zeit: 7 bis 9 Stunden (Schätzung; Lehrplan: 12 UE zu 45 Minuten = 9 Stunden).

> Skripte im Container ausgeführt; Replikation zwischen zwei VMs nicht getestet.

| Datei | Zweck |
|---|---|
| `08.1-replikation-in-grundzuegen.md` | Die Übung mit Aufgaben, Kontrollfragen und Musterlösung |
| `lauf.sh` | Skript |
| `repl_mariadb.sh` | MariaDB: Replikation Primär -> Replikat mit GTID (zwei Instanzen auf einem Rechner; erfundene Daten und Kennwörter). |
| `repl_postgres.sh` | PostgreSQL: Streaming-Replikation Primär -> Standby mit pg_basebackup und Replikationsslot (zwei Instanzen auf einem Rechner; erfundene Daten). |
| `replikation_modell.py` | Modell: asynchrone und synchrone Replikation, Verzögerung und Datenverlust bei einem Ausfall des Primärservers. |
| `umschalten.sh` | Umschalten auf das Replikat (Promote) in beiden Systemen. Im Test fällt der Primär durch Beenden des Dienstes aus (erfundene Daten). |
| `beispiele/lauf.ausgabe.txt` | Echte Ausgabe des Laufs von `lauf` |
| `beispiele/repl_mariadb.ausgabe.txt` | Echte Ausgabe des Laufs von `repl_mariadb` |
| `beispiele/repl_postgres.ausgabe.txt` | Echte Ausgabe des Laufs von `repl_postgres` |
| `beispiele/umschalten.ausgabe.txt` | Echte Ausgabe des Laufs von `umschalten` |
