#!/usr/bin/env bash
# PostgreSQL: EXPLAIN (ANALYZE), Indizes und pg_stat_statements (erfundene Daten).
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; pg_up demo 5441 || exit 1
echo "shared_preload_libraries = 'pg_stat_statements'" > /etc/postgresql/16/demo/conf.d/stat.conf
pg_ctlcluster 16 demo restart
pg 5441 -q -c "create database shop"
pg 5441 -d shop -q <<'SQL'
create extension pg_stat_statements;
create table bestellung (id serial primary key, kunde_id int, betrag numeric(8,2), status text);
insert into bestellung (kunde_id, betrag, status) select g % 5000, (g % 997) / 10.0, case when g % 10 = 0 then 'offen' else 'fertig' end from generate_series(1,200000) g;
analyze bestellung;
SQL
Q="select count(*), sum(betrag) from bestellung where kunde_id = 4242"
step "1. EXPLAIN ohne Index: sequentieller Scan (Seq Scan), Zeitwerte variieren"
pg 5441 -d shop -c "explain (analyze, buffers off, timing off, summary off) $Q"
step "2. Index anlegen und erneut prüfen (Index Scan oder Bitmap Heap Scan)"
pg 5441 -d shop -q -c "create index idx_kunde on bestellung (kunde_id)" -c "analyze bestellung"
pg 5441 -d shop -c "explain (analyze, buffers off, timing off, summary off) $Q"
step "3. pg_stat_statements: die teuersten Anweisungen (Ausführungen, Gesamtzeit gerundet)"
pg 5441 -d shop -q -c "select pg_stat_statements_reset()" >/dev/null
for i in 1 2 3; do pg 5441 -d shop -q -c "$Q" >/dev/null; done
pg 5441 -d shop -c "select calls, round(total_exec_time::numeric,0) > 0 as hat_zeit, rows, left(query,60) as abfrage from pg_stat_statements where query like '%bestellung%' and query not like '%pg_stat%' order by total_exec_time desc limit 3"
rm -f /etc/postgresql/16/demo/conf.d/stat.conf
lab_down
