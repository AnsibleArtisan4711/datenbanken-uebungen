# SQL-Grundlagen (P30)

Übungsreihe zu relationalen Modellen und Normalisierung, Installation und Absicherung von PostgreSQL, Tabellen und Schlüsseln (DDL), Daten ändern (DML), Abfragen mit `SELECT`, Funktionen und Aggregation, Joins, Unterabfragen und CTEs, Sichten, Indizes mit `EXPLAIN`, Transaktionen und Sperren sowie Backup, Restore und Log-Analyse. Zwölf Module, 120 Unterrichtseinheiten zu 45 Minuten, davon 2 Module mit Priorität 2 (Vertiefung). Die Aufgabentexte und Kontrollfragen stammen aus dem Lehrplan P30 (Reihe „Lehrplan-Prompts“) und sind unverändert; Hinweise, Musterlösungen und Ergänzungen sind Teil der Ausarbeitung und gekennzeichnet.

> **Prüfstand, ehrlich:** **Teilweise in einer Testumgebung ausgeführt, nicht unter Hyper-V, nicht auf Debian 12 mit PostgreSQL 15 und nicht mit DBeaver.** Alle SQL-Befehle der Module 3 bis 11, die Serverkonfiguration (`listen_addresses`, `pg_hba.conf`) und die Sicherungs- und Log-Befehle (Modul 12) wurden in einem Cloud-Container (Ubuntu 24.04, PostgreSQL 16.15, Locale `de_AT.UTF-8`, zwei Netzwerk-Namespaces) mit `psql` ausgeführt; die Nebenläufigkeit (Modul 11) mit drei `psql`-Sitzungen. **Nicht geprüft:** Hyper-V und die VM-Installation, Windows 11, DBeaver (Treiber-Manager, Auto-Commit, Editor-Tabs), `systemctl`, `/etc/network/interfaces`, die Pfade von Debian 12 mit PostgreSQL 15. Modul 1 ist eine Fallstudie (die Zerlegung wurde in PostgreSQL gegengeprüft). Die Rechnung und die Flat-File in Modul 1 sind Material der Ausarbeitung. Die Ausgaben im Ordner `beispiele/` der Module stammen aus der Testumgebung. Offene Punkte: [`befehle-nicht-bestaetigt.md`](befehle-nicht-bestaetigt.md); Anmerkungen zum Lehrplan: [`lehrplan-korrekturen.md`](lehrplan-korrekturen.md).

## Umgebung

Zwei VMs unter **Hyper-V** (Lehrplan): `db-server` (Debian 12, minimale Installation, `192.168.100.10`, PostgreSQL 15, Benutzer `labadmin` mit `sudo`) und `db-client` (Windows 11 Enterprise Evaluation oder Debian mit Desktop, `192.168.100.20`, DBeaver Community) am privaten Switch `DB-Lab` (`192.168.100.0/24`, statisch, ohne Gateway, kein DNS). Bis zur Internetphase in Modul 2 hängen beide VMs am `Default Switch`; die Installation beider Betriebssysteme ist nicht Teil der Unterrichtseinheiten. Das Labor wurde **nicht** aufgebaut; getestet wurde in Namespaces (siehe `testlabor30.sh`).

## Module

| Nr. | Modul | Zeit | Prüfstand |
|---|---|---|---|
| 01 | [Relationale Modelle & Normalisierung](01-relationale-modelle-und-normalisierung/) | 7,5 h | Entwurf, Fallstudie; Zerlegung der Flat-File in PostgreSQL 16 gegengeprüft |
| 02 | [Installation & Labor-Aufbau (PostgreSQL)](02-installation-und-labor-aufbau/) | 7,5 h | Entwurf, Linux-Teile mit PostgreSQL 16 in Testumgebung ausgeführt; Installation, Hyper-V und DBeaver nicht |
| 03 | [DDL - Tabellen, Datentypen und Schlüssel](03-ddl-tabellen-datentypen-schluessel/) | 7,5 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver) |
| 04 | [DML - INSERT, UPDATE, DELETE](04-dml-insert-update-delete/) | 6 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver) |
| 05 | [DQL - Grundlagen der Datenabfrage (SELECT)](05-dql-select-grundlagen/) | 7,5 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver) |
| 06 | [Funktionen & Aggregation](06-funktionen-und-aggregation/) | 7,5 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver) |
| 07 | [Joins (Verknüpfungen)](07-joins/) | 9 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver) |
| 08 | [Unterabfragen (Subqueries) & CTEs](08-unterabfragen-und-ctes/) (Priorität 2) | 7,5 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver) |
| 09 | [Sichten (Views)](09-sichten-views/) (Priorität 2) | 7,5 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver) |
| 10 | [Indizes und Performance-Grundlagen](10-indizes-und-performance/) | 7,5 h | Entwurf, SQL in Testumgebung ausgeführt (psql statt DBeaver); Zeiten und Pläne rechnerabhängig |
| 11 | [Transaktionen (ACID) & Sperren](11-transaktionen-und-sperren/) | 7,5 h | Entwurf, SQL und Nebenläufigkeit in Testumgebung ausgeführt (psql statt DBeaver) |
| 12 | [Troubleshooting, Diagnose & Backup](12-troubleshooting-diagnose-und-backup/) | 7,5 h | Entwurf, Befehle in Testumgebung ausgeführt (PostgreSQL 16, Ubuntu); Debian 12 mit PostgreSQL 15 nicht |

