-- 02_daten.sql: Beispieldaten der Datenbank firma (Modul 4)
-- Reihenfolge: zuerst abteilung, dann mitarbeiter und projekt (Fremdschlüssel)
INSERT INTO abteilung (name, standort) VALUES
    ('Verwaltung', 'Wien'),
    ('Technik',    'Linz'),
    ('Vertrieb',   'Graz');

INSERT INTO mitarbeiter (vorname, nachname, email, gehalt, abteilung_id, einstellungsdatum) VALUES
    ('Anna',  'Müller',  'anna.mueller@example.com',  3800.00, 2, DATE '2019-03-01'),
    ('Peter', 'Maier',   'peter.maier@example.com',   4200.00, 2, DATE '2021-09-15'),
    ('Karl',  'Huber',   'karl.huber@example.com',    3600.00, 2, DATE '2023-01-10'),
    ('Eva',   'Berger',  NULL,                        3100.00, 1, DATE '2020-06-01'),
    ('Lukas', 'Steiner', 'lukas.steiner@example.com', 4500.00, 3, DATE '2022-11-01');

INSERT INTO projekt (bezeichnung, startdatum, abteilung_id) VALUES
    ('Netzwerkmodernisierung', DATE '2026-02-01', 2),
    ('Kundenportal',           DATE '2026-05-15', 3);
