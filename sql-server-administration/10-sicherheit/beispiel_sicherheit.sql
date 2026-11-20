-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Konto sa deaktivieren und Rechte eines Benutzers prüfen
ALTER LOGIN sa DISABLE;
SELECT dp.name, rp.name AS rolle FROM sys.database_role_members m
JOIN sys.database_principals dp ON dp.principal_id = m.member_principal_id
JOIN sys.database_principals rp ON rp.principal_id = m.role_principal_id;
