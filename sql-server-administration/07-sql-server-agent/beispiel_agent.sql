-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Agent-Auftrag mit Zeitplan anlegen (msdb-Prozeduren)
USE msdb;
EXEC dbo.sp_add_job @job_name = N'LabDB Log-Sicherung';
EXEC dbo.sp_add_jobstep @job_name = N'LabDB Log-Sicherung', @step_name = N'Sicherung', @subsystem = N'TSQL',
     @command = N'BACKUP LOG LabDB TO DISK = ''F:\Sicherung\LabDB_log.trn'' WITH CHECKSUM';
EXEC dbo.sp_add_jobschedule @job_name = N'LabDB Log-Sicherung', @name = N'stuendlich', @freq_type = 4, @freq_interval = 1,
     @freq_subday_type = 8, @freq_subday_interval = 1;
EXEC dbo.sp_add_jobserver @job_name = N'LabDB Log-Sicherung';
