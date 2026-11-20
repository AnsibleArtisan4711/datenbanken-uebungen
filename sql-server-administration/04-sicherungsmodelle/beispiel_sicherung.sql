-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Sicherungsarten
ALTER DATABASE LabDB SET RECOVERY FULL;
BACKUP DATABASE LabDB TO DISK = 'F:\Sicherung\LabDB_voll.bak' WITH CHECKSUM, INIT;
BACKUP DATABASE LabDB TO DISK = 'F:\Sicherung\LabDB_diff.bak' WITH DIFFERENTIAL, CHECKSUM, INIT;
BACKUP LOG      LabDB TO DISK = 'F:\Sicherung\LabDB_log1.trn' WITH CHECKSUM, INIT;
RESTORE VERIFYONLY FROM DISK = 'F:\Sicherung\LabDB_voll.bak' WITH CHECKSUM;
