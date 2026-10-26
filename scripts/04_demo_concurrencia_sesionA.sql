USE BusRD;
GO

DECLARE @ViajeID INT, @Asiento INT, @NuevoBoleto INT;

SELECT TOP 1 
    @ViajeID = v.ViajeID,
    @Asiento = asi.NumeroAsiento
FROM dbo.Viajes v
JOIN dbo.Asientos asi ON asi.AutobusID = v.AutobusID
LEFT JOIN dbo.Boletos b ON b.ViajeID = v.ViajeID 
                       AND b.NumeroAsiento = asi.NumeroAsiento 
                       AND b.Estado = 'Activo'
WHERE v.Estado = 'Programado' 
  AND b.BoletoID IS NULL
ORDER BY v.ViajeID DESC, asi.NumeroAsiento ASC;

PRINT 'Sesion A - Intentando vender ViajeID: ' + CAST(@ViajeID AS VARCHAR(10)) + ', Asiento: ' + CAST(@Asiento AS VARCHAR(10));

EXEC dbo.sp_VenderBoleto
    @ViajeID = @ViajeID,
    @NumeroAsiento = @Asiento,
    @ClienteID = 1,
    @Canal = 'Web',
    @Metodo = 'Tarjeta',
    @SimularDemora = 1,
    @BoletoID = @NuevoBoleto OUTPUT;

SELECT @NuevoBoleto AS BoletoCreado_SesionA;
GO