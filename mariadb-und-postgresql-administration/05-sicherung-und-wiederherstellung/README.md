# 05 Sicherung

Übung **05.1** (Priorität 1). Geschätzte Zeit: 8 bis 11 Stunden (Schätzung; Lehrplan: 14 UE zu 45 Minuten = 10,5 Stunden).

> Skripte im Container ausgeführt.

| Datei | Zweck |
|---|---|
| `05.1-sicherung-und-wiederherstellung.md` | Die Übung mit Aufgaben, Kontrollfragen und Musterlösung |
| `lauf.sh` | Skript |
| `pitr_mariadb.sh` | MariaDB: Wiederherstellung bis kurz vor einem Fehler (Point-in-Time) mit Sicherung + Binärprotokoll (erfundene Daten). |
| `pitr_postgres.sh` | PostgreSQL: Wiederherstellung bis zu einem benannten Zeitpunkt (PITR) mit Basissicherung + WAL-Archiv (erfundene Daten). |
| `sicherung_logisch.sh` | Logische Sicherung und Wiederherstellung: mariadb-dump und pg_dump/pg_restore (erfundene Daten). |
| `sicherung_physisch.sh` | Physische Sicherung: mariabackup und pg_basebackup (erfundene Daten). |
| `sicherungsplan.py` | Modell: Datenverlust (RPO) und Wiederherstellungsdauer (RTO) verschiedener Sicherungsvarianten. |
| `beispiele/lauf.ausgabe.txt` | Echte Ausgabe des Laufs von `lauf` |
| `beispiele/pitr_mariadb.ausgabe.txt` | Echte Ausgabe des Laufs von `pitr_mariadb` |
| `beispiele/pitr_postgres.ausgabe.txt` | Echte Ausgabe des Laufs von `pitr_postgres` |
| `beispiele/sicherung_logisch.ausgabe.txt` | Echte Ausgabe des Laufs von `sicherung_logisch` |
| `beispiele/sicherung_physisch.ausgabe.txt` | Echte Ausgabe des Laufs von `sicherung_physisch` |
