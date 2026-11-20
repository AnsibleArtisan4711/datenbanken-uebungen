-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Wiederherstellung bis zu einem Zeitpunkt
BACKUP LOG LabDB TO DISK = 'F:\Sicherung\LabDB_tail.trn' WITH NORECOVERY;
RESTORE DATABASE LabDB FROM DISK = 'F:\Sicherung\LabDB_voll.bak' WITH NORECOVERY, REPLACE;
RESTORE DATABASE LabDB FROM DISK = 'F:\Sicherung\LabDB_diff.bak' WITH NORECOVERY;
RESTORE LOG LabDB FROM DISK = 'F:\Sicherung\LabDB_log1.trn' WITH NORECOVERY, STOPAT = '2026-11-17T09:00:00';
RESTORE DATABASE LabDB WITH RECOVERY;
