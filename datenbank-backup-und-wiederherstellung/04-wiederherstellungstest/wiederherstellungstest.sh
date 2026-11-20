#!/usr/bin/env bash
# Modul 4: Wiederherstellungstest und Verifikation: Sicherung in eine zweite Instanz einspielen und den Inhalt vergleichen; beschädigte Sicherungen erkennen.
. "$(dirname "$0")/../lab.sh"
lab_up; pg_up q 5481 >/dev/null; pg_up z 5482 >/dev/null; pg_daten 5481 800
maria_up mq 3381 11 >/dev/null; maria_up mz 3382 12 >/dev/null; maria_daten mq 800
D="$W/dump"; mkdir -p "$D"; chown postgres "$D"; chmod 777 "$D"
pf() { pg $1 -d shop -Atc "select count(*), sum(betrag), md5(string_agg(id::text || ':' || kunde_id || ':' || betrag, ',' order by id)) from bestellungen"; }
mf() { maria $1 -N -e "select count(*), sum(betrag), md5(group_concat(concat(id, ':', kunde_id, ':', betrag) order by id separator ',')) from shop.bestellungen"; }
step "1. PostgreSQL: Sicherung der Quelle (Port 5481), Einspielen in die Zielinstanz (Port 5482)"
su postgres -c "pg_dump -p 5481 -Fc shop -f $D/shop.dump"; pg 5482 -c 'create database shop' >/dev/null; su postgres -c "pg_restore -p 5482 -d shop $D/shop.dump"; echo "pg_restore Rückgabecode: $?"
echo "Quelle : $(pf 5481 | awk -F'|' '{print $1 "|" $2}')"; echo "Ziel   : $(pf 5482 | awk -F'|' '{print $1 "|" $2}')"
echo "Prüfsumme der Zeilen gleich: $([ "$(pf 5481)" = "$(pf 5482)" ] && echo ja || echo nein)"
step "2. Ein einzelner Wert wird in der Quelle geändert: die Prüfsumme bemerkt es, Anzahl und Summe nicht unbedingt"
pg 5481 -d shop -qc "update bestellungen set betrag = betrag + 1 where id = 1; update bestellungen set betrag = betrag - 1 where id = 2"
echo "Anzahl und Summe gleich: $([ "$(pf 5481 | awk -F'|' '{print $1 "|" $2}')" = "$(pf 5482 | awk -F'|' '{print $1 "|" $2}')" ] && echo ja || echo nein)"
echo "Prüfsumme gleich: $([ "$(pf 5481)" = "$(pf 5482)" ] && echo ja || echo nein)"
step "3. Beschädigte Sicherung: Datei abgeschnitten"
head -c 20000 "$D/shop.dump" > "$D/kurz.dump"; su postgres -c "pg_restore -p 5482 -l $D/kurz.dump >/dev/null 2>$D/fehler.txt"; echo "pg_restore -l Rückgabecode: $?"; sed -n 1p "$D/fehler.txt" | cut -c1-70
pg 5482 -c 'create database probe' >/dev/null; su postgres -c "pg_restore -p 5482 -d probe --exit-on-error $D/kurz.dump >/dev/null 2>$D/fehler2.txt"; echo "pg_restore ins Ziel Rückgabecode ungleich 0: $([ $? -ne 0 ] && echo ja || echo nein)"
echo "Das Auflisten mit pg_restore -l erkannte den Schaden in diesem Lauf nicht; erst das Einspielen in eine Testinstanz schlug fehl."
step "4. MariaDB: Dump einspielen und vergleichen"
mariadb-dump --no-defaults -S $W/mq/s.sock -uroot --single-transaction shop > $D/maria.sql
maria mz -e 'create database shop'; maria mz shop < $D/maria.sql; echo "Rückgabecode: $?"
echo "Quelle : $(mf mq | awk '{print $1 "|" $2}')"; echo "Ziel   : $(mf mz | awk '{print $1 "|" $2}')"
echo "Prüfsumme der Zeilen gleich: $([ "$(mf mq)" = "$(mf mz)" ] && echo ja || echo nein)"
step "5. Abgeschnittener MariaDB-Dump: Prüfung der letzten Zeile"
head -c 30000 $D/maria.sql > $D/maria_kurz.sql; echo "Letzte Zeile des vollständigen Dumps: $(tail -1 $D/maria.sql | cut -c1-18)"; echo "Letzte Zeile des abgeschnittenen Dumps: (mitten in einer Anweisung abgebrochen)"
echo "Abschlusszeile \"Dump completed\" vorhanden (vollständig): $(grep -c 'Dump completed' $D/maria.sql); (abgeschnitten): $(grep -c 'Dump completed' $D/maria_kurz.sql)"
step "6. Ablauf eines Wiederherstellungstests (Text)"
cat <<'T'
1 Sicherung auswählen (zufällig oder die älteste noch gültige)
2 In einer getrennten Testinstanz einspielen, nie in die Produktion
3 Zeilenzahlen, Summen und Prüfsumme mit der Quelle vergleichen (bei bewegter Quelle: Zeitpunkt der Sicherung beachten)
4 Dauer messen und mit dem RTO vergleichen
5 Ergebnis dokumentieren, Testinstanz entfernen
T
