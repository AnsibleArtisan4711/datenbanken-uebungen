# Anmerkungen zum Lehrplan P68

Beim Ausarbeiten und Testen aufgefallene Punkte. Der Lehrplan selbst wurde zusammen mit der Übungsreihe erstellt und danach **nicht** verändert.

| Nr. | Modul | Befund | Vorschlag |
|---|---|---|---|
| 1 | alle | **Ausführung:** Alle Skripte liefen im Cloud-Container (Ubuntu 24.04, kein systemd) mit PostgreSQL 16, MariaDB 10.11 und SQLite. Alle Daten sind erfunden. Das Verhalten auf `db01` und mit anderen Versionen wurde nicht getestet. | Übungen auf `db01` nachvollziehen; Ausgaben vergleichen. |
| 2 | alle | **Nicht ausgeführt:** Offsite-Speicher, Objektsperre, `cron`, `zstd`, physische Sicherung und PITR (siehe P31). Die Dokumentation der Werkzeuge wurde nicht gelesen. | Im Labor ausführen und Ergebnis eintragen. |
| 3 | 03 | **Befund:** `PRAGMA integrity_check` meldet `ok`, obwohl eine Änderung in der Mitte der Datei die Prüfsumme ändert; die Strukturprüfung erkennt nicht jede Änderung. | Prüfsumme und Strukturprüfung gemeinsam einsetzen. |
| 4 | 04 | **Befund:** `pg_restore -l` liefert bei einer abgeschnittenen Sicherung den Rückgabecode 0; erst das Einspielen in eine Testinstanz scheitert. | Auflisten ersetzt keinen Wiederherstellungstest. |
| 5 | 05 | **Aufbewahrung:** Die Regel 7/4/3 ist ein Beispielmodell; rechtliche Fristen wurden nicht geprüft. | Fristen mit Fachabteilung klären. |
| 6 | 07 | **Priorität:** Modul 7 ist Priorität 2; kein anderes Modul setzt es voraus. Medien, Orte und Rollen sind erfunden; `chmod 444` ist als root wirkungslos. | Bei Zeitmangel entfallen lassen. |
| 7 | 08 | **Zeitmessung:** Die Wiederherstellungsdauer schwankt; festgehalten ist nur „unter 60 Sekunden“. | Mit eigenen Daten messen. |
