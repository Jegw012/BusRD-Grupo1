USE BusRD;
GO

-- Vistas
CREATE OR ALTER VIEW dbo.vw_AsientosDisponibles
AS
SELECT 
    v.ViajeID, v.FechaSalida, r.Origen, r.Destino,
    s.NumeroAsiento, s.Ubicacion, r.PrecioBase
FROM dbo.Viajes v
JOIN dbo.Rutas r     ON r.RutaID = v.RutaID
JOIN dbo.Asientos s  ON s.AutobusID = v.AutobusID
WHERE v.Estado = 'Programado'
  AND NOT EXISTS (
      SELECT 1 FROM dbo.Boletos b
      WHERE b.ViajeID = v.ViajeID
        AND b.NumeroAsiento = s.NumeroAsiento
        AND b.Estado = 'Activo'
  );
GO

CREATE OR ALTER VIEW dbo.vw_VentasMensuales
AS
SELECT 
    r.Origen, r.Destino,
    YEAR(b.FechaVenta)  AS Anio,
    MONTH(b.FechaVenta) AS Mes,
    COUNT(b.BoletoID)   AS TotalBoletosVendidos,
    SUM(p.Monto)        AS TotalIngresos
FROM dbo.Boletos b
JOIN dbo.Pagos p  ON p.BoletoID = b.BoletoID
JOIN dbo.Viajes v ON v.ViajeID = b.ViajeID
JOIN dbo.Rutas r  ON r.RutaID = v.RutaID
WHERE b.Estado = 'Activo'
GROUP BY r.Origen, r.Destino, YEAR(b.FechaVenta), MONTH(b.FechaVenta);
GO

-- Roles
IF DATABASE_PRINCIPAL_ID('rol_taquilla') IS NULL CREATE ROLE rol_taquilla;
IF DATABASE_PRINCIPAL_ID('rol_reportes') IS NULL CREATE ROLE rol_reportes;
IF DATABASE_PRINCIPAL_ID('rol_admin') IS NULL    CREATE ROLE rol_admin;
GO

-- Permisos
GRANT EXECUTE ON dbo.sp_VenderBoleto TO rol_taquilla;
GRANT EXECUTE ON dbo.sp_AnularBoleto TO rol_taquilla;
GRANT SELECT ON dbo.vw_AsientosDisponibles TO rol_taquilla;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Boletos TO rol_taquilla;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Pagos TO rol_taquilla;

GRANT SELECT ON dbo.vw_VentasMensuales TO rol_reportes;
GRANT SELECT ON dbo.Clientes TO rol_reportes;
DENY SELECT ON dbo.Clientes(Email, Telefono) TO rol_reportes;

ALTER ROLE db_owner ADD MEMBER rol_admin;
GO

-- Usuarios
IF USER_ID('usr_taquilla_test') IS NOT NULL DROP USER usr_taquilla_test;
CREATE USER usr_taquilla_test WITHOUT LOGIN;
ALTER ROLE rol_taquilla ADD MEMBER usr_taquilla_test;

IF USER_ID('usr_reportes_test') IS NOT NULL DROP USER usr_reportes_test;
CREATE USER usr_reportes_test WITHOUT LOGIN;
ALTER ROLE rol_reportes ADD MEMBER usr_reportes_test;

IF USER_ID('usr_admin_test') IS NOT NULL DROP USER usr_admin_test;
CREATE USER usr_admin_test WITHOUT LOGIN;
ALTER ROLE rol_admin ADD MEMBER usr_admin_test;
GO