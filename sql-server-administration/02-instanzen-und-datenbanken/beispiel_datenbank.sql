-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Datenbank mit getrennten Daten- und Protokolldateien
CREATE DATABASE LabDB
ON PRIMARY (NAME = LabDB_Daten, FILENAME = 'D:\Daten\LabDB.mdf', SIZE = 512MB, FILEGROWTH = 256MB)
LOG ON     (NAME = LabDB_Log,   FILENAME = 'E:\Log\LabDB.ldf',   SIZE = 256MB, FILEGROWTH = 128MB);
GO
SELECT name, physical_name, size*8/1024 AS groesse_mb, growth FROM LabDB.sys.database_files;
