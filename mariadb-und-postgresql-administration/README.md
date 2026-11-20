# MariaDB und PostgreSQL Administration (P31)

Übungsreihe zur Administration von MariaDB und PostgreSQL unter Debian/Ubuntu: Installation und Aufbau, Konfiguration, Benutzer und Rechte, Speicher und Wartung, Sicherung und Wiederherstellung (logisch, physisch, bis zu einem Zeitpunkt), Leistungsanalyse, Sicherheit mit TLS, Replikation in Grundzügen, Updates sowie Überwachung. 10 Module, 108 Unterrichtseinheiten zu 45 Minuten, davon 1 Modul mit Priorität 2 (Vertiefung). Die Aufgabentexte und Kontrollfragen stammen aus dem Lehrplan P31 (Reihe „Lehrplan-Prompts“, Datei `P31-mariadb-und-postgresql-administration.md`) und sind unverändert; Hinweise, Musterlösungen und Ergänzungen sind Teil der Ausarbeitung und gekennzeichnet.

> **Prüfstand, ehrlich:** **Im Cloud-Container ausgeführt (Ubuntu 24.04, ohne systemd), nicht in Hyper-V.** Alle Skripte der Module 1 bis 10 liefen mit MariaDB 10.11.14, PostgreSQL 16.15 und Python 3 mit echten Instanzen; die Ausgaben stehen in den Ordnern `beispiele/`. Alle Daten sind erfunden. Bestätigt wurde das Verhalten der Programme in diesem Lauf, **nicht** gegen die Dokumentation; ein Versionssprung (Modul 9) und die Replikation zwischen zwei VMs (Modul 8) wurden nicht getestet. Offene Punkte: [`befehle-nicht-bestaetigt.md`](befehle-nicht-bestaetigt.md); Anmerkungen zum Lehrplan: [`lehrplan-korrekturen.md`](lehrplan-korrekturen.md).

## Umgebung

Drei VMs unter **Hyper-V** (Lehrplan): `db01` (`10.31.0.2`, Debian/Ubuntu mit MariaDB und PostgreSQL), `db02` (`10.31.0.3`, Replikat) und `client01` (`10.31.0.20`) am privaten Switch `Lab-DB` (`10.31.0.0/24`). Das Labor wurde **nicht** aufgebaut. Die Skripte starten stattdessen eigene Instanzen unter `/tmp/p31` (Ports 3311/3312 und 5441/5442) und brauchen `root`.

## Module

| Nr. | Modul | Zeit | Prüfstand |
|---|---|---|---|
| 01 | [Installation und Aufbau](01-installation-und-aufbau/) | 7,5 h | Skripte im Container ausgeführt. |
| 02 | [Konfiguration](02-konfiguration/) | 7,5 h | Skripte im Container ausgeführt. |
| 03 | [Benutzer und Rechte](03-benutzer-und-rechte/) | 9 h | Skripte im Container ausgeführt. |
| 04 | [Speicher und Wartung](04-speicher-und-wartung/) | 7,5 h | Skripte im Container ausgeführt. |
| 05 | [Sicherung und Wiederherstellung](05-sicherung-und-wiederherstellung/) | 10,5 h | Skripte im Container ausgeführt. |
| 06 | [Leistungsanalyse](06-leistungsanalyse/) | 7,5 h | Skripte im Container ausgeführt. |
| 07 | [Sicherheit: Zugriffskontrolle und TLS](07-sicherheit/) | 9 h | Skripte im Container ausgeführt. |
| 08 | [Replikation in Grundzügen](08-replikation-in-grundzuegen/) (Priorität 2) | 9 h | Skripte im Container ausgeführt; Replikation zwischen zwei VMs nicht getestet. |
| 09 | [Updates](09-updates/) | 6 h | Skripte im Container ausgeführt; kein Versionswechsel getestet. |
| 10 | [Überwachung](10-ueberwachung/) | 7,5 h | Skripte im Container ausgeführt. |

Summe 81 Stunden.

## Aufbau eines Moduls

Ordner `NN-kurzname/` mit `README.md`, der Übung `NN.1-….md` (Lernziele, Voraussetzungen, Grundbegriffe, Aufgaben, Hinweise, Kontrollfragen, einklappbare Musterlösung, Erweiterungen, Quellen), den Skripten und Beispieldaten des Moduls und einem Ordner `beispiele/` mit den echten Ausgaben der Läufe. Die Skripte der Module liegen im jeweiligen Modulordner und binden `../lab.sh` ein.

## Hinweise

- Die Skripte starten eigene MariaDB-Instanzen und PostgreSQL-Cluster (`pg_createcluster`, Namen außer `main`) und entfernen sie am Ende (`lab_down`). **Nicht auf einem Rechner mit produktiven Datenbanken ausführen**: `lab_down` löscht alle PostgreSQL-Cluster außer `main` der Version 16.
- Alle Namen, Adressen (`10.31.0.0/24`), Konten und Kennwörter sind erfunden; die Kennwörter (`Test-…-12345`) sind Testwerte im Klartext. **Niemals für echte Konten verwenden.**
- Das TLS-Zertifikat in Modul 7 ist selbstsigniert und nur für Tests.
- Die Skripte schreiben nur unter `/tmp/p31` und in `/etc/postgresql/16/<Cluster>/conf.d` des Testclusters.

## Lizenz

- Skripte: MIT, siehe [`LICENSE`](LICENSE)
- Texte: CC BY 4.0, siehe [`LICENSE-DOCS.md`](LICENSE-DOCS.md)

*Lizenz: Text CC BY 4.0, Skripte MIT, siehe `LICENSE-DOCS.md` und `LICENSE` im Kursordner. Alle Personen, Firmen, Zahlen und Termine sind frei erfunden. Windows und Windows Server sind Marken der Microsoft Corporation; dieses Dokument steht in keiner Verbindung zu Microsoft.*
