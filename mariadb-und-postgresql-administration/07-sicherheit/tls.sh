#!/usr/bin/env bash
# TLS: selbstsigniertes Testzertifikat erzeugen und in MariaDB und PostgreSQL verwenden. NUR FÜR TESTS: echte Systeme brauchen Zertifikate einer vertrauenswürdigen Stelle.
cd "$(dirname "$0")" || exit 1
. ../lab.sh
lab_up; mkdir -p $W/tls
step "1. Testzertifikat für den Namen db.example.com erzeugen (selbstsigniert, 30 Tage)"
openssl req -x509 -newkey rsa:2048 -nodes -days 30 -subj "/CN=db.example.com" -keyout $W/tls/server.key -out $W/tls/server.crt 2>/dev/null
chown mysql:mysql $W/tls/server.key $W/tls/server.crt; chmod 600 $W/tls/server.key
openssl x509 -in $W/tls/server.crt -noout -subject -issuer | sed 's/^/  /'
step "2. MariaDB mit TLS starten und prüfen"
maria_up demo 3311 1 --ssl-cert=$W/tls/server.crt --ssl-key=$W/tls/server.key || exit 1
maria demo <<'SQL'
create user 'tlsuser'@'%' identified by 'Test-Tls-12345' require ssl;
grant select on mysql.* to 'tlsuser'@'%';
SQL
maria demo -N -e "show variables like 'have_ssl'" | sed 's/\t/   /'
echo "-- Verbindung MIT TLS (Zertifikat wird in diesem Test nicht geprüft):"
mariadb --no-defaults -h127.0.0.1 -P3311 -utlsuser -pTest-Tls-12345 --ssl -e "show session status like 'Ssl_cipher'; show session status like 'Ssl_version'" | sed 's/\t/   /'
echo "-- Verbindung OHNE TLS wird für diesen Benutzer abgelehnt:"
mariadb --no-defaults -h127.0.0.1 -P3311 -utlsuser -pTest-Tls-12345 --skip-ssl -e "select 1" 2>&1 | head -1 | sed -E "s/'[^']*'@'[^']*'/'tlsuser'@'host'/"
step "3. PostgreSQL mit TLS: ssl=on, Schlüsseldatei darf nur dem Besitzer lesbar sein"
pg_up demo 5441 || exit 1
install -o postgres -g postgres -m 600 $W/tls/server.key /var/lib/postgresql/16/demo/server.key
install -o postgres -g postgres -m 644 $W/tls/server.crt /var/lib/postgresql/16/demo/server.crt
cat > /etc/postgresql/16/demo/conf.d/tls.conf <<CONF
ssl = on
ssl_cert_file = '/var/lib/postgresql/16/demo/server.crt'
ssl_key_file = '/var/lib/postgresql/16/demo/server.key'
CONF
pg_ctlcluster 16 demo restart
pg 5441 -c "create role tlsuser login password 'Test-Tls-12345'" -q
sed -i '1i hostssl all tlsuser 127.0.0.1/32 scram-sha-256\nhostnossl all tlsuser 127.0.0.1/32 reject' /etc/postgresql/16/demo/pg_hba.conf
pg 5441 -c "select pg_reload_conf()" >/dev/null; sleep 1
echo "-- Verbindung mit TLS:"
PGPASSWORD=Test-Tls-12345 PGSSLMODE=require psql -X -h 127.0.0.1 -p 5441 -U tlsuser -d postgres -c "select ssl, version, cipher from pg_stat_ssl where pid = pg_backend_pid()" 2>&1 | sed -n 1,4p
echo "-- Verbindung ohne TLS wird abgelehnt (hostnossl ... reject):"
PGPASSWORD=Test-Tls-12345 PGSSLMODE=disable psql -X -h 127.0.0.1 -p 5441 -U tlsuser -d postgres -c "select 1" 2>&1 | head -1 | sed -E 's/"[^"]*"/"..."/2'
rm -f /etc/postgresql/16/demo/conf.d/tls.conf
lab_down
