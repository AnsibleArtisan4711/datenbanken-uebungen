#!/usr/bin/env bash
# Installation und Aufbau: Pakete, Programme, Pfade, Prozesse. Startet je eine Test-Instanz im Container (ohne systemd).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up
step "1. Installierte Pakete und Versionen"
dpkg-query -W -f='${Package} ${Version}\n' mariadb-server postgresql-16 | sed 's/^/  /'
step "2. Wichtige Programme"
for p in mariadbd mariadb mariadb-dump mariabackup mariadb-upgrade pg_createcluster pg_ctlcluster pg_dump pg_basebackup; do printf '  %-20s %s\n' "$p" "$(command -v $p 2>/dev/null || ls /usr/lib/postgresql/16/bin/$p 2>/dev/null || echo fehlt)"; done
step "3. Standardpfade (Debian/Ubuntu-Pakete)"
for f in /etc/mysql/my.cnf /etc/mysql/mariadb.conf.d /var/lib/mysql /etc/postgresql/16/main/postgresql.conf /etc/postgresql/16/main/pg_hba.conf /var/lib/postgresql/16/main; do [ -e "$f" ] && echo "  vorhanden: $f" || echo "  fehlt:     $f"; done
step "4. PostgreSQL-Cluster (Debian-Verwaltung mit pg_lsclusters)"
cmd pg_lsclusters
step "5. Eine MariaDB-Instanz starten und das Prozessmodell ansehen"
maria_up demo 3311 1 || exit 1
PID=$(cat $W/demo/pid)
echo "MariaDB: ein Prozess (PID vorhanden: $([ -n "$PID" ] && echo ja)), Threads: $(ls /proc/$PID/task | wc -l) (Wert variiert)"
step "6. Einen PostgreSQL-Cluster starten und das Prozessmodell ansehen"
pg_up demo 5441 || exit 1
echo "PostgreSQL: Hauptprozess plus Hilfsprozesse:"
ps -u postgres -o args= | grep -E '^postgres: 16/demo' | sed 's/^postgres: 16\/demo: /  /' | sort
cmd pg_lsclusters
lab_down
