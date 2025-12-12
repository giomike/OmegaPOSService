DROP PROC MPos_Crm01_CleanCart

go

CREATE PROC MPos_Crm01_CleanCart
  @TransDate smalldatetime,
  @Shop      char(5),
  @Crid      char(3),
  @CartID    uniqueidentifier
AS
    DELETE crcarh
    WHERE  TransDate = @TransDate AND
           Shop = @Shop AND
           Crid = @Crid AND
           CartID = @CartID

    DELETE crcart
    WHERE  TransDate = @TransDate AND
           Shop = @Shop AND
           Crid = @Crid AND
           CartID = @CartID

    DELETE crcinv
    WHERE  TransDate = @TransDate AND
           Shop = @Shop AND
           Crid = @Crid AND
           CartID = @CartID

go 
