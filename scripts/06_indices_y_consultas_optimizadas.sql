USE BusRD;
GO

-- 1. Creación de Índices Secundarios
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Boletos_ClienteID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Boletos_ClienteID
    ON dbo.Boletos (ClienteID)
    INCLUDE (ViajeID, NumeroAsiento, Precio, Estado);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Boletos_FechaVenta_Estado')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Boletos_FechaVenta_Estado
    ON dbo.Boletos (FechaVenta, Estado)
    INCLUDE (ViajeID);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pagos_BoletoID_Monto')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pagos_BoletoID_Monto
    ON dbo.Pagos (BoletoID)
    INCLUDE (Monto);
END
GO

-- 2. Consultas Sargables
-- C1
DECLARE @ViajeID INT = 16000;
SELECT s.NumeroAsiento, s.Ubicacion
FROM dbo.Viajes v
JOIN dbo.Asientos s ON s.AutobusID = v.AutobusID
WHERE v.ViajeID = @ViajeID
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Boletos b
      WHERE b.ViajeID = v.ViajeID
        AND b.NumeroAsiento = s.NumeroAsiento
        AND b.Estado = 'Activo'
  )
ORDER BY s.NumeroAsiento;
GO

-- C2
DECLARE @Cedula CHAR(11) = '40200001000';
SET @Cedula = LTRIM(RTRIM(@Cedula));

SELECT c.Nombre, c.Apellido, r.Origen, r.Destino,
       v.FechaSalida, b.NumeroAsiento, b.Precio, b.Estado
FROM dbo.Clientes c
JOIN dbo.Boletos b ON b.ClienteID = c.ClienteID
JOIN dbo.Viajes  v ON v.ViajeID   = b.ViajeID
JOIN dbo.Rutas   r ON r.RutaID    = v.RutaID
WHERE c.Cedula = @Cedula
ORDER BY v.FechaSalida DESC;
GO

-- C3
SELECT r.Origen, r.Destino, MONTH(b.FechaVenta) AS Mes,
       COUNT(*) AS Boletos, SUM(p.Monto) AS Ingresos
FROM dbo.Boletos b
JOIN dbo.Pagos  p ON p.BoletoID = b.BoletoID
JOIN dbo.Viajes v ON v.ViajeID  = b.ViajeID
JOIN dbo.Rutas  r ON r.RutaID   = v.RutaID
WHERE b.FechaVenta >= '20250101 00:00:00' 
  AND b.FechaVenta <  '20260101 00:00:00'
  AND b.Estado = 'Activo'
GROUP BY r.Origen, r.Destino, MONTH(b.FechaVenta)
ORDER BY r.Origen, r.Destino, Mes;
GO