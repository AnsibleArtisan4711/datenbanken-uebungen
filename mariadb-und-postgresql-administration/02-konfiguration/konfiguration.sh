#!/usr/bin/env bash
# Konfigurationsdateien, Rangfolge und Änderungen im laufenden Betrieb (MariaDB und PostgreSQL).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up
step "1. MariaDB: Konfigurationsdateien der Debian/Ubuntu-Pakete"
ls /etc/mysql/mariadb.conf.d/
echo "-- Auszug aus 50-server.cnf (nur aktive Zeilen):"
grep -vE '^\s*(#|$)' /etc/mysql/mariadb.conf.d/50-server.cnf | head -8
step "2. MariaDB: welche Dateien werden gelesen? (--help, Suchreihenfolge)"
mariadbd --verbose --help 2>/dev/null | grep -A1 'Default options are read from' | tail -1
step "3. MariaDB: Dauerhaft (Datei) gegen Laufzeit (SET GLOBAL)"
echo "Start mit Option --max-connections=77 (gleiche Wirkung wie max_connections = 77 in einer .cnf-Datei):"
maria_up demo 3311 1 --max-connections=77 || exit 1
maria demo -N -e "show variables like 'max_connections'"
maria demo -e "set global max_connections = 120"
echo "nach SET GLOBAL:"; maria demo -N -e "show variables like 'max_connections'"
echo "(Nach einem Neustart gilt wieder der Wert aus der Konfiguration; SET GLOBAL ist nicht dauerhaft.)"
step "4. PostgreSQL: Dateien und Herkunft eines Parameters (pg_settings)"
pg_up demo 5441 || exit 1
ls /etc/postgresql/16/demo/
pg 5441 -c "select name, setting, unit, source, sourcefile is not null as aus_datei from pg_settings where name in ('max_connections','shared_buffers','work_mem','listen_addresses') order by name"
step "5. PostgreSQL: ALTER SYSTEM, reload und Neustart-pflichtige Parameter"
pg 5441 -c "alter system set work_mem = '8MB'" -c "alter system set max_connections = 150"
pg 5441 -c "select name, setting, pending_restart from pg_settings where name in ('work_mem','max_connections') order by name"
echo "-- nach pg_reload_conf(): work_mem gilt, max_connections wartet auf Neustart"
pg 5441 -c "select pg_reload_conf()"
sleep 1
pg 5441 -c "select name, setting, pending_restart from pg_settings where name in ('work_mem','max_connections') order by name"
echo "-- Datei, in die ALTER SYSTEM schreibt:"
cat /var/lib/postgresql/16/demo/postgresql.auto.conf | grep -v '^#'
pg_ctlcluster 16 demo restart
pg 5441 -c "show max_connections"
lab_down
