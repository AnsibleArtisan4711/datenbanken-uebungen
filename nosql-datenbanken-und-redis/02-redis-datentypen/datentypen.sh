#!/usr/bin/env bash
# Modul 2: Datentypen in Redis: Zeichenketten, Zähler, Listen, Hashes, Mengen, sortierte Mengen. Erfundene Daten.
. "$(dirname "$0")/../lab.sh"
lab_up; start $P1
step "1. Zeichenketten und Zähler (atomar)"
r set zaehler 10; r incr zaehler; r incrby zaehler 5; r get zaehler; r type zaehler
step "2. Liste (Warteschlange): hinten anfügen, vorne entnehmen"
r rpush auftraege a1 a2 a3; r lpop auftraege; r lrange auftraege 0 -1; r llen auftraege; r type auftraege
step "3. Hash (Objekt mit Feldern)"
r hset kunde:1 name Anna ort Musterstadt alter 31; r hget kunde:1 ort; r hgetall kunde:1; r hincrby kunde:1 alter 1; r type kunde:1
step "4. Menge (eindeutige Elemente) und Mengenoperationen"
r sadd tags:a rot gruen blau; r sadd tags:b blau gelb; r sadd tags:a rot; r sinter tags:a tags:b; echo "> sunion tags:a tags:b (sortiert)"; rr sunion tags:a tags:b | sort | tr "\n" " "; echo; r scard tags:a
step "5. Sortierte Menge (Rangliste)"
r zadd rang 120 anna 95 ben 150 cara; r zrange rang 0 -1 withscores; r zrevrange rang 0 0; r zrank rang ben; r zincrby rang 60 ben; r zrevrange rang 0 0
step "6. Falscher Typ liefert einen Fehler"
r lpush zaehler x
step "7. Wann welcher Typ? (Text)"
cat <<'T'
Zeichenkette: Einzelwert, Zähler, Zwischenspeicher
Liste       : Warteschlange, neueste Einträge
Hash        : Objekt mit Feldern (zum Beispiel Benutzerprofil)
Menge       : Eindeutigkeit, Schnitt und Vereinigung (Markierungen)
Sortiert    : Ranglisten, nach Punktzahl sortiert
T
