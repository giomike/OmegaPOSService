DROP PROC MPos_Crm01_CleanCartPayment
go
CREATE PROC MPos_Crm01_CleanCartPayment
  @TransDate smalldatetime,
  @Shop      char(5),
  @Crid      char(3),
  @CartID    uniqueidentifier
AS
    DELETE crcinv
    WHERE  TransDate = @TransDate AND
           shop = @Shop AND
           Crid = @Crid AND
           CartID = @CartID
go 
