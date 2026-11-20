#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
python3 agent_jobs.py beispiel_jobs.csv
