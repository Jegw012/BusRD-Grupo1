USE master;
GO
ALTER DATABASE BusRD SET RECOVERY FULL;
GO

-- 1. Secuencia de respaldos en BusRD
USE BusRD;
GO

BACKUP DATABASE BusRD TO DISK = 'C:\Backups\BusRD\BusRD_Full.bak' WITH FORMAT, INIT;
-- (Se venden 5 boletos)
BACKUP DATABASE BusRD TO DISK = 'C:\Backups\BusRD\BusRD_Diff.bak' WITH FORMAT, INIT;
-- (Se venden 3 boletos)
BACKUP LOG BusRD TO DISK = 'C:\Backups\BusRD\BusRD_Log1.trn' WITH FORMAT, INIT;
-- (Simulación de DELETE accidental)
BACKUP LOG BusRD TO DISK = 'C:\Backups\BusRD\BusRD_TailLog.trn' WITH FORMAT, INIT, NO_TRUNCATE;
GO

-- 2. Restauración puntual con STOPAT en BusRD_Recuperada
USE master;
GO

RESTORE DATABASE BusRD_Recuperada
FROM DISK = 'C:\Backups\BusRD\BusRD_Full.bak'
WITH NORECOVERY,
     MOVE 'BusRD' TO 'C:\Backups\BusRD\BusRD_Recuperada.mdf',
     MOVE 'BusRD_log' TO 'C:\Backups\BusRD\BusRD_Recuperada_log.ldf';

RESTORE DATABASE BusRD_Recuperada
FROM DISK = 'C:\Backups\BusRD\BusRD_Diff.bak'
WITH NORECOVERY;

RESTORE LOG BusRD_Recuperada
FROM DISK = 'C:\Backups\BusRD\BusRD_Log1.trn'
WITH NORECOVERY;

RESTORE LOG BusRD_Recuperada
FROM DISK = 'C:\Backups\BusRD\BusRD_TailLog.trn'
WITH RECOVERY,
     STOPAT = '2026-10-26 12:08:50';
GO