#!/bin/bash
# Hilfsmittel (NICHT Teil des Lehrplans): baut db-server und db-client ohne Hyper-V in Netzwerk-Namespaces nach.
# Nur als root auf einem Linux-Testrechner, nicht auf einem Produktivsystem. Benötigt: iproute2, postgresql (Debian/Ubuntu-Paket), psql.
# Verwendung:  source testlabor30.sh; lab_up   # db-server = 192.168.100.10, db-client = 192.168.100.20 (eth0 in beiden)
#              ip netns exec db-server <befehl>   # Befehl im "Server"
#              lab_down
# Unterschied zur Hyper-V-Umgebung: der Client ist ein Linux-Namespace mit psql statt Windows mit DBeaver.
# Stand: Entwurf; ausgeführt auf Ubuntu 24.04 mit PostgreSQL 16, nicht auf Debian 12 mit PostgreSQL 15 und nicht auf Hyper-V.
lab_up(){
  ip netns add db-server; ip netns add db-client
  ip link add vs01 type veth peer name vc01
  ip link set vs01 netns db-server; ip link set vc01 netns db-client
  ip -n db-server link set vs01 name eth0; ip -n db-client link set vc01 name eth0
  ip -n db-server addr add 192.168.100.10/24 dev eth0; ip -n db-client addr add 192.168.100.20/24 dev eth0
  for n in db-server db-client; do ip -n $n link set eth0 up; ip -n $n link set lo up; done
}
lab_down(){ for n in db-server db-client; do ip netns del $n 2>/dev/null; done; }
