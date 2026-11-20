# Befehle und Aussagen, die nicht bestätigt sind

Prüfliste für den ersten Durchlauf in den Hyper-V-VMs: Befund und Datum eintragen, danach den Hinweis in der Übung entfernen. Legende: **Q** = gegen Quelle gelesen; **L** = im Labor (Container) ausgeführt; **–** = weder noch.

| Modul | Befehl oder Aussage | Status | Nächster Schritt |
|---|---|---|---|
| alle | Aufbau des Hyper-V-Labors (privater Switch `Lab-SQL`, `sql01`, `win11`), Installation von SQL Server | – | laut Lehrplan aufbauen und prüfen |
| 01 | `editionen.py` (Werte aus Microsoft Learn, Abruf 20.11.2026); `SERVERPROPERTY`, `@@VERSION` | L (Python-Modell); T-SQL – | Werte gegen aktuelle Seite prüfen; Abfrage in SSMS ausführen |
| 02 | `autogrowth.py`; `CREATE DATABASE` | L (Modell); T-SQL – | Datenbank auf `sql01` anlegen |
| 03 | `rechte_pruefen.py`; `CREATE LOGIN`, `CREATE USER`, `ALTER ROLE` | L (Textprüfung); T-SQL – | auf `sql01` ausführen |
| 04 | `recovery_modelle.py`; `BACKUP DATABASE/LOG`, `RESTORE VERIFYONLY` | L (Modell); T-SQL – | Sicherungen auf `sql01` anlegen |
| 05 | `restore_plan.py`; `RESTORE DATABASE/LOG ... STOPAT` | L (Modell); T-SQL – | Wiederherstellung auf `sql01` üben |
| 06 | `wartungsfenster.py`; `DBCC CHECKDB`, `ALTER INDEX`, `UPDATE STATISTICS` | L (Modell); T-SQL – | auf `sql01` ausführen und Laufzeiten messen |
| 07 | `agent_jobs.py`; `sp_add_job` u. a. in `msdb` | L (Modell); T-SQL – | Auftrag auf `sql01` anlegen |
| 08 | `wartezeiten.py` (erfundene Daten); `sys.dm_os_wait_stats`, `sys.dm_exec_requests` | L (Modell); T-SQL – | Abfragen auf `sql01` prüfen |
| 09 | `verfuegbarkeit.py` | L (Python-Modell) | Verfahren in der Dokumentation prüfen |
| 10 | `sicherheit_pruefen.py`; `ALTER LOGIN sa DISABLE` | L (Modell); T-SQL – | auf `sql01` ausführen |