Summe 90 Stunden.

## Datenmodell und Zustand der Datenbank

Die Datenbank `firma` (Eigentümer `labuser`) enthält ab Modul 3 die Tabellen `abteilung` (`abteilung_id`, `name`, `standort`), `mitarbeiter` (`mitarbeiter_id`, `vorname`, `nachname`, `email`, `gehalt`, `abteilung_id`, `einstellungsdatum`) und `projekt` (`projekt_id`, `bezeichnung`, `startdatum`, `abteilung_id`). **Die Module bauen aufeinander auf:**

| Nach Modul | Zustand |
|---|---|
| 3 | Struktur mit Primär- und Fremdschlüsseln, `UNIQUE` auf `email`; Datei `01_struktur.sql` |
| 4 | 3 Abteilungen, 5 Mitarbeiter (u. a. Müller, Maier, Huber in Technik; Berger ohne E-Mail), 2 Projekte; Datei `02_daten.sql`; Müllers Gehalt um 5 % erhöht |
| 7 | zusätzlich Mitarbeiter Neumann ohne Abteilung und Abteilung Archiv ohne Mitarbeiter |
| 9 | zusätzlich `vw_mitarbeiterliste` und `mv_abteilung_statistik` |
| 10 | Testzeilen und Index wieder entfernt; die Identity-Folge läuft weiter |
| 11 | zusätzlich Mitarbeiterin Wagner; `mitarbeiter_sicherung` wieder gelöscht |

Wer ein Modul überspringt, stellt den Zustand mit den Skripten und den Befehlen der Musterlösungen her.

## Aufbau eines Moduls

Ordner `NN-kurzname/` mit `README.md`, der Übung `NN.1-….md` (Lernziele, Voraussetzungen, Grundbegriffe, Aufgaben, Hinweise, Kontrollfragen, einklappbare Musterlösung, Erweiterungen, Quellen), ggf. Skripten und Material und einem Ordner `beispiele/` mit Ausgaben der Testumgebung. Das Hilfsskript [`testlabor30.sh`](testlabor30.sh) baut `db-server` und `db-client` ohne Hyper-V in zwei Netzwerk-Namespaces nach; es ist nicht Teil des Lehrplans.

## Hinweise

- Nur im Labor ausführen. Kennwörter gehören nie in ein Repository; das Kennwort in den Beispielen (`LabKennwort1`) ist ein Laborwert.
- `DELETE`, `UPDATE` ohne `WHERE`, `DROP` und der Restore in eine bestehende Datenbank verändern oder zerstören Daten: vorher Bestand prüfen, Namen kontrollieren, im Zweifel eine Transaktion oder eine Sicherung verwenden.
- Alle Namen, E-Mail-Adressen (`example.com`) und Adressen sind frei erfunden (Adressen nach RFC 1918).
- Aussagen zu Normalformen, Isolation und Planer sind Fachwissen bzw. Testergebnisse mit PostgreSQL 16.15; auf PostgreSQL 15 können Pläne, Zeiten und Meldungen abweichen.

## Lizenz

- Skripte: MIT, siehe [`LICENSE`](LICENSE)
- Texte: CC BY 4.0, siehe [`LICENSE-DOCS.md`](LICENSE-DOCS.md)
