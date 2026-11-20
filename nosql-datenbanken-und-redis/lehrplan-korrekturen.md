# Anmerkungen zum Lehrplan P67

Beim Ausarbeiten und Testen aufgefallene Punkte. Der Lehrplan selbst wurde zusammen mit der Übungsreihe erstellt und danach **nicht** verändert.

| Nr. | Modul | Befund | Vorschlag |
|---|---|---|---|
| 1 | alle | **Ausführung:** Alle Skripte liefen im Cloud-Container (Ubuntu 24.04, kein systemd) mit Redis 7.0.15 auf Loopback. Alle Daten und Kennwörter sind erfunden. Das Verhalten auf `redis01` und mit anderen Versionen wurde nicht getestet. | Übungen auf `redis01` nachvollziehen; Ausgaben vergleichen. |
| 2 | alle | **Nicht ausgeführt:** MongoDB, Redis Sentinel und Cluster, TLS. Die Datei `mongodb_beispiel.txt` ist Text aus Fachwissen und **nicht bestätigt**. | Im Labor ausführen und Ergebnis eintragen. |
| 3 | alle | **Quellen und Lizenz:** Die Dokumentation von Redis und MongoDB wurde nicht gelesen. Zur Lizenz wurden nur Schlagzeilen einer Websuche gesehen; die Lizenz der getesteten Version 7.0.15 wurde nicht geprüft. | Lizenz mit Stand prüfen. |
| 4 | 04 | **Hartes Ende:** Das Skript beendet Redis mit `kill -9`; die Zahl der AOF-Befehle (3) und die Dateien (3) gelten für Redis 7.0.15; bei anderen Versionen kann die Dateistruktur abweichen. | Bei anderer Version prüfen. |
| 5 | 05 | **Zeitverhalten:** Ohne `--repl-diskless-sync-delay 0` war die Verbindung im Test nach 5 Sekunden noch nicht aufgebaut; die Ursache (Standardwert) wurde nicht in der Dokumentation belegt. | In der Dokumentation nachlesen. |
| 6 | 07 | **Priorität:** Modul 7 ist Priorität 2; kein anderes Modul setzt es voraus. Das Python-Modell kennt nur wenige Operatoren und ist kein Datenbankprodukt. | Bei Zeitmangel entfallen lassen. |
| 7 | 08 | **Verdrängung:** Die Zahl der verdrängten Schlüssel hängt vom Speicherverbrauch der Instanz ab; die Ausgabe zeigt nur „weniger als 50“. | Mit eigenen Werten wiederholen. |
