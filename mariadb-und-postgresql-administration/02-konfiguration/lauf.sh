#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
for f in beispiel_mariadb.cnf beispiel_postgresql.conf; do echo "\$ python3 konfig_pruefen.py $f"; python3 konfig_pruefen.py $f; echo "Rückgabecode: $?"; echo; done
