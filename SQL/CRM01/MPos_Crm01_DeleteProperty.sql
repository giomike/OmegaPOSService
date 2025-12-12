DROP PROC MPos_Crm01_DeleteProperty
go
CREATE PROC MPos_Crm01_DeleteProperty
  @pdTxdt smalldatetime,
  @pdShop char(5),
  @pcCrid char(3),
  @pnInvo int,
  @pcProp varchar(10)
AS
    SELECT *
    FROM   crprop
    WHERE  cptxdt = @pdTxdt AND
           cpshop = @pdShop AND
           cpcrid = @pcCrid AND
           cpinvo = @pnInvo AND
           cpprop LIKE rtrim(@pcProp) + '%'
go 
