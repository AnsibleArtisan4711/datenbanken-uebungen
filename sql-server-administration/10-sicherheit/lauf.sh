#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
python3 sicherheit_pruefen.py beispiel_stand.csv
