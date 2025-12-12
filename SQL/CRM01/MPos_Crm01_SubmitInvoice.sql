DROP PROCEDURE MPos_Crm01_SubmitInvoice;
GO
CREATE PROCEDURE MPos_Crm01_SubmitInvoice
  @marketID CHAR(2),
  @operator       varchar(25), --收银员
  @tranDate       smalldatetime, --销售日期
  @shopID         char(5), --店铺代码
  @crid           char(3), --收银机号
  @invoiceID      int, --发票号
  @cartID         uniqueidentifier, --购物车号
  @memberCard     varchar(25),
  @memberCardType varchar(15),
  @salesAssociate varchar(25),
  @usePromotion   char(1)
AS
    DECLARE @return TABLE
    (
       ReturnID int,ReturnMessage varchar( 256 )
    );

    -- 1. check payment
    IF NOT EXISTS ( SELECT *
                    FROM   dbo.crctdr (NOLOCK) a
                    WHERE  a.cttxdt = @tranDate AND
                           a.ctshop = @shopID AND
                           a.ctcrid = @crid AND
                           a.ctinvo = @invoiceID )
      BEGIN
          INSERT @return
                 (ReturnID,
                  ReturnMessage)
          VALUES ( -1,-- ReturnID - int
                   '没有支付方式' -- ReturnMessage - varchar(256)
          );

          SELECT *
          FROM   @return;

          RETURN;
      END;

    -- 2. check whether  shopping cart is empty.

    IF NOT EXISTS ( SELECT *
                    FROM   crcart (NOLOCK) a
                    WHERE  a.TransDate = @tranDate AND
                           a.Shop = @shopID AND
                           a.Crid = @crid AND
                           a.CartID = @cartID )
      BEGIN
          INSERT @return
                 (ReturnID,
                  ReturnMessage)
          VALUES ( -2,-- ReturnID - int
                   '没有支付方式' -- ReturnMessage - varchar(256)
          );

          SELECT *
          FROM   @return;

          RETURN;
      END;

	--2.5 check crsalh exists
	IF EXISTS(SELECT *
                   FROM   dbo.crsalh a
                   WHERE  a.shtxdt = @tranDate AND
                          a.shshop = @shopID AND
                          a.shcrid = @crid AND
                          a.shinvo = @invoiceID AND a.shupdt='Y'
						  )
		BEGIN
          INSERT @return
                 (ReturnID,
                  ReturnMessage)
          VALUES ( -3,-- ReturnID - int
                   '该发票号码已经有单据了' -- ReturnMessage - varchar(256)
          );

          SELECT *
          FROM   @return;

		END

    -- 3. create crsalh
    IF NOT EXISTS( SELECT *
                   FROM   dbo.crsalh a
                   WHERE  a.shtxdt = @tranDate AND
                          a.shshop = @shopID AND
                          a.shcrid = @crid AND
                          a.shinvo = @invoiceID )
      BEGIN
          DECLARE @t TABLE
          (
             Invo int
          );

          INSERT INTO @t
          EXEC dbo.MPos_Crm01_NewInvo @PCSHOP = @shopID,-- char(5)
                                      @PDTXDT = @tranDate,-- smalldatetime
                                      @PCCRID = @crid -- char(3)

          SELECT @invoiceID = Invo
          FROM   @t;

          INSERT dbo.crsalh
                 (shtxdt,
                  shshop,
                  shcrid,
                  shinvo,
                  shtxtm,
                  shtqty,
                  shamnt,
                  shuser,
                  shupdt,
                  shvoid,
                  shcust,
                  shsalm,
                  shiden,
                  shforw)
          VALUES ( @tranDate,-- shtxdt - smalldatetime
                   @shopID,-- shshop - char(5)
                   @crid,-- shcrid - char(3)
                   @invoiceID,-- shinvo - int
                   GETDATE(),-- shtxtm - smalldatetime
                   0,-- shtqty - int
                   0,-- shamnt - money
                   @operator,-- shuser - char(40)
                   '',-- shupdt - char(1)
                   '',-- shvoid - char(1)
                   @memberCard,-- shcust - char(10)
                   @salesAssociate,-- shsalm - char(40)
                   '',-- shiden - char(12)
                   '' -- shforw - char(10)
          )
      END
	ELSE
		BEGIN
			UPDATE a SET a.shsalm = @salesAssociate, a.shcust = @memberCard, a.shuser = @operator
                   FROM   dbo.crsalh a
                   WHERE  a.shtxdt = @tranDate AND
                          a.shshop = @shopID AND
                          a.shcrid = @crid AND
                          a.shinvo = @invoiceID
        END

