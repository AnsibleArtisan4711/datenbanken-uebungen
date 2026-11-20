# Anmerkungen zum Lehrplan P31

Beim Ausarbeiten und Testen aufgefallene Punkte. Der Lehrplan selbst wurde zusammen mit der Übungsreihe erstellt und danach **nicht** verändert.

| Nr. | Modul | Befund | Vorschlag |
|---|---|---|---|
| 1 | alle | **Ausführung:** Alle Skripte liefen im Cloud-Container (Ubuntu 24.04, MariaDB 10.11.14, PostgreSQL 16.15) **ohne systemd**; MariaDB wurde direkt mit `mariadbd` gestartet, PostgreSQL mit `pg_createcluster`/`pg_ctlcluster`. Das Verhalten auf Debian oder Ubuntu mit systemd und anderen Versionen wurde nicht getestet. | Übungen auf `db01` nachvollziehen; Pfade und Dienstnamen prüfen. |
| 2 | 01 | **Zeichensatz:** MariaDB wurde mit `--no-defaults` gestartet (Ausgabe `latin1`); die Paketdatei `50-server.cnf` setzt `utf8mb4`. PostgreSQL zeigt im Container `SQL_ASCII`, weil die Locale `C` ist. | Werte auf `db01` prüfen. |
| 3 | 03 | **Host-Auflösung:** Die Fehlermeldungen von MariaDB nennen `localhost`, obwohl über `127.0.0.1` verbunden wurde; das Konto mit `127.0.0.1` hat gepasst. | Auf `db01` mit `client01` über die Adresse prüfen. |
| 4 | 04 | **Testtabelle:** Autovacuum ist im PostgreSQL-Skript nur für die Testtabelle abgeschaltet, damit der Ablauf sichtbar ist. | Nicht in den Betrieb übernehmen. |
| 5 | 05 | **Zahlen:** `sicherungsplan.py` rechnet mit Annahmen (50 GB, Durchsätze), keine Messwerte. | Mit Messwerten von `db01` rechnen. |
| 6 | 07 | **TLS:** Das Zertifikat ist selbstsigniert; die Prüfung des Zertifikats durch den Client wurde nicht getestet. PostgreSQL meldete `ssl=on` bereits mit dem Standardzertifikat der Pakete. | Mit eigener CA und `verify-full` bzw. `--ssl-verify-server-cert` prüfen. |
| 7 | 08 | **Priorität:** Modul 8 ist Priorität 2; kein anderes Modul setzt es voraus. Beide Server laufen im Test auf einem Rechner; die Replikation zwischen zwei VMs wurde nicht getestet. | Bei Zeitmangel entfallen lassen; sonst auf `db01`/`db02` prüfen. |
| 8 | 09 | **Update:** Es gab nur eine Version je Produkt; ein echter Versionssprung wurde nicht getestet. Die Regeln für Minor/Major sind Fachwissen. | Auf einer Kopie mit zwei Versionen testen; Dokumentation lesen. |
| 9 | alle | **Quellen:** Die Dokumentation von MariaDB und PostgreSQL wurde nicht gelesen; Syntax, Standardwerte und Support-Zeiträume sind nicht bestätigt. | Quellen lesen und eintragen. |
