# 10 Überwachung

Übung **10.1** (Priorität 1). Geschätzte Zeit: 6 bis 8 Stunden (Schätzung; Lehrplan: 10 UE zu 45 Minuten = 7,5 Stunden).

> Skripte im Container ausgeführt.

| Datei | Zweck |
|---|---|
| `10.1-ueberwachung.md` | Die Übung mit Aufgaben, Kontrollfragen und Musterlösung |
| `check_datenbank.py` | Überwachungs-Plugin im Stil von Nagios/Icinga: prüft Erreichbarkeit und Verbindungsauslastung. |
| `lauf.sh` | Testet das Plugin gegen laufende und gestoppte Instanzen. |
| `ueberwachung_mariadb.sh` | MariaDB überwachen: Statusvariablen, laufende Abfragen, Fehlerprotokoll (erfundene Daten). |
| `ueberwachung_postgres.sh` | PostgreSQL überwachen: pg_stat_activity, pg_stat_database, Sperren, Protokoll (erfundene Daten). |
| `beispiele/lauf.ausgabe.txt` | Echte Ausgabe des Laufs von `lauf` |
| `beispiele/ueberwachung_mariadb.ausgabe.txt` | Echte Ausgabe des Laufs von `ueberwachung_mariadb` |
| `beispiele/ueberwachung_postgres.ausgabe.txt` | Echte Ausgabe des Laufs von `ueberwachung_postgres` |
