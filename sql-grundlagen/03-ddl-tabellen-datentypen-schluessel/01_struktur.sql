-- 01_struktur.sql: Tabellen der Datenbank firma (Modul 3)
-- Aufgabe 1: Tabellen anlegen
CREATE TABLE abteilung (
    abteilung_id  INTEGER GENERATED ALWAYS AS IDENTITY,
    name          VARCHAR(50) NOT NULL,
    standort      VARCHAR(50)
);

CREATE TABLE mitarbeiter (
    mitarbeiter_id INTEGER GENERATED ALWAYS AS IDENTITY,
    vorname        VARCHAR(50) NOT NULL,
    nachname       VARCHAR(50) NOT NULL,
    email          VARCHAR(100),
    gehalt         NUMERIC(10,2),
    abteilung_id   INTEGER
);

CREATE TABLE projekt (
    projekt_id     INTEGER GENERATED ALWAYS AS IDENTITY,
    bezeichnung    VARCHAR(100) NOT NULL,
    startdatum     DATE,
    abteilung_id   INTEGER
);

-- Aufgabe 2: Constraints
ALTER TABLE abteilung   ADD CONSTRAINT pk_abteilung   PRIMARY KEY (abteilung_id);
ALTER TABLE mitarbeiter ADD CONSTRAINT pk_mitarbeiter PRIMARY KEY (mitarbeiter_id);
ALTER TABLE projekt     ADD CONSTRAINT pk_projekt     PRIMARY KEY (projekt_id);

ALTER TABLE mitarbeiter ADD CONSTRAINT fk_mitarbeiter_abteilung
    FOREIGN KEY (abteilung_id) REFERENCES abteilung (abteilung_id);
ALTER TABLE projekt     ADD CONSTRAINT fk_projekt_abteilung
    FOREIGN KEY (abteilung_id) REFERENCES abteilung (abteilung_id);

ALTER TABLE mitarbeiter ADD CONSTRAINT uq_mitarbeiter_email UNIQUE (email);

-- Aufgabe 3: Spalte ergänzen
ALTER TABLE mitarbeiter ADD COLUMN einstellungsdatum DATE NOT NULL DEFAULT CURRENT_DATE;
