# NoSQL-Datenbanken und Redis (P67)

Übungsreihe zu NoSQL-Datenbanken und Redis: Überblick und Start, Datentypen, Ablaufzeiten und Zwischenspeicher, Persistenz mit RDB und AOF, Replikation, Absicherung, Dokumentenmodell als Vergleich sowie Transaktionen, Speicher und Betrieb. 8 Module, 45 Unterrichtseinheiten zu 45 Minuten, davon 1 Modul mit Priorität 2 (Vertiefung). Praxisübungen mit echten Läufen gegen Redis 7.0.15; MongoDB wird nicht ausgeführt. Die Aufgabentexte und Kontrollfragen stammen aus dem Lehrplan P67 (Reihe „Lehrplan-Prompts“, Datei `P67-nosql-datenbanken-und-redis.md`) und sind unverändert; Hinweise, Musterlösungen und Ergänzungen sind Teil der Ausarbeitung und gekennzeichnet.

> **Prüfstand, ehrlich:** **Im Cloud-Container ausgeführt, nicht in Hyper-V.** Die Skripte liefen mit Redis 7.0.15, Python 3 und Bash unter Ubuntu 24.04 auf `127.0.0.1`; die Ausgaben stehen in den Ordnern `beispiele/`. Alle Daten sind erfunden. **MongoDB, Sentinel, Cluster und TLS wurden nicht ausgeführt**; Modul 7 ist ein Python-Modell, `mongodb_beispiel.txt` nicht bestätigt. Offene Punkte: [`befehle-nicht-bestaetigt.md`](befehle-nicht-bestaetigt.md); Anmerkungen zum Lehrplan: [`lehrplan-korrekturen.md`](lehrplan-korrekturen.md).

## Umgebung

Zwei Linux-VMs unter **Hyper-V** (Lehrplan): `redis01` (`10.67.0.2`) und `redis02` (`10.67.0.3`) am privaten Switch `Lab-NoSQL` (`10.67.0.0/24`); optional `mongo01`. Das Labor wurde **nicht** aufgebaut. Die Skripte starten Redis selbst auf `127.0.0.1` (Ports 6399 und 6400).

## Module

| Nr. | Modul | Zeit | Prüfstand |
|---|---|---|---|
| 01 | [NoSQL-Überblick und Redis-Start](01-nosql-ueberblick-und-redis-start/) | 3,75 h | Skript im Container ausgeführt. |
| 02 | [Redis-Datentypen](02-redis-datentypen/) | 4,5 h | Skript im Container ausgeführt. |
| 03 | [Ablaufzeiten und Zwischenspeicher](03-ablaufzeiten-und-zwischenspeicher/) | 3,75 h | Skript im Container ausgeführt. |
| 04 | [Persistenz mit RDB und AOF](04-persistenz-rdb-und-aof/) | 4,5 h | Skript im Container ausgeführt. |
| 05 | [Replikation](05-replikation/) | 4,5 h | Skript im Container ausgeführt. |
| 06 | [Absicherung von Redis](06-absicherung-von-redis/) | 4,5 h | Skript im Container ausgeführt. |
| 07 | [Dokumentenmodell (Vergleich)](07-dokumentenmodell/) (Priorität 2) | 3,75 h | Modell ausgeführt; MongoDB nicht ausgeführt. |
| 08 | [Transaktionen, Speicher und Betrieb](08-transaktionen-speicher-und-betrieb/) | 4,5 h | Skript im Container ausgeführt. |

Summe 33,75 Stunden.

## Aufbau eines Moduls

Ordner `NN-kurzname/` mit `README.md`, der Übung `NN.1-….md` (Lernziele, Voraussetzungen, Grundbegriffe, Aufgaben, Hinweise, Kontrollfragen, einklappbare Musterlösung, Erweiterungen, Quellen), den Skripten und Beispieldaten des Moduls und einem Ordner `beispiele/` mit den echten Ausgaben der Läufe. Die Skripte der Module liegen im jeweiligen Modulordner und binden `../lab.sh` ein.

## Hinweise

- Die Skripte starten kurzzeitig Redis auf `127.0.0.1` (Ports 6399 und 6400) und beenden es am Ende. **Nicht ausführen, wenn diese Ports belegt sind.**
- Alle Kennwörter sind erfunden; verwenden Sie in Übungen nie echte Kennwörter.
- Die Datei `mongodb_beispiel.txt` wurde nicht ausgeführt.

## Lizenz

- Skripte: MIT, siehe [`LICENSE`](LICENSE)
- Texte: CC BY 4.0, siehe [`LICENSE-DOCS.md`](LICENSE-DOCS.md)

*Lizenz: Text CC BY 4.0, Skripte MIT, siehe `LICENSE-DOCS.md` und `LICENSE` im Kursordner. Alle Personen, Firmen, Zahlen und Termine sind frei erfunden. Windows und Windows Server sind Marken der Microsoft Corporation; dieses Dokument steht in keiner Verbindung zu Microsoft.*
