USE BusRD;
GO

CREATE OR ALTER PROCEDURE dbo.sp_VenderBoleto
    @ViajeID INT,
    @NumeroAsiento INT,
    @ClienteID INT,
    @Canal VARCHAR(10),
    @Metodo VARCHAR(15),
    @SimularDemora BIT = 0,
    @BoletoID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Precio DECIMAL(10,2);
    DECLARE @AutobusID INT;
    DECLARE @Capacidad INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @AutobusID = v.AutobusID, @Precio = r.PrecioBase
        FROM dbo.Viajes v WITH (UPDLOCK, HOLDLOCK)
        JOIN dbo.Rutas r ON r.RutaID = v.RutaID
        WHERE v.ViajeID = @ViajeID AND v.Estado = 'Programado';

        IF @AutobusID IS NULL
            THROW 50001, 'El viaje no existe o no se encuentra en estado Programado.', 1;

        SELECT @Capacidad = Capacidad FROM dbo.Autobuses WHERE AutobusID = @AutobusID;
        IF @NumeroAsiento < 1 OR @NumeroAsiento > @Capacidad
            THROW 50002, 'El número de asiento no corresponde al autobús asignado.', 1;

        IF EXISTS (
            SELECT 1 
            FROM dbo.Boletos WITH (UPDLOCK, HOLDLOCK)
            WHERE ViajeID = @ViajeID 
              AND NumeroAsiento = @NumeroAsiento 
              AND Estado = 'Activo'
        )
            THROW 50006, 'El asiento ya se encuentra vendido para este viaje.', 1;

        IF @SimularDemora = 1
            WAITFOR DELAY '00:00:10';

        INSERT INTO dbo.Boletos (ViajeID, NumeroAsiento, ClienteID, FechaVenta, Canal, Precio, Estado)
        VALUES (@ViajeID, @NumeroAsiento, @ClienteID, SYSDATETIME(), @Canal, @Precio, 'Activo');

        SET @BoletoID = SCOPE_IDENTITY();

        INSERT INTO dbo.Pagos (BoletoID, Monto, Metodo, FechaPago)
        VALUES (@BoletoID, @Precio, @Metodo, SYSDATETIME());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO