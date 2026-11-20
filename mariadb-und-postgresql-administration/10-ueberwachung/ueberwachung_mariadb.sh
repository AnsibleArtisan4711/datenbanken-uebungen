#!/usr/bin/env bash
# MariaDB überwachen: Statusvariablen, laufende Abfragen, Fehlerprotokoll (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 --max-connections=20 || exit 1
step "1. Wichtige Statusvariablen"
maria demo -t -e "select variable_name, variable_value from information_schema.global_status where variable_name in ('UPTIME','THREADS_CONNECTED','MAX_USED_CONNECTIONS','ABORTED_CONNECTS','SLOW_QUERIES','CONNECTIONS') order by 1"
step "2. Laufende Verbindungen und Abfragen (SHOW PROCESSLIST)"
maria demo -e "select sleep(3)" >/dev/null 2>&1 &
sleep 1
maria demo -t -e "select id > 0 as hat_id, user, left(command,8) as command, left(info,30) as info from information_schema.processlist order by command"
wait
step "3. Fehlschläge zählen: falsche Anmeldung erhöht Aborted_connects"
mariadb --no-defaults -h127.0.0.1 -P3311 -uniemand -pfalsch -e "select 1" >/dev/null 2>&1
maria demo -N -e "show global status like 'Aborted_connects'" | sed 's/\t/   /'
step "4. Verbindungslimit: Auslastung in Prozent"
maria demo -N -e "select concat(round(100*(select variable_value from information_schema.global_status where variable_name='MAX_USED_CONNECTIONS')/@@max_connections,1),' % des Limits (', @@max_connections, ') bisher genutzt')"
step "5. Fehlerprotokoll (letzte Zeilen, Zeitstempel entfernt)"
tail -3 $W/demo/error.log | sed -E 's/^[0-9-]+ +[0-9:]+ [0-9]+ //'
lab_down
