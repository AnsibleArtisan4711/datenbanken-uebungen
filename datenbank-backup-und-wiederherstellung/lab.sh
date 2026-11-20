#!/usr/bin/env bash
# Gemeinsame Hilfen der Übungsreihe (P68). Nur im Testlabor als root ausführen.
# MariaDB-Instanzen starten ohne systemd direkt mit mariadbd (Datenverzeichnis unter /tmp/p68),
# PostgreSQL-Cluster werden mit den Debian/Ubuntu-Werkzeugen (pg_createcluster, pg_ctlcluster) angelegt.
W=/tmp/p68
PGV=16
step() { echo; echo "## $*"; }
cmd() { echo "\$ $*"; "$@" 2>&1; return $?; }
lab_up() { lab_down >/dev/null 2>&1; mkdir -p "$W"; chmod 755 "$W"; }
# --- MariaDB: maria_up NAME PORT SERVER-ID [weitere mariadbd-Optionen] ---
maria_up() {
  local n=$1 p=$2 sid=$3; shift 3
  mkdir -p "$W/$n"; chown mysql:mysql "$W/$n"
  mariadb-install-db --no-defaults --user=mysql --datadir="$W/$n/data" --skip-test-db >"$W/$n/install.log" 2>&1
  su mysql -s /bin/bash -c "mariadbd --no-defaults --datadir=$W/$n/data --socket=$W/$n/s.sock --port=$p --bind-address=127.0.0.1 --pid-file=$W/$n/pid --log-error=$W/$n/error.log --server-id=$sid --log-bin=$W/$n/binlog $* </dev/null >/dev/null 2>&1 &"
  for i in $(seq 1 60); do mariadb --no-defaults -S "$W/$n/s.sock" -uroot -e 'select 1' >/dev/null 2>&1 && return 0; sleep 0.5; done
  echo "MariaDB $n startet nicht"; tail -5 "$W/$n/error.log"; return 1
}
# maria NAME [mariadb-Optionen]: SQL von stdin oder mit -e
maria() { local n=$1; shift; mariadb --no-defaults -S "$W/$n/s.sock" -uroot "$@"; }
maria_down() {
  local n=$1 pid
  [ -f "$W/$n/pid" ] || return 0
  pid=$(cat "$W/$n/pid"); kill "$pid" 2>/dev/null
  for i in $(seq 1 120); do kill -0 "$pid" 2>/dev/null || return 0; sleep 0.5; done
  kill -9 "$pid" 2>/dev/null
}
# --- PostgreSQL: pg_up NAME PORT ---
pg_up() { pg_createcluster $PGV "$1" -p "$2" >/dev/null 2>&1 && pg_ctlcluster $PGV "$1" start; for i in $(seq 1 40); do pg_isready -q -p "$2" && return 0; sleep 0.5; done; echo "PostgreSQL $1 startet nicht"; return 1; }
# pg PORT [psql-Optionen]: als Systembenutzer postgres (Peer-Anmeldung über Socket)
pg() { local p=$1; shift; su postgres -c "psql -X -p $p $(printf '%q ' "$@")"; }
pg_down() { pg_ctlcluster $PGV "$1" stop -m fast >/dev/null 2>&1; pg_dropcluster $PGV "$1" >/dev/null 2>&1; }
lab_down() {
  for d in "$W"/*/; do [ -d "$d" ] && maria_down "$(basename "$d")"; done
  for c in $(pg_lsclusters -h 2>/dev/null | awk '$1==16 && $2!="main"{print $2}'); do pg_down "$c"; done
  rm -rf "$W"
}
# --- Beispieldaten (erfunden) ---
# pg_daten PORT [ANZAHL]: Datenbank shop mit kunden und bestellungen
pg_daten() { local p=$1 n=${2:-1000}; pg $p -c 'create database shop' >/dev/null; pg $p -d shop -q >/dev/null <<SQL
create table kunden (id serial primary key, name text not null, ort text);
create table bestellungen (id serial primary key, kunde_id int references kunden(id), betrag numeric(10,2), erfasst timestamptz default now());
insert into kunden (name, ort) select 'Kunde ' || g, 'Ort ' || (g % 10) from generate_series(1, $n) g;
insert into bestellungen (kunde_id, betrag) select (g % $n) + 1, (g % 97) + 0.5 from generate_series(1, $n * 3) g;
SQL
}
# maria_daten NAME [ANZAHL]: Datenbank shop (InnoDB)
maria_daten() { local n=$1 c=${2:-1000}; maria $n <<SQL
create database shop; use shop;
create table kunden (id int auto_increment primary key, name varchar(50) not null, ort varchar(50)) engine=InnoDB;
create table bestellungen (id int auto_increment primary key, kunde_id int, betrag decimal(10,2), foreign key (kunde_id) references kunden(id)) engine=InnoDB;
insert into kunden (name, ort) select concat('Kunde ', seq), concat('Ort ', seq % 10) from seq_1_to_$c;
insert into bestellungen (kunde_id, betrag) select (seq % $c) + 1, (seq % 97) + 0.5 from seq_1_to_$((c * 3));
SQL
}
