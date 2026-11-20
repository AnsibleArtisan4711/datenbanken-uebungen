# SQL Server Administration (P32)

Übungsreihe zur Administration von Microsoft SQL Server: Installation und Editionen, Instanzen und Datenbanken, Anmeldungen und Rechte, Sicherungsmodelle, Wiederherstellung, Wartungspläne, SQL Server Agent, Leistungsanalyse, Hochverfügbarkeit im Überblick sowie Sicherheit. 10 Module, 108 Unterrichtseinheiten zu 45 Minuten, davon 1 Modul mit Priorität 2 (Vertiefung). Die Aufgabentexte und Kontrollfragen stammen aus dem Lehrplan P32 (Reihe „Lehrplan-Prompts“, Datei `P32-sql-server-administration.md`) und sind unverändert; Hinweise, Musterlösungen und Ergänzungen sind Teil der Ausarbeitung und gekennzeichnet.

> **Prüfstand, ehrlich:** **Nur als Python-Modelle im Cloud-Container ausgeführt; kein SQL Server wurde verwendet.** Alle Skripte der Module 1 bis 10 liefen mit Python 3; die Ausgaben stehen in den Ordnern `beispiele/`. Alle Daten sind erfunden. Die `.sql`-Dateien enthalten nicht ausgeführte T-SQL-Beispiele. Bestätigt (Microsoft Learn, Abruf 20.11.2026) sind nur Editionsgrenzen und die Reihenfolge der Wiederherstellung. Offene Punkte: [`befehle-nicht-bestaetigt.md`](befehle-nicht-bestaetigt.md); Anmerkungen zum Lehrplan: [`lehrplan-korrekturen.md`](lehrplan-korrekturen.md).

## Umgebung

Zwei VMs unter **Hyper-V** (Lehrplan): `sql01` (`10.32.0.2`, Windows Server mit SQL Server Developer oder Evaluation) und `win11` (`10.32.0.20`, SSMS) am privaten Switch `Lab-SQL` (`10.32.0.0/24`). Das Labor wurde **nicht** aufgebaut. Die Python-Skripte brauchen nur `python3`.

## Module

| Nr. | Modul | Zeit | Prüfstand |
|---|---|---|---|
| 01 | [Installation und Editionen](01-installation-und-editionen/) | 7,5 h | Modell ausgeführt; kein SQL Server installiert. |
| 02 | [Instanzen, Datenbanken und Dateien](02-instanzen-und-datenbanken/) | 7,5 h | Modell ausgeführt; SQL Server nicht verwendet. |
| 03 | [Anmeldungen, Benutzer und Rechte](03-anmeldungen-und-rechte/) | 9 h | Modell ausgeführt; kein SQL Server. |
| 04 | [Recovery-Modelle und Sicherungsarten](04-sicherungsmodelle/) | 9 h | Modell ausgeführt; kein SQL Server. |
| 05 | [Wiederherstellung planen und üben](05-wiederherstellung/) | 10,5 h | Modell ausgeführt; keine Wiederherstellung durchgeführt. |
| 06 | [Wartungspläne: Prüfen, Indexpflege und Statistiken](06-wartungsplaene/) | 7,5 h | Modell ausgeführt; kein SQL Server. |
| 07 | [SQL Server Agent: Aufträge, Zeitpläne und Benachrichtigungen](07-sql-server-agent/) | 7,5 h | Modell ausgeführt; kein SQL Server. |
| 08 | [Leistungsanalyse: Wartezeiten und Blockierungen](08-leistungsanalyse/) | 9 h | Modell ausgeführt; kein SQL Server. |
| 09 | [Hochverfügbarkeit im Überblick](09-hochverfuegbarkeit-im-ueberblick/) (Priorität 2) | 6 h | Modell ausgeführt; nichts eingerichtet. |
| 10 | [Sicherheit und Härtung](10-sicherheit/) | 7,5 h | Modell ausgeführt; kein SQL Server. |

Summe 81 Stunden.

## Aufbau eines Moduls

Ordner `NN-kurzname/` mit `README.md`, der Übung `NN.1-….md` (Lernziele, Voraussetzungen, Grundbegriffe, Aufgaben, Hinweise, Kontrollfragen, einklappbare Musterlösung, Erweiterungen, Quellen), den Skripten und Beispieldaten des Moduls und einem Ordner `beispiele/` mit den echten Ausgaben der Läufe. Die Skripte der Module liegen im jeweiligen Modulordner.

## Hinweise

- Die Skripte sind reine Python-Modelle und greifen nicht auf SQL Server zu.
- Die `.sql`-Dateien sind **nicht ausgeführt**; vor dem Lauf Pfade anpassen und nur in einer Testinstanz ausführen. `RESTORE ... REPLACE` überschreibt Datenbanken.
- Alle Namen, Konten und Zahlen sind erfunden.

## Lizenz

- Skripte: MIT, siehe [`LICENSE`](LICENSE)
- Texte: CC BY 4.0, siehe [`LICENSE-DOCS.md`](LICENSE-DOCS.md)

*Lizenz: Text CC BY 4.0, Skripte MIT, siehe `LICENSE-DOCS.md` und `LICENSE` im Kursordner. Alle Personen, Firmen, Zahlen und Termine sind frei erfunden. Windows und Windows Server sind Marken der Microsoft Corporation; dieses Dokument steht in keiner Verbindung zu Microsoft.*
