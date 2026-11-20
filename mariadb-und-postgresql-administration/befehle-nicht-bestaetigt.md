# Befehle und Aussagen, die nicht bestätigt sind

Prüfliste für den ersten Durchlauf in den Hyper-V-VMs: Befund und Datum eintragen, danach den Hinweis in der Übung entfernen. Legende: **Q** = gegen Quelle gelesen; **L** = im Labor (Container) ausgeführt; **–** = weder noch.

| Modul | Befehl oder Aussage | Status | Nächster Schritt |
|---|---|---|---|
| alle | Aufbau des Hyper-V-Labors (privater Switch `Lab-DB`, `db01`, `db02`, `client01`), Installation von MariaDB und PostgreSQL aus den Paketquellen | – | laut Lehrplan aufbauen und prüfen |
| 01 | `dpkg-query`, `pg_lsclusters`, `mariadbd`, `pg_createcluster`, `pg_ctlcluster`; Abfragen `select version()`, `show variables` | L (Ubuntu 24.04, MariaDB 10.11.14, PostgreSQL 16.15, ohne systemd) | `systemctl` und Paketpfade auf `db01` prüfen |
| 02 | `mariadbd --max-connections`, `SET GLOBAL`, `ALTER SYSTEM`, `pg_reload_conf()`, `pg_settings`; `konfig_pruefen.py` | L (Container) | Konfigurationsdateien der Pakete auf `db01` verwenden |
| 03 | `CREATE ROLE/USER`, `GRANT`, `SHOW GRANTS`, `\dp`, `pg_roles`, `mysql.global_priv` | L (Container) | Anmeldung von `client01` aus über das Netz prüfen |
| 04 | `ANALYZE/OPTIMIZE/CHECK TABLE`, `VACUUM`, `VACUUM FULL`, `pg_size_pretty`, `information_schema.tables` | L (Container) | Laufzeiten auf `db01` messen |
| 05 | `mariadb-dump --single-transaction`, `pg_dump -Fc`, `pg_restore`, `pg_dumpall --globals-only`, `mariabackup --backup/--prepare/--copy-back`, `pg_basebackup`, `mariadb-binlog`, `recovery_target_name`; `sicherungsplan.py` | L (Container); Plan: Modell mit Annahmen | auf `db01` mit Dienstverwaltung (`systemctl`) und Paketpfaden wiederholen; Sicherung auf eine zweite Platte |
| 06 | `EXPLAIN`, Slow-Query-Log, `EXPLAIN (ANALYZE)`, `pg_stat_statements`, `information_schema.global_status`, `pg_stat_database` | L (Container; Zeitwerte variieren) | auf `db01` mit größeren Datenmengen wiederholen |
| 07 | `ss -ltnp`, `pg_hba_file_rules`, `openssl req -x509`, `--ssl-cert`, `ssl = on`, `hostssl`, `hostnossl` | L (Container, selbstsigniertes Testzertifikat) | Zertifikat einer vertrauenswürdigen Stelle und Prüfung auf dem Client testen |
| 08 | `replikation_modell.py`; `CHANGE MASTER TO ... MASTER_USE_GTID`, `SHOW SLAVE STATUS`, `pg_basebackup -R -C -S`, `pg_stat_replication`, `pg_promote()` | L (zwei Instanzen auf einem Rechner) | auf `db01` und `db02` über das Netz einrichten |
| 09 | `update_planer.py`; `mariadb-upgrade`; `pg_dump -C`, `pg_dumpall --globals-only` | L (nur eine Version je Produkt); `pg_upgrade` – | echten Versionssprung auf einer Kopie testen |
| 10 | `SHOW GLOBAL STATUS`, `information_schema.processlist`, `pg_stat_activity`, `pg_blocking_pids`; `check_datenbank.py` | L (Container); Überwachungssystem – | Plugin in ein Überwachungssystem einbinden |
