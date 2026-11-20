#!/usr/bin/env bash
# PostgreSQL überwachen: pg_stat_activity, pg_stat_database, Sperren, Protokoll (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; pg_up demo 5441 || exit 1
pg 5441 -q -c "create database shop"
pg 5441 -d shop -q -c "create table konto (id int primary key, stand int); insert into konto values (1,100)"
step "1. Verbindungen nach Zustand"
pg 5441 -d shop -c "select state, count(*) from pg_stat_activity where backend_type='client backend' group by state order by 1"
step "2. Eine blockierte Abfrage sichtbar machen (Sitzung A hält eine Sperre, Sitzung B wartet)"
( pg 5441 -d shop -q -c "begin; update konto set stand = 90 where id = 1; select pg_sleep(4); commit;" >/dev/null 2>&1 ) &
sleep 1
( pg 5441 -d shop -q -c "update konto set stand = 80 where id = 1" >/dev/null 2>&1 ) &
sleep 1
pg 5441 -d shop -c "select wait_event_type, wait_event, left(query,40) as abfrage from pg_stat_activity where wait_event_type = 'Lock'"
pg 5441 -d shop -c "select pid <> 0 as hat_pid, cardinality(pg_blocking_pids(pid)) as blockiert_von from pg_stat_activity where wait_event_type='Lock'"
wait
step "3. Datenbankstatistik: Commits, Rollbacks, Deadlocks, Tupel"
pg 5441 -d shop -c "select datname, xact_commit > 0 as hat_commits, xact_rollback, deadlocks, conflicts from pg_stat_database where datname='shop'"
step "4. Lange laufende Anweisungen (Schwelle 2 Sekunden) finden"
( pg 5441 -d shop -q -c "select pg_sleep(4)" >/dev/null 2>&1 ) &
sleep 3
pg 5441 -d shop -c "select left(query,25) as abfrage, now() - query_start > interval '2 seconds' as laenger_als_2s from pg_stat_activity where state='active' and pid <> pg_backend_pid() and query like 'select pg_sleep%'"
wait
step "5. Protokoll: Anmeldefehler stehen in der Logdatei"
PGPASSWORD=falsch psql -X -h 127.0.0.1 -p 5441 -U niemand -d shop -c "select 1" >/dev/null 2>&1
grep -E 'FATAL' /var/log/postgresql/postgresql-16-demo.log | tail -2 | sed -E 's/^[0-9-]+ [0-9:.]+ [A-Z]+ \[[0-9]+\] //'
lab_down
