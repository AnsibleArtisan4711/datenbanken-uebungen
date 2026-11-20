# Datenbanken – Übungsreihen

Praxisübungen zu Datenbanken (relational mit PostgreSQL, MariaDB und SQL Server, außerdem Redis und Datensicherung) im isolierten Labor. Jede Reihe liegt in einem eigenen Ordner mit Modulen, Material und Skripten.

## Reihen

| Ordner | Thema | Stand |
|---|---|---|
| [`sql-grundlagen/`](sql-grundlagen/) | SQL-Grundlagen (P30): 12 Module, 90 Stunden | Entwurf, SQL und Serverbefehle in einer Testumgebung (PostgreSQL 16) ausgeführt, Hyper-V, Debian 12 und DBeaver nicht |
| [`sql-server-administration/`](sql-server-administration/) | SQL Server Administration (P32): 10 Module, 108 Unterrichtseinheiten | Entwurf, Python-Modelle im Container ausgeführt, SQL Server und die T-SQL-Beispiele nicht ausgeführt |
| [`mariadb-und-postgresql-administration/`](mariadb-und-postgresql-administration/) | MariaDB und PostgreSQL Administration (P31): 10 Module, 108 Unterrichtseinheiten | Entwurf, Skripte im Container mit MariaDB 10.11.14 und PostgreSQL 16.15 ausgeführt, Hyper-V, systemd, Replikation zwischen zwei VMs, Versionssprung und Dokumentation nicht |
| [`nosql-datenbanken-und-redis/`](nosql-datenbanken-und-redis/) | NoSQL-Datenbanken und Redis (P67): 8 Module, 45 Unterrichtseinheiten | Entwurf, Skripte im Container mit Redis 7.0.15 ausgeführt; MongoDB (Modell), Sentinel, Cluster, TLS und Hyper-V nicht ausgeführt; Lizenz nicht geprüft |
| [`datenbank-backup-und-wiederherstellung/`](datenbank-backup-und-wiederherstellung/) | Datenbank-Backup und Wiederherstellung (P68): 8 Module, 45 Unterrichtseinheiten | Entwurf, Skripte im Container mit PostgreSQL 16, MariaDB 10.11, SQLite, `gzip` und `age` ausgeführt; Offsite, Objektsperre, `cron` und Hyper-V nicht ausgeführt |

## Lizenz

- Skripte: MIT, siehe [`LICENSE`](LICENSE)
- Texte: CC BY 4.0, siehe [`LICENSE-DOCS.md`](LICENSE-DOCS.md)

PostgreSQL ist eine eingetragene Marke der PostgreSQL Community Association of Canada, Microsoft, Windows und Hyper-V sind Marken der Microsoft Corporation, Debian ist eine eingetragene Marke von Software in the Public Interest, Inc. Dieses Repository steht in keiner Verbindung zu den Markeninhabern. Der Teststatus jeder Reihe steht in deren README.
