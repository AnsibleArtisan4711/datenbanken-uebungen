#!/usr/bin/env bash
# Testet das Plugin gegen laufende und gestoppte Instanzen.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 --max-connections=10 || exit 1; pg_up demo 5441 || exit 1
chk() { echo "\$ python3 check_datenbank.py $*"; python3 check_datenbank.py "$@"; echo "Rückgabecode: $?"; echo; }
step "1. Normalbetrieb"
chk mariadb $W/demo/s.sock 70 90
chk postgres 5441 70 90
step "2. Auslastung erzwingen: 8 offene MariaDB-Verbindungen bei Limit 10"
for i in 1 2 3 4 5 6 7; do maria demo -e "select sleep(6)" >/dev/null 2>&1 & done
sleep 1
chk mariadb $W/demo/s.sock 70 90
chk mariadb $W/demo/s.sock 90 95
wait
step "3. Dienst gestoppt"
maria_down demo
chk mariadb $W/demo/s.sock 70 90
pg_ctlcluster 16 demo stop
chk postgres 5441 70 90
step "4. Falscher Aufruf"
chk mariadb
lab_down
