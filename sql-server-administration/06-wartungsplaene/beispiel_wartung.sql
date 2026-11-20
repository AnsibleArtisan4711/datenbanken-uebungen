-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Wartungsaufgaben als T-SQL
DBCC CHECKDB (LabDB) WITH NO_INFOMSGS;
ALTER INDEX ALL ON dbo.Kunde REORGANIZE;
UPDATE STATISTICS dbo.Kunde;