-- 4. create crsald
	DELETE FROM a FROM dbo.crsald a WHERE a.sdtxdt = @tranDate AND a.sdshop = @shopID AND a.sdcrid = @crid AND a.sdinvo = @invoiceID

	INSERT dbo.crsald
	(
	    sdtxdt,
	    sdshop,
	    sdcrid,
	    sdinvo,
	    sdseqn,
	    sdtype,
	    sdskun,
	    sdsprc,
	    sdtqty,
	    sddsct,
	    sdvata,
	    sddscd,
	    sdprom
	)

	
	SELECT @tranDate, @shopID, @crid, @invoiceID, a.Seqn, a.ItemType, a.Sku, a.Price, a.Qty, a.OAmnt - a.Amnt,0,a.DiscountID, a.PromotionID
		FROM dbo.crcart a WHERE a.TransDate=@tranDate AND a.Shop = @shopID AND a.Crid = @crid AND a.CartID = @cartID

-- 5. create crctdr
	DELETE FROM a FROM dbo.crctdr A WHERE A.cttxdt = @tranDate AND a.ctshop = @shopID AND a.ctcrid = @crid AND a.ctinvo = @invoiceID

	INSERT dbo.crctdr
		   (cttxdt,
			ctshop,
			ctcrid,
			ctinvo,
			ctmakt,
			cttdrt,
			ctcrdn,
			ctcurr,
			ctlamt,
			ctoamt,
			ctexrt)
	SELECT A.TransDate,A.Shop,A.Crid,@invoiceID,@marketID,a.tdrt,a.code,a.curr,a.lamt,a.oamt,a.extr
	FROM   dbo.crcinv a
	WHERE  a.TransDate = @tranDate AND
		   a.Shop = @shopID AND
		   a.Crid = @crid AND
		   a.CartID = @cartID 
	                                        

-- 6. create crprop
	DELETE FROM a FROM dbo.crprop a WHERE a.cptxdt = @tranDate AND a.cpshop=@shopID AND a.cpcrid=@crid AND a.cpinvo = @invoiceID
	INSERT dbo.crprop
	(
	    cptxdt,
	    cpshop,
	    cpcrid,
	    cpinvo,
	    cpprop,
	    cpvalu
	)
	VALUES
	(   @tranDate, -- cptxdt - smalldatetime
	    @shopID,                    -- cpshop - char(5)
	    @crid,                    -- cpcrid - char(3)
	    @invoiceID,                     -- cpinvo - int
	    'DiscountTicket',                    -- cpprop - varchar(10)
	    ''                   -- cpvalu - nvarchar(2000)
	    )

	
	UPDATE a SET a.shupdt='Y' FROM crsalh a WHERE a.shtxdt= @tranDate AND a.shcrid=@crid AND a.shshop = @shopID AND a.shinvo = @invoiceID

    IF @lnError = 1
      BEGIN
          DELETE FROM crsald
          WHERE  sdshop = @pcShop AND
                 sdtxdt = @pdTxdt AND
                 sdcrid = @pcCrid AND
                 sdinvo = @pnInvo

          DELETE FROM crctdr
          WHERE  ctshop = @pcShop AND
                 cttxdt = @pdTxdt AND
                 ctcrid = @pcCrid AND
                 ctinvo = @pnInvo

          DELETE FROM crprop
          WHERE  cpshop = @pcShop AND
                 cptxdt = @pdTxdt AND
                 cpcrid = @pcCrid AND
                 cpinvo = @pnInvo

          DELETE FROM crsalh
          WHERE  shshop = @pcShop AND
                 shtxdt = @pdTxdt AND
                 shcrid = @pcCrid AND
                 shinvo = @pnInvo
      END

    SELECT @lnError    

GO


