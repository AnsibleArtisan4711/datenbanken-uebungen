-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Version und Edition einer Instanz abfragen
SELECT @@VERSION AS Version;
SELECT SERVERPROPERTY('Edition') AS Edition, SERVERPROPERTY('ProductVersion') AS Produktversion;
