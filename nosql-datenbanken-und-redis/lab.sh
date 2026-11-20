#!/usr/bin/env bash
# Gemeinsame Hilfen der Übungsreihe (P67). Redis läuft nur auf 127.0.0.1 (Ports 6399 und 6400), Dateien unter /tmp/p67. Alle Daten sind erfunden.
W=/tmp/p67; P1=6399; P2=6400
step() { echo; echo "## $*"; }
cmd() { echo "\$ $*"; "$@" 2>&1; return $?; }
r() { echo "> $*"; redis-cli -p ${RP:-$P1} --no-raw "$@" 2>&1; }          # Befehl an die aktive Instanz, formatierte Ausgabe
rr() { redis-cli -p ${RP:-$P1} "$@" 2>&1; }                  # Rohausgabe
warte() { for i in $(seq 1 50); do redis-cli -p $1 ping >/dev/null 2>&1 && return 0; sleep 0.1; done; echo "Port $1 nicht bereit"; return 1; }
start() {  # start PORT [weitere Optionen]
  local p=$1; shift; mkdir -p "$W/$p"
  nohup redis-server --port $p --bind 127.0.0.1 --dir "$W/$p" --save "" --appendonly no --daemonize no "$@" >"$W/$p/log.txt" 2>&1 &
  echo $! >> "$W/pids"; disown; warte $p; }
stop() { redis-cli -p $1 shutdown nosave >/dev/null 2>&1; }
lab_up() { lab_down >/dev/null 2>&1; mkdir -p "$W"; }
lab_down() { stop $P1; stop $P2; [ -f "$W/pids" ] && kill $(cat "$W/pids") 2>/dev/null; sleep 0.2; rm -rf "$W"; }
trap 'lab_down >/dev/null 2>&1' EXIT
