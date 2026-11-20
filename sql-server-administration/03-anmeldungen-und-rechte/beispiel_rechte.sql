-- BEISPIEL (nicht ausgeführt, nicht bestätigt): Anmeldung, Datenbankbenutzer und Rolle
CREATE LOGIN [LAB\gruppe-lesen] FROM WINDOWS;
USE ShopDB;
CREATE USER [LAB\gruppe-lesen] FOR LOGIN [LAB\gruppe-lesen];
ALTER ROLE db_datareader ADD MEMBER [LAB\gruppe-lesen];
