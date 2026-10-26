USE BusRD;
GO

-- 1. Limpieza de boletos activos duplicados
WITH Duplicados AS (
    SELECT BoletoID,
           ROW_NUMBER() OVER(
               PARTITION BY ViajeID, NumeroAsiento 
               ORDER BY FechaVenta DESC, BoletoID DESC
           ) AS rn
    FROM dbo.Boletos
    WHERE Estado = 'Activo'
)
DELETE FROM dbo.Boletos
WHERE BoletoID IN (SELECT BoletoID FROM Duplicados WHERE rn > 1);
GO

-- 2. Limpieza de pagos huérfanos
DELETE FROM dbo.Pagos
WHERE BoletoID NOT IN (SELECT BoletoID FROM dbo.Boletos);
GO

-- 3. Llaves Foráneas
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Boletos_Viajes')
    ALTER TABLE dbo.Boletos ADD CONSTRAINT FK_Boletos_Viajes FOREIGN KEY (ViajeID) REFERENCES dbo.Viajes(ViajeID);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Boletos_Clientes')
    ALTER TABLE dbo.Boletos ADD CONSTRAINT FK_Boletos_Clientes FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Pagos_Boletos')
    ALTER TABLE dbo.Pagos ADD CONSTRAINT FK_Pagos_Boletos FOREIGN KEY (BoletoID) REFERENCES dbo.Boletos(BoletoID);
GO

-- 4. Restricciones CHECK y UNIQUE
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Boletos_Estado')
    ALTER TABLE dbo.Boletos ADD CONSTRAINT CK_Boletos_Estado CHECK (Estado IN ('Activo', 'Anulado'));

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Pagos_Monto')
    ALTER TABLE dbo.Pagos ADD CONSTRAINT CK_Pagos_Monto CHECK (Monto <> 0);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_Clientes_Cedula')
    ALTER TABLE dbo.Clientes ADD CONSTRAINT UQ_Clientes_Cedula UNIQUE (Cedula);
GO

-- 5. Índice Único Filtrado
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Boletos_Viaje_Asiento_Activo')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_Boletos_Viaje_Asiento_Activo
    ON dbo.Boletos (ViajeID, NumeroAsiento)
    WHERE Estado = 'Activo';
END
GO