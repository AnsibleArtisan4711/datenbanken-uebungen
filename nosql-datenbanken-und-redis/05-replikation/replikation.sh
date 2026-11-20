#!/usr/bin/env bash
# Modul 5: Replikation mit zwei Redis-Instanzen (Haupt 6399, Replikat 6400, nur Loopback). Prüfung, Schreibschutz und Übernahme von Hand.
. "$(dirname "$0")/../lab.sh"
lab_up; start $P1 --repl-diskless-sync-delay 0; start $P2
warten_sync() { for i in $(seq 1 100); do redis-cli -p $P2 info replication | tr -d '\r' | grep -q 'master_link_status:up' && return 0; sleep 0.1; done; return 1; }
step "1. Replikat mit der Hauptinstanz verbinden (die Hauptinstanz startet mit repl-diskless-sync-delay 0, sonst war die Verbindung im Test nach 5 Sekunden noch nicht aufgebaut)"
RP=$P2 r replicaof 127.0.0.1 $P1; warten_sync && echo "Verbindung: up"
RP=$P2 rr info replication | tr -d '\r' | grep -E '^(role|master_link_status):'
RP=$P1 rr info replication | tr -d '\r' | grep -E '^(role|connected_slaves):'
step "2. Schreiben an der Hauptinstanz, Lesen am Replikat"
RP=$P1 r set bestellung:1 offen; sleep 0.3; RP=$P2 r get bestellung:1
step "3. Das Replikat ist schreibgeschützt"
RP=$P2 r set bestellung:2 offen
step "4. Hauptinstanz fällt aus (Prozess beendet), das Replikat behält die Daten"
stop $P1; sleep 0.3; RP=$P2 r get bestellung:1; RP=$P2 rr info replication | tr -d '\r' | grep -E '^master_link_status:'
step "5. Übernahme von Hand: Replikat wird Haupt (REPLICAOF NO ONE)"
RP=$P2 r replicaof no one; RP=$P2 rr info replication | tr -d '\r' | grep -E '^role:'; RP=$P2 r set bestellung:2 offen; RP=$P2 r get bestellung:2
step "6. Grenzen (Text)"
cat <<'T'
Die Replikation arbeitet asynchron: Schreibvorgänge, die das Replikat noch nicht erreicht haben, können bei einem Ausfall fehlen.
Die Übernahme von Hand genügt nicht für den Betrieb; automatische Übernahme (Sentinel, Cluster) wurde nicht ausgeführt.
Replikation ist keine Datensicherung: gelöschte Daten werden auf das Replikat übertragen.
T
