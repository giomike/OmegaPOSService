--取消使用员工折扣
DROP PROCEDURE MPos_CancelStaffDiscount

GO

CREATE PROC MPos_CancelStaffDiscount
  @shop   char(5),
  @cartid uniqueidentifier,
  @key    varchar(255)
AS
    DECLARE @ltVoucher TABLE
    (
       vseqn char( 13 )
       PRIMARY KEY CLUSTERED(vseqn)
    )
    DECLARE @lcvalu varchar(255)
    DECLARE @lcseqn char(13)

    SET @lcvalu=Ltrim(Rtrim(@key))
    SET @lcvalu=Rtrim(@key)

    WHILE Len(@lcvalu) > 1
      BEGIN
          SET @lcseqn=LEFT(@lcvalu, 13)

          INSERT @ltVoucher
                 (vseqn)
          VALUES(@lcseqn)

          SET @lcvalu=RIGHT(@lcvalu, Len(@lcvalu) - 14)
      END

    UPDATE crcart
    SET    discount = 0,
           amnt = price,
           oamnt = price * qty,
           voucherid = ''
    FROM   @ltVoucher
    WHERE  shop = @shop AND
           cartid = @cartid AND
           voucherid = vseqn

Go 
