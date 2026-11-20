# Befehle und Aussagen, die nicht bestätigt sind

Prüfliste für den ersten Durchlauf in den Hyper-V-VMs: Befund und Datum eintragen, danach den Hinweis in der Übung entfernen. Legende: **Q** = gegen Quelle gelesen; **L** = im Labor (Container) ausgeführt; **–** = weder noch.

| Modul | Befehl oder Aussage | Status | Nächster Schritt |
|---|---|---|---|
| alle | Aufbau des Hyper-V-Labors (privater Switch `Lab-NoSQL`, `redis01`, `redis02`), Installation von Redis | – | laut Lehrplan aufbauen und prüfen |
| 01 | `redis-server --port`, `redis-cli ping/set/get/del/exists/dbsize/--scan`, `INFO server` | L (Redis 7.0.15) | auf `redis01` wiederholen |
| 02 | `INCR`, `INCRBY`, `RPUSH`, `LPOP`, `LRANGE`, `HSET`, `HGETALL`, `HINCRBY`, `SADD`, `SINTER`, `SUNION`, `ZADD`, `ZRANGE`, `ZREVRANGE`, `ZINCRBY` | L | auf `redis01` wiederholen |
| 03 | `SET … EX`, `TTL`, `EXPIRE`, `PERSIST` | L | auf `redis01` wiederholen |
| 04 | `SAVE`, `--appendonly yes`, `--appendfsync always`, `kill -9` | L | auf `redis01` wiederholen; weitere `appendfsync`-Werte nicht ausgeführt |
| 05 | `REPLICAOF`, `INFO replication`, `--repl-diskless-sync-delay 0` | L (zwei Instanzen auf Loopback) | auf `redis01` und `redis02` wiederholen |
| 06 | `CONFIG SET requirepass`, `ACL SETUSER`, `--user`, `--pass` | L | auf `redis01` wiederholen; TLS nicht ausgeführt |
| 07 | Python-Modell eines Dokumentenspeichers; `mongodb_beispiel.txt` | Modell: L; MongoDB: nicht ausgeführt | mit MongoDB ausführen; Syntax mit der Dokumentation prüfen |
| 08 | `MULTI`/`EXEC`, `SUBSCRIBE`/`PUBLISH`, `CONFIG SET maxmemory`, `maxmemory-policy`, `SLOWLOG` | L | auf `redis01` wiederholen; Sentinel und Cluster nicht ausgeführt |
