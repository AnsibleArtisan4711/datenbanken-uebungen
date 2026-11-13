# Befehle und Aussagen, die nicht bestätigt sind

Prüfliste für den ersten Durchlauf in den Hyper-V-VMs: Befund und Datum eintragen, danach den Hinweis in der Übung entfernen. Legende: **Q** = gegen Quelle gelesen; **L** = in der Testumgebung (Namespaces, PostgreSQL 16) ausgeführt; **–** = weder noch.

| Modul | Befehl oder Aussage | Status | Nächster Schritt |
|---|---|---|---|
| alle | Aufbau des Hyper-V-Labors, Installation von Debian 12 und Windows 11, Switch `DB-Lab`, Prüfpunkte, Umstellung des Switch nach Modul 2 | – | laut Lehrplan aufbauen und prüfen |
| alle | Alle Befehle mit **PostgreSQL 15** unter Debian 12 (getestet wurde PostgreSQL 16.15 unter Ubuntu 24.04) | L (nur Version 16) | auf Debian 12 wiederholen; Abweichungen eintragen |
| alle | DBeaver (Installation, Treiber-Manager, Verbindungsdialog, SQL-Editor, Auto-Commit, Transaktionsmodus, zweiter Editor-Tab) | – (statt dessen `psql`) | in `db-client` ausführen; Menünamen im Lehrplan nachtragen |
| 01 | Zerlegung der Flat-File in die drei Tabellen (Verlustfreiheit, Anomalien) | L (`normalisierung-test.sql`) | – |
| 01 | Normalformen, ER-Modell, Kardinalität (Fachwissen); Mermaid-Diagramm (Syntax mit mmdc geprüft, nicht auf GitHub dargestellt) | – (Fachwissen) | gegen Quelle prüfen |
| 02 | `sudo apt update && sudo apt install -y postgresql`; Version unter Debian 12 (laut Lehrplan 15) | – | auf Debian 12 ausführen |
| 02 | `/etc/network/interfaces` mit `iface eth0 inet static`, Adaptername `eth0`, `systemctl restart networking` | – | auf Debian 12 ausführen |
| 02 | `listen_addresses`, `pg_hba.conf`-Zeile, Neustart, `ss -tln`, Rolle, Datenbank, Verbindung mit `psql`, Fehlermeldungen | L (PostgreSQL 16, `pg_ctlcluster` statt `systemctl`) | mit `systemctl` auf Debian 12 wiederholen |
| 02 | `\password labuser` (interaktiv) | – (im Test `ALTER ROLE … PASSWORD`) | in der VM ausführen |
| 03 | `CREATE`, `ALTER`, `DROP`, Constraints, Fehlermeldungen | L | wiederholen |
| 04 | `INSERT … RETURNING`, `UPDATE`, `DELETE`, Fremdschlüssel-Fehler | L | wiederholen |
| 05, 06 | `SELECT`, `LIKE`/`ILIKE`, `ORDER BY`/`LIMIT`/`OFFSET`, Funktionen, Aggregation, Fehlermeldungen | L | wiederholen; Sortierung bei anderer Collation prüfen |
| 07, 08 | Joins, Unterabfragen, CTE, `NOT IN` mit `NULL` | L | wiederholen |
| 09 | View, Materialized View, `REFRESH`, `DROP`, Abhängigkeiten, Rechte (`GRANT SELECT` auf View) | L | wiederholen |
| 10 | 100 000 Testzeilen, `EXPLAIN ANALYZE` (Seq Scan, Bitmap Index Scan), Index, Größen; Zeiten | L (Zeiten und Pläne rechnerabhängig) | auf der VM wiederholen; Plan und Zeiten eintragen |
| 11 | `BEGIN`/`COMMIT`/`ROLLBACK`, Sicherung, `OVERRIDING SYSTEM VALUE`, Sperren und Deadlock mit drei `psql`-Sitzungen | L (Zeiten per `pg_sleep` gesteuert) | mit zwei Editor-Tabs in DBeaver prüfen |
| 12 | `pg_dump` (Plain und `-Fc`), `pg_restore -l`/`-d`, `createdb`, `dropdb`, Log-Zeilen, `pg_hba.conf`-Fehler | L (16.15) | auf Debian 12 wiederholen |
| 12 | `/var/log/postgresql/postgresql-15-main.log`, `systemctl reload postgresql`, Benutzer `labadmin` mit `sudo` | – | auf Debian 12 prüfen |
