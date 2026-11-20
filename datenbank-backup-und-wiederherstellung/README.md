# Datenbank-Backup und Wiederherstellung (P68)

Übungsreihe zu Datenbank-Backup und Wiederherstellung: Sicherungskonzept, logische Sicherung mit `pg_dump` und `mariadb-dump`, SQLite, Wiederherstellungstest, Komprimierung, Verschlüsselung und Aufbewahrung, Sicherungsskript, Offsite-Kopien sowie Abschlussprojekt mit gemessenem Datenverlust. 8 Module, 45 Unterrichtseinheiten zu 45 Minuten, davon 1 Modul mit Priorität 2 (Vertiefung). Praxisübungen mit echten Läufen gegen PostgreSQL 16, MariaDB 10.11 und SQLite. Die Aufgabentexte und Kontrollfragen stammen aus dem Lehrplan P68 (Reihe „Lehrplan-Prompts“, Datei `P68-datenbank-backup-und-wiederherstellung.md`) und sind unverändert; Hinweise, Musterlösungen und Ergänzungen sind Teil der Ausarbeitung und gekennzeichnet.

> **Prüfstand, ehrlich:** **Im Cloud-Container ausgeführt, nicht in Hyper-V.** Die Skripte liefen mit PostgreSQL 16, MariaDB 10.11, SQLite, `gzip`, `age` 1.1.1 und Bash unter Ubuntu 24.04; die Ausgaben stehen in den Ordnern `beispiele/`. Alle Daten sind erfunden. **Offsite-Speicher, Objektsperre und `cron` wurden nicht ausgeführt**; Modul 7 ist ein Modell. Offene Punkte: [`befehle-nicht-bestaetigt.md`](befehle-nicht-bestaetigt.md); Anmerkungen zum Lehrplan: [`lehrplan-korrekturen.md`](lehrplan-korrekturen.md).

## Umgebung

Zwei Linux-VMs unter **Hyper-V** (Lehrplan): `db01` (`10.68.0.2`) und `db02` (`10.68.0.3`) am privaten Switch `Lab-DBBackup` (`10.68.0.0/24`); optional `sicherung01`. Das Labor wurde **nicht** aufgebaut. Die Skripte legen eigene Instanzen unter `/tmp/p68` an (Ports 5481, 5482, 3381, 3382).

## Module

| Nr. | Modul | Zeit | Prüfstand |
|---|---|---|---|
| 01 | [Sicherungskonzept: RPO und RTO](01-sicherungskonzept-rpo-und-rto/) | 3,75 h | Skript im Container ausgeführt (reine Rechnung). |
| 02 | [Logische Sicherung mit pg_dump und mariadb-dump](02-logische-sicherung/) | 4,5 h | Skript im Container ausgeführt. |
| 03 | [SQLite sichern](03-sqlite-sichern/) | 4,5 h | Skript im Container ausgeführt. |
| 04 | [Wiederherstellungstest](04-wiederherstellungstest/) | 3,75 h | Skript im Container ausgeführt. |
| 05 | [Komprimierung, Verschlüsselung und Aufbewahrung](05-komprimierung-verschluesselung-aufbewahrung/) | 4,5 h | Skript im Container ausgeführt. |
| 06 | [Sicherungsskript](06-sicherungsskript/) | 4,5 h | Skript im Container ausgeführt; `cron` nicht ausgeführt. |
| 07 | [Offsite-Kopien und 3-2-1-Regel](07-offsite-und-3-2-1-regel/) (Priorität 2) | 3,75 h | Modell ausgeführt; Offsite nicht ausgeführt. |
| 08 | [Abschlussprojekt: Datenverlust messen](08-abschlussprojekt-datenverlust-messen/) | 4,5 h | Skript im Container ausgeführt. |

Summe 33,75 Stunden.

## Aufbau eines Moduls

Ordner `NN-kurzname/` mit `README.md`, der Übung `NN.1-….md` (Lernziele, Voraussetzungen, Grundbegriffe, Aufgaben, Hinweise, Kontrollfragen, einklappbare Musterlösung, Erweiterungen, Quellen), den Skripten und Beispieldaten des Moduls und einem Ordner `beispiele/` mit den echten Ausgaben der Läufe. Die Skripte der Module liegen im jeweiligen Modulordner und binden `../lab.sh` ein.

## Hinweise

- Die Skripte legen eigene PostgreSQL- und MariaDB-Instanzen unter `/tmp/p68` an und löschen sie am Ende. **Nur auf einem Testrechner ausführen; nicht, wenn die Ports 5481, 5482, 3381 oder 3382 belegt sind.**
- Das Abschlussprojekt löscht eine Datenbank der Testinstanz; niemals gegen eine Produktivinstanz ausführen.
- Alle Schlüssel sind Testschlüssel und erfunden.

## Lizenz

- Skripte: MIT, siehe [`LICENSE`](LICENSE)
- Texte: CC BY 4.0, siehe [`LICENSE-DOCS.md`](LICENSE-DOCS.md)

*Lizenz: Text CC BY 4.0, Skripte MIT, siehe `LICENSE-DOCS.md` und `LICENSE` im Kursordner. Alle Personen, Firmen, Zahlen und Termine sind frei erfunden. Windows und Windows Server sind Marken der Microsoft Corporation; dieses Dokument steht in keiner Verbindung zu Microsoft.*
