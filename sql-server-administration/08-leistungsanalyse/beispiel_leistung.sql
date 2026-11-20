-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Wait-Statistik, Sitzungen und Blockierungen lesen
SELECT TOP 10 wait_type, wait_time_ms, waiting_tasks_count FROM sys.dm_os_wait_stats ORDER BY wait_time_ms DESC;
SELECT session_id, blocking_session_id, wait_type, wait_time FROM sys.dm_exec_requests WHERE blocking_session_id <> 0;
