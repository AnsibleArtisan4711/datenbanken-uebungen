# 07 Sicherheit

Übung **07.1** (Priorität 1). Geschätzte Zeit: 7 bis 9 Stunden (Schätzung; Lehrplan: 12 UE zu 45 Minuten = 9 Stunden).

> Skripte im Container ausgeführt.

| Datei | Zweck |
|---|---|
| `07.1-sicherheit.md` | Die Übung mit Aufgaben, Kontrollfragen und Musterlösung |
| `sicherheit_pruefen.sh` | Kleine Sicherheitsprüfung gegen zwei Test-Instanzen mit absichtlichen Schwächen (erfundene Konten). Gibt je Prüfung OK oder WARNUNG aus. |
| `tls.sh` | TLS: selbstsigniertes Testzertifikat erzeugen und in MariaDB und PostgreSQL verwenden. NUR FÜR TESTS: echte Systeme brauchen Zertifikate einer vertrauenswürdigen Stelle. |
| `zugriff.sh` | Zugriffskontrolle: auf welchen Adressen lauscht der Dienst, wer darf sich anmelden, wie wird authentifiziert? (erfundene Daten) |
| `beispiele/sicherheit_pruefen.ausgabe.txt` | Echte Ausgabe des Laufs von `sicherheit_pruefen` |
| `beispiele/tls.ausgabe.txt` | Echte Ausgabe des Laufs von `tls` |
| `beispiele/zugriff.ausgabe.txt` | Echte Ausgabe des Laufs von `zugriff` |
