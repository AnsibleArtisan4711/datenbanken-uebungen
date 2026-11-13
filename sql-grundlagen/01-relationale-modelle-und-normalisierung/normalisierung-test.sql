-- normalisierung-test.sql (Modul 1, Prüfhilfe der Ausarbeitung)
-- Läuft in einer Wegwerf-Datenbank (nicht in firma): prüft, dass die Zerlegung der Flat-File in drei Tabellen verlustfrei ist.
-- Aufruf: createdb normtest; psql -d normtest -f normalisierung-test.sql; dropdb normtest

\echo === Ausgangstabelle (Flat-File aus flatfile.csv)
CREATE TABLE flat (
    mitarbeitername  TEXT,
    email            TEXT,
    gehalt           NUMERIC(10,2),
    abteilungsname   TEXT,
    standort         TEXT,
    projektbezeichnung TEXT,
    projektstart     DATE
);
INSERT INTO flat VALUES
 ('Anna Müller',   'anna.mueller@example.com',  3800.00, 'Technik',    'Linz', 'Netzwerkmodernisierung', DATE '2026-02-01'),
 ('Peter Maier',   'peter.maier@example.com',   4200.00, 'Technik',    'Linz', 'Netzwerkmodernisierung', DATE '2026-02-01'),
 ('Karl Huber',    'karl.huber@example.com',    3600.00, 'Technik',    'Linz', 'Netzwerkmodernisierung', DATE '2026-02-01'),
 ('Eva Berger',    NULL,                        3100.00, 'Verwaltung', 'Wien', NULL,                     NULL),
 ('Lukas Steiner', 'lukas.steiner@example.com', 4500.00, 'Vertrieb',   'Graz', 'Kundenportal',           DATE '2026-05-15');
SELECT * FROM flat;

\echo === Anomalien in der Flat-File (jeweils in einer Transaktion, danach zurückgerollt)
BEGIN;
-- Update-Anomalie: Der Standort von Technik ändert sich, aber nur eine Zeile wird angepasst
UPDATE flat SET standort = 'Salzburg' WHERE mitarbeitername = 'Anna Müller';
SELECT abteilungsname, standort, COUNT(*) FROM flat GROUP BY abteilungsname, standort ORDER BY 1, 2;
ROLLBACK;
BEGIN;
-- Delete-Anomalie: Mit Lukas Steiner verschwinden Abteilung Vertrieb, Standort Graz und das Projekt Kundenportal
DELETE FROM flat WHERE mitarbeitername = 'Lukas Steiner';
SELECT DISTINCT abteilungsname, projektbezeichnung FROM flat ORDER BY 1;
ROLLBACK;
-- Insert-Anomalie: Eine neue Abteilung ohne Mitarbeiter lässt sich nur mit einem Scheineintrag speichern
-- (mitarbeitername ist hier nicht NOT NULL; mit einem Schlüssel auf mitarbeitername wäre die Zeile unmöglich)

\echo === 1NF: Namen zerlegen, Schlüssel ergänzen
CREATE TABLE nf1 AS
SELECT ROW_NUMBER() OVER (ORDER BY mitarbeitername) AS mitarbeiter_id,
       split_part(mitarbeitername, ' ', 1) AS vorname,
       split_part(mitarbeitername, ' ', 2) AS nachname,
       email, gehalt, abteilungsname, standort, projektbezeichnung, projektstart
FROM flat;
ALTER TABLE nf1 ADD PRIMARY KEY (mitarbeiter_id);
SELECT * FROM nf1 ORDER BY mitarbeiter_id;

\echo === 2NF: einspaltiger Schlüssel, daher keine Teilabhängigkeit; Prüfung der Abhängigkeiten
-- Jede Spalte hängt vom ganzen Schlüssel ab. Prüfung der funktionalen Abhängigkeit Abteilung -> Standort und Abteilung -> Projekt:
SELECT abteilungsname, COUNT(DISTINCT standort) AS standorte, COUNT(DISTINCT projektbezeichnung) AS projekte FROM nf1 GROUP BY abteilungsname ORDER BY 1;

\echo === 3NF: transitive Abhängigkeiten herauslösen (Mitarbeiter -> Abteilung -> Standort, Projekt)
CREATE TABLE abteilung AS
SELECT ROW_NUMBER() OVER (ORDER BY abteilungsname) AS abteilung_id, abteilungsname AS name, standort
FROM (SELECT DISTINCT abteilungsname, standort FROM nf1) x;
CREATE TABLE projekt AS
SELECT ROW_NUMBER() OVER (ORDER BY p.projektbezeichnung) AS projekt_id, p.projektbezeichnung AS bezeichnung, p.projektstart AS startdatum, a.abteilung_id
FROM (SELECT DISTINCT abteilungsname, projektbezeichnung, projektstart FROM nf1 WHERE projektbezeichnung IS NOT NULL) p
JOIN abteilung a ON a.name = p.abteilungsname;
CREATE TABLE mitarbeiter AS
SELECT n.mitarbeiter_id, n.vorname, n.nachname, n.email, n.gehalt, a.abteilung_id
FROM nf1 n JOIN abteilung a ON a.name = n.abteilungsname;
SELECT * FROM abteilung ORDER BY abteilung_id;
SELECT * FROM projekt ORDER BY projekt_id;
SELECT * FROM mitarbeiter ORDER BY mitarbeiter_id;

\echo === Probe: Die Zerlegung ist verlustfrei (beide Differenzen müssen leer sein)
CREATE VIEW rekonstruiert AS
SELECT m.vorname || ' ' || m.nachname AS mitarbeitername, m.email, m.gehalt, a.name AS abteilungsname, a.standort, p.bezeichnung AS projektbezeichnung, p.startdatum AS projektstart
FROM mitarbeiter m JOIN abteilung a ON a.abteilung_id = m.abteilung_id LEFT JOIN projekt p ON p.abteilung_id = a.abteilung_id;
SELECT 'in flat, nicht rekonstruiert' AS richtung, COUNT(*) FROM (SELECT * FROM flat EXCEPT SELECT * FROM rekonstruiert) d
UNION ALL
SELECT 'rekonstruiert, nicht in flat', COUNT(*) FROM (SELECT * FROM rekonstruiert EXCEPT SELECT * FROM flat) d;
