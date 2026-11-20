#!/usr/bin/env bash
# Version, Datenverzeichnis, Port und Zeichensatz der Instanzen abfragen.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up
maria_up demo 3311 1 || exit 1
pg_up demo 5441 || exit 1
step "MariaDB"
maria demo -t -e "select version() as version; show variables where Variable_name in ('port','datadir','character_set_server','collation_server','max_connections','bind_address','socket');" | sed "s#$W#/tmp/p31#g"
echo "(Hinweis: Die Zeichensatz-Werte hängen vom Test-Container ab: MariaDB wurde mit --no-defaults gestartet, PostgreSQL erbt die Umgebung (Locale).)"
step "PostgreSQL"
pg 5441 -c "select version();" -c "show data_directory;" -c "show port;" -c "show server_encoding;" -c "select datname, datcollate, datctype from pg_database where datname = 'postgres';" -c "show max_connections;" -c "show listen_addresses;"
lab_down
