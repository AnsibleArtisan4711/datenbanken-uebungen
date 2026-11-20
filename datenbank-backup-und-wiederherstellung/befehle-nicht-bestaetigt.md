# Befehle und Aussagen, die nicht bestätigt sind

Prüfliste für den ersten Durchlauf in den Hyper-V-VMs: Befund und Datum eintragen, danach den Hinweis in der Übung entfernen. Legende: **Q** = gegen Quelle gelesen; **L** = im Labor (Container) ausgeführt; **–** = weder noch.

| Modul | Befehl oder Aussage | Status | Nächster Schritt |
|---|---|---|---|
| alle | Aufbau des Hyper-V-Labors (privater Switch `Lab-DBBackup`, `db01`, `db02`), Installation von PostgreSQL und MariaDB | – | laut Lehrplan aufbauen und prüfen |
| 01 | Rechnung in Python (RPO, RTO, Dauer, Protokollmenge) | Modell | mit eigenen Anforderungen wiederholen |
| 02 | `pg_dump -Fc/-Fd/-Ft`, `pg_restore -l/-t`, `--schema-only`, `--data-only`, `mariadb-dump --no-data --where --single-transaction` | L (PostgreSQL 16, MariaDB 10.11) | auf `db01` wiederholen |
| 03 | `.backup`, `VACUUM INTO`, `PRAGMA integrity_check`, `sha256sum` | L (sqlite3) | auf `db01` wiederholen |
| 04 | `pg_restore` in Testinstanz, Zeilenprüfsumme, abgeschnittener Dump | L | auf `db01` und `db02` wiederholen |
| 05 | `gzip`, `age -r`, `age -d`, Aufbewahrungsmodell 7/4/3 | L (age 1.1.1); Aufbewahrung: Modell | auf `db01` wiederholen; `zstd` nicht verfügbar |
| 06 | `flock`, Rückgabecodes, `.tmp` und Umbenennen, `sha256sum -c`; `cron`-Zeile | L; `cron`: Text | auf `db01` wiederholen; `cron` im Labor einrichten |
| 07 | 3-2-1-Prüfung (Python), `chmod 444` | Modell; Offsite und Objektsperre: nicht ausgeführt | mit einem echten Offsite-Ziel prüfen |
| 08 | Sicherung, `INSERT`, `DROP DATABASE`, `pg_restore`, Zeitmessung | L | auf `db01` wiederholen |
