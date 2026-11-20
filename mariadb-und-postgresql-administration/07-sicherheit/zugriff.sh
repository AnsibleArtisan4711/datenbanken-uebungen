#!/usr/bin/env bash
# Zugriffskontrolle: auf welchen Adressen lauscht der Dienst, wer darf sich anmelden, wie wird authentifiziert? (erfundene Daten)
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; maria_up demo 3311 1 || exit 1; pg_up demo 5441 || exit 1
step "1. Auf welchen Adressen lauschen die Dienste?"
ss -ltnp 2>/dev/null | awk 'NR==1 || /3311|5441/ {print $1, $4, $6}' | sed -E 's/users:\(\("([^"]+)".*/\1/' | sed 's/\t/   /g'
echo "(127.0.0.1 = nur der eigene Rechner. Für Zugriff vom Client muss bind-address bzw. listen_addresses gesetzt UND die Firewall/pg_hba.conf angepasst werden.)"
step "2. MariaDB: Anmeldung über Socket (Betriebssystemkonto root) und über TCP"
maria demo -N -e "select user, host from mysql.user where user in ('root','mysql') order by user, host" | sed 's/\t/   /g'
echo "-- Die Anmeldung per Socket als Betriebssystem-root hat gerade funktioniert (diese Skriptzeilen laufen so). Per TCP ohne Kennwort wird root abgewiesen:"
mariadb --no-defaults -h127.0.0.1 -P3311 -uroot -e "select 1" 2>&1 | head -1
step "3. PostgreSQL: pg_hba.conf entscheidet über Herkunft und Methode (erste passende Zeile gilt)"
grep -vE '^\s*(#|$)' /etc/postgresql/16/demo/pg_hba.conf
echo "-- Verbindung per TCP ohne Kennwort als Benutzer postgres:"
psql -X -h 127.0.0.1 -p 5441 -U postgres -w -d postgres -c "select 1" 2>&1 | head -1
step "4. Eine zu offene Regel erkennen und entschärfen (pg_hba.conf, erfundene Adresse 10.31.0.0/24)"
echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/16/demo/pg_hba.conf
pg 5441 -c "select pg_reload_conf()" >/dev/null; sleep 1
pg 5441 -c "select line_number, type, database, address, auth_method from pg_hba_file_rules where auth_method='trust'"
echo "-- 'trust' für 0.0.0.0/0 bedeutet: jeder darf sich ohne Kennwort anmelden. Ersetzen durch Subnetz und scram-sha-256:"
sed -i '/0.0.0.0\/0 trust/d' /etc/postgresql/16/demo/pg_hba.conf
echo "host shop app 10.31.0.0/24 scram-sha-256" >> /etc/postgresql/16/demo/pg_hba.conf
pg 5441 -c "select pg_reload_conf()" >/dev/null; sleep 1
pg 5441 -c "select line_number, type, database, user_name, address, netmask, auth_method from pg_hba_file_rules where address like '10.31%'"
lab_down
