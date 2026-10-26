USE BusRD;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AnularBoleto
    @BoletoID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EstadoActual VARCHAR(10);
    DECLARE @MontoReverso DECIMAL(10,2);
    DECLARE @MetodoPago VARCHAR(15);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @EstadoActual = Estado
        FROM dbo.Boletos WITH (UPDLOCK, ROWLOCK)
        WHERE BoletoID = @BoletoID;

        IF @EstadoActual IS NULL
            THROW 50010, 'El boleto especificado no existe.', 1;

        IF @EstadoActual = 'Anulado'
            THROW 50011, 'El boleto ya se encuentra anulado.', 1;

        UPDATE dbo.Boletos
        SET Estado = 'Anulado'
        WHERE BoletoID = @BoletoID;

        SELECT TOP 1 
            @MontoReverso = -1 * ABS(Monto),
            @MetodoPago = Metodo
        FROM dbo.Pagos
        WHERE BoletoID = @BoletoID AND Monto > 0
        ORDER BY FechaPago DESC;

        IF @MontoReverso IS NOT NULL
        BEGIN
            INSERT INTO dbo.Pagos (BoletoID, Monto, Metodo, FechaPago)
            VALUES (@BoletoID, @MontoReverso, @MetodoPago, SYSDATETIME());
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO