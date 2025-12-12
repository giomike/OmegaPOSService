
DROP PROC MPos_Crm01_DeleteCartItem

GO

CREATE PROC MPos_Crm01_DeleteCartItem
  @TransDate SMALLDATETIME,
  @Shop      CHAR(5),
  @Crid      CHAR(3),
  @CartID    UNIQUEIDENTIFIER,
  @Seqn      INT
AS
    SET XACT_ABORT ON

    BEGIN TRANSACTION

    DELETE crcart
    WHERE  TransDate = @TransDate AND
           Shop = @Shop AND
           Crid = @Crid AND
           CartID = @CartID AND
           Seqn = @Seqn

    COMMIT TRAN

go 
