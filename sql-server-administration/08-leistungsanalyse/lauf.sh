#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
python3 wartezeiten.py beispiel_waits.csv
