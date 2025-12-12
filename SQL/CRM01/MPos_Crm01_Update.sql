DROP PROC MPos_Crm01_Update

go

CREATE PROCEDURE MPos_Crm01_Update
  @pcShop      char(5),
  @pdTxdt      smalldatetime,
  @pcCrid      char(3),
  @pnInvo      int,
  @pmDiscAmt   money=0,
  @pmRedeemAmt money=0,
  @pcPromId    nvarchar(200)='',
  @pnRedeemQty smallint=0
AS
    DECLARE @lmCamt money
    DECLARE @lmIamt money
    DECLARE @lnShft int
    DECLARE @lcMakt char(2)
    DECLARE @lnVatr decimal(5, 2)
    DECLARE @lnDEC smallint
    DECLARE @lcCard char(10)
    DECLARE @lcKind char(3)
    DECLARE @lcIden char(10)
    DECLARE @lmEdcr money
    DECLARE @lmEdpt money
    DECLARE @lnOdds smallint
    DECLARE @lnFixc smallint
    DECLARE @lnCurc smallint
    DECLARE @lcPomo varchar(12)
    DECLARE @lcMeed char(1)
    DECLARE @lnDInv int
    DECLARE @lnDQty int
    DECLARE @lnDamt money
    DECLARE @lnRInv int
    DECLARE @lnRQty int
    DECLARE @lnRAmt money
    DECLARE @lnTqty int
    DECLARE @lnTAmt money
    DECLARE @lnError int
    DECLARE @lcPara char(40)

    SELECT @lcPara = CONVERT(char(8), @pdTxdt, 112) + '  ' + @pcshop
                     + @pcCrid + CONVERT(char(5), @pnInvo)

    --????coupon      
    DECLARE @lnXCouponSum money
    DECLARE @lnXCrsaldSum money
    DECLARE @lnXShareSum money
    DECLARE @lnXCrsaldMaxAmntSeqn int
    DECLARE @lnXCrsaldMaxAmnt money
    DECLARE @tctdr TABLE
    (
       tttdrt char( 1 ),
       ttcurr char( 3 ),
       ttlamt money,
       ttoamt money
    )

    SELECT @lcMakt = shmakt
    FROM   mfshop(nolock)
    WHERE  shshop = @pcShop

    SELECT @lnVatr = CONVERT(decimal(5, 2), cnvalu)
    FROM   syconf
    WHERE  cnshop = @pcShop AND
           rtrim(cnprop) = 'VATRATE'

    SELECT @lnDEC = CASE
                      WHEN cnvalu = '' THEN 2
                      ELSE CONVERT(smallint, cnvalu)
                    END
    FROM   syconf
    WHERE  cnshop = @pcShop AND
           rtrim(cnprop) = 'TDECIMAL'

    SELECT @lmIamt = sum(CASE
                           WHEN sdtype = 'S' THEN sdtqty * sdsprc - sddsct
                           ELSE sddsct - sdtqty * sdsprc
                         END)
    FROM   crsald
    WHERE  sdshop = @pcShop AND
           sdtxdt = @pdTxdt AND
           sdcrid = @pcCrid AND
           sdinvo = @pnInvo

    SELECT @lmCamt = sum(ctlamt)
    FROM   crctdr
    WHERE  ctshop = @pcShop AND
           cttxdt = @pdTxdt AND
           ctcrid = @pcCrid AND
           ctinvo = @pnInvo

    SELECT @lnShft = dhshft
    FROM   crcdwh
    WHERE  dhtxdt = @pdtxdt AND
           dhshop = @pcShop AND
           dhcrid = @pcCrid AND
           dhfinv <= @pnInvo AND
           dhtinv >= @pnInvo

    IF @lnShft IS NULL
      SELECT @lnShft = dhshft
      FROM   crcdwh
      WHERE  dhtxdt = @pdtxdt AND
             dhshop = @pcShop AND
             dhcrid = @pcCrid AND
             rtrim(dhclrf) = ''

    IF @lmCamt IS NULL
      SET @lmCamt = 0

    SET @lmCamt = @lmCamt + @pmDiscAmt
    SET @lcMeed = 'N'

    IF @lmCamt = @lmIamt  OR
       floor(@lmCamt) = floor(@lmIamt)  OR
       ceiling(@lmCamt) = ceiling(@lmIamt)  OR
       floor(@lmCamt) = ceiling(@lmIamt)  OR
       ceiling(@lmCamt) = floor(@lmIamt)  OR
       round(@lmCamt, @lnDEC, abs(@lnDEC)) = round(@lmIamt, @lnDEC, abs(@lnDEC))
      BEGIN
          SET xact_abort ON

          BEGIN TRANSACTION

          SELECT @lnXCouponSum = sum(ctlamt)
          FROM   crctdr,mftdrt
          WHERE  cttdrt = tdtdrt AND
                 ctmakt = tdmakt AND
                 ctshop = @pcShop AND
                 cttxdt = @pdTxdt AND
                 ctcrid = @pcCrid AND
                 ctinvo = @pnInvo AND
                 tdtype&1 = 1

          IF @lnXCouponSum IS NULL
            SET @lnXCouponSum = 0

          SET @lnXCouponSum = @lnXCouponSum + @pmDiscAmt

          IF @lnXCouponSum > 0
            BEGIN
                SELECT @lnXCrsaldSum = sum(sdsprc * sdtqty - sddsct)
                FROM   crsald
                WHERE  sdshop = @pcShop AND
                       sdtxdt = @pdTxdt AND
                       sdcrid = @pcCrid AND
                       sdinvo = @pnInvo AND
                       sdtype = 'S'

                SELECT @lnXShareSum = sum(floor(( ( sdsprc * sdtqty - sddsct ) / @lnXCrsaldSum ) * @lnXCouponSum))
                FROM   crsald
                WHERE  sdshop = @pcShop AND
                       sdtxdt = @pdTxdt AND
                       sdcrid = @pcCrid AND
                       sdinvo = @pnInvo AND
                       sdtype = 'S'

                UPDATE crsald
                SET    sddsct = sddsct
                                + floor(((sdsprc*sdtqty-sddsct)/@lnXCrsaldSum) * @lnXCouponSum)
                WHERE  sdshop = @pcShop AND
                       sdtxdt = @pdTxdt AND
                       sdcrid = @pcCrid AND
                       sdinvo = @pnInvo AND
                       sdtype = 'S'

                IF @lnXShareSum <> @lnXCouponSum
                  BEGIN
                      SELECT @lnXCrsaldMaxAmnt = max(sdsprc * sdtqty - sddsct)
                      FROM   crsald
                      WHERE  sdshop = @pcShop AND
                             sdtxdt = @pdTxdt AND
                             sdcrid = @pcCrid AND
                             sdinvo = @pnInvo AND
                             sdtype = 'S'

                      SELECT @lnXCrsaldMaxAmntSeqn = sdseqn
                      FROM   crsald
                      WHERE  sdshop = @pcShop AND
                             sdtxdt = @pdTxdt AND
                             sdcrid = @pcCrid AND
                             sdinvo = @pnInvo AND
                             sdtype = 'S' AND
                             ( sdsprc * sdtqty - sddsct ) = @lnXCrsaldMaxAmnt

                      UPDATE crsald
                      SET    sddsct = sddsct + ( @lnXCouponSum - @lnXShareSum )
                      WHERE  sdshop = @pcShop AND
                             sdtxdt = @pdTxdt AND
                             sdcrid = @pcCrid AND
                             sdinvo = @pnInvo AND
                             sdtype = 'S' AND
                             sdseqn = @lnXCrsaldMaxAmntSeqn
                  END

                IF @lnVatr > 0
                  UPDATE crsald
                  SET    sdvata = ( sdsprc * sdtqty - sddsct ) * @lnVatr / ( 1 + @lnVatr )
                  WHERE  sdshop = @pcShop AND
                         sdtxdt = @pdTxdt AND
                         sdcrid = @pcCrid AND
                         sdinvo = @pnInvo

            /*      
                           delete from crctdr      
                              from mftdrt      
                              where ctshop=@pcShop and cttxdt=@pdTxdt and ctcrid=@pcCrid and ctinvo=@pnInvo and    
                                    ctmakt=@lcMakt and ctmakt=tdmakt and cttdrt=tdtdrt and tdtype & 1 = 1   
            */
                --????????  
                IF EXISTS( SELECT *
                           FROM   crctdr
                           WHERE  ctshop = @pcShop AND
                                  cttxdt = @pdTxdt AND
                                  ctcrid = @pcCrid AND
                                  ctinvo = @pnInvo ) AND
                   EXISTS( SELECT *
                           FROM   crprop
                           WHERE  cpshop = @pcShop AND
                                  cptxdt = @pdTxdt AND
                                  cpcrid = @pcCrid AND
                                  cpinvo = @pnInvo AND
                                  cpprop = 'RODSkunLST' AND
                                  cpvalu IS NOT NULL AND
                                  RTRIM(cpvalu) <> '' )
                  BEGIN
                      DECLARE @remoteOrderSkuList nvarchar(2000)

                      SELECT @remoteOrderSkuList = RTRIM(cpvalu)
                      FROM   crprop(nolock)
                      WHERE  cpshop = @pcShop AND
                             cptxdt = @pdTxdt AND
                             cpcrid = @pcCrid AND
                             cpinvo = @pnInvo AND
                             cpprop = 'RODSkunLST'

                      DECLARE @loop int
                      DECLARE @remoteOrderItems TABLE
                      (
                         SkunId char( 15 ),
                         Qty    smallint,
                         Amount smallmoney
                      )

                      SET @loop = 0

                      WHILE EXISTS( SELECT *
                                    FROM   fn_SplitStrEx(@remoteOrderSkuList, ';')
                                    WHERE  row = @loop )
                        BEGIN
                            DECLARE @item varchar(100)

                            SET @item = ''

                            SELECT @item = col
                            FROM   fn_SplitStrEx(@remoteOrderSkuList, ';')
                            WHERE  row = @loop

                            DECLARE @skunID char(15)
                            DECLARE @qty smallint
                            DECLARE @amount smallmoney

                            SELECT @skunID = col
                            FROM   fn_SplitStrEx(@item, ',')
                            WHERE  row = 0

                            SELECT @qty = CONVERT(smallint, col)
                            FROM   fn_SplitStrEx(@item, ',')
                            WHERE  row = 1

                            SELECT @amount = CONVERT(smallmoney, col)
                            FROM   fn_SplitStrEx(@item, ',')
                            WHERE  row = 2

                            INSERT @remoteOrderItems
                            VALUES(@skunID,@qty,@amount)

                            SET @loop = @loop + 1
                        END

                      UPDATE @remoteOrderItems
                      SET    Amount = ( ( sdsprc * sdtqty - sddsct ) / sdtqty ) * Qty
                      FROM   crsald
                      WHERE  sdshop = @pcShop AND
                             sdtxdt = @pdTxdt AND
                             sdcrid = @pcCrid AND
                             sdinvo = @pnInvo AND
                             sdskun = SkunId AND
                             sdtype = 'S' AND
                             sdtqty > 0

                      DECLARE @RODSkunList varchar(4000)

                      SET @RODSkunList = ''

                      SELECT @RODSkunList = @RODSkunList + SkunID + ','
                                            + ltrim(rtrim(CONVERT(varchar, Qty))) + ','
                                            + LTRIM(rtrim(CONVERT(varchar, amount))) + ';'
                      FROM   @remoteOrderItems

                      IF LEN(rtrim(@RODSkunList)) > 0
                        SET @RODSkunList = LEFT(@RODSkunList, LEN(RTRIM(@RODSkunList)) - 1)

                      UPDATE crprop
                      SET    cpvalu = @RODSkunList
                      WHERE  cpshop = @pcShop AND
                             cptxdt = @pdTxdt AND
                             cpcrid = @pcCrid AND
                             cpinvo = @pnInvo AND
                             cpprop = 'RODSkunLST'
                  END
            END

          IF @lnVatr < 0
            UPDATE crsald
            SET    sdvata = ( sdsprc * sdtqty - sddsct ) * ( 0 - @lnVatr ),
                   sdsprc = sdsprc * ( 1 - @lnVatr ),
                   sddsct = sddsct * ( 1 - @lnVatr )
            WHERE  sdshop = @pcShop AND
                   sdtxdt = @pdTxdt AND
                   sdcrid = @pcCrid AND
                   sdinvo = @pnInvo

          SELECT @lnTqty = sum(CASE
                                 WHEN sdtype = 'S' THEN sdtqty
                                 ELSE -sdtqty
                               END),@lnTamt = sum(CASE
                                                    WHEN sdtype = 'S' THEN sdsprc * sdtqty - sddsct
                                                    ELSE -sdsprc * sdtqty + sddsct
                                                  END),@lnRqty = sum(CASE
                                                                       WHEN sdtype = 'R' THEN sdtqty
                                                                       ELSE 0
                                                                     END),@lnRamt = sum(CASE
                                                                                          WHEN sdtype = 'R' THEN sdsprc * sdtqty - sddsct
                                                                                          ELSE 0
                                                                                        END),@lnDqty = sum(CASE sddsct
                                                                                                             WHEN 0 THEN 0
                                                                                                             ELSE
                                                                                                               CASE sdtype
                                                                                                                 WHEN 'S' THEN sdtqty
                                                                                                                 ELSE -sdtqty
                                                                                                               END
                                                                                                           END),@lnDamt = sum(CASE sddsct
                                                                                                                                WHEN 0 THEN 0
                                                                                                                                ELSE
                                                                                                                                  CASE sdtype
                                                                                                                                    WHEN 'S' THEN sddsct
                                                                                                                                    ELSE -sddsct
                                                                                                                                  END
                                                                                                                              END)
          FROM   crsald
          WHERE  sdshop = @pcShop AND
                 sdtxdt = @pdTxdt AND
                 sdcrid = @pcCrid AND
                 sdinvo = @pnInvo

          SELECT @lnDinv = 0,@lnRinv = 0

          IF @lnRqty > 0
            SELECT @lnRInv = 1
          ELSE
            SELECT @lnRinv = 0

          IF @lnDamt <> 0 AND
             @lnTamt <> 0
            SELECT @lnDinv = 1
          ELSE
            SELECT @lnDinv = 0,@lnDamt = 0,@lnDqty = 0

          INSERT @tctdr
                 (tttdrt,ttcurr,ttlamt,ttoamt)
          SELECT cttdrt,ctcurr,ctlamt=sum(ctlamt),ctoamt=sum(ctoamt)
          FROM   crctdr
          WHERE  cttxdt = @pdTxdt AND
                 ctshop = @pcShop AND
                 ctcrid = @pcCrid AND
                 ctinvo = @pnInvo
          GROUP  BY cttdrt,ctcurr

          IF NOT EXISTS( SELECT *
                         FROM   syproc
                         WHERE  prshop = @pcShop AND
                                prtype = 'CRSAL' AND
                                prtxnt = @lcpara )
            INSERT syproc
                   (prshop,prtype,prtxnt)
            VALUES (@pcShop,'CRSAL',@lcpara)

          UPDATE crcdwh
          SET    dhdinv = dhdinv + @lnDinv,
                 dhdqty = dhdqty + @lnDqty,
                 dhdamt = dhdamt + @lnDamt,
                 dhrinv = dhrinv + @lnRinv,
                 dhrqty = dhrqty + @lnRqty,
                 dhramt = dhramt + @lnramt
          WHERE  dhtxdt = @pdTxdt AND
                 dhshop = @pcShop AND
                 dhcrid = @pcCrid AND
                 dhshft = @lnShft

          UPDATE crcdwd
          SET    ddlamt = ddlamt + ttlamt,
                 ddoamt = ddoamt + ttoamt
          FROM   @tctdr
          WHERE  ddtxdt = @pdTxdt AND
                 ddshop = @pcShop AND
                 ddcrid = @pcCrid AND
                 ddshft = @lnShft AND
                 ddtdrt = tttdrt AND
                 ddcurr = ttcurr

          INSERT crcdwd
                 (ddtxdt,ddshop,ddcrid,ddshft,ddmakt,ddtdrt,ddcurr,ddlamt,ddoamt,ddaamt)
          SELECT @pdTxdt,@pcShop,@pcCrid,@lnShft,@lcMakt,tttdrt,ttcurr,ttlamt,ttoamt,0
          FROM   @tctdr
          WHERE  NOT EXISTS( SELECT *
                             FROM   crcdwd
                             WHERE  ddtxdt = @pdTxdt AND
                                    ddshop = @pcShop AND
                                    ddcrid = @pcCrid AND
                                    ddshft = @lnShft AND
                                    ddtdrt = tttdrt AND
                                    ddcurr = ttcurr )

          IF @pmDiscAmt <> 0
            BEGIN
                DECLARE @lcDiscAmt nvarchar(200)

                SET @lcDiscAmt = CONVERT(nvarchar(200), @pmDiscAmt)

                EXEC ap_Crm01_InsertProperty @pdTxdt,@pcShop,@pcCrid,@pnInvo,'INVDISCAMT',@lcDiscAmt
            END

          IF @pmRedeemAmt <> 0
            BEGIN
                DECLARE @lcRedeemAmt nvarchar(200)

                SET @lcRedeemAmt = CONVERT(nvarchar(200), @pmRedeemAmt)

                EXEC ap_Crm01_InsertProperty @pdTxdt,@pcShop,@pcCrid,@pnInvo,'REDEEMAMT',@lcRedeemAmt
            END

          IF @pnRedeemQty <> 0
            BEGIN
                DECLARE @lcRedeemQty nvarchar(200)

                SET @lcRedeemQty = CONVERT(nvarchar(200), @pnRedeemQty)

                EXEC ap_Crm01_InsertProperty @pdTxdt,@pcShop,@pcCrid,@pnInvo,'REDEEMQTY',@lcRedeemQty
            END

          IF len(@pcPromId) > 0
            BEGIN
                EXEC ap_Crm01_InsertProperty @pdTxdt,@pcShop,@pcCrid,@pnInvo,'NOSTORHIST',@pcPromId
            END

          UPDATE crsalh
          SET    shtqty = @lnTqty,
                 shamnt = @lnTamt,
                 shupdt = 'Y'
          WHERE  shtxdt = @pdTxdt AND
                 shshop = @pcShop AND
                 shcrid = @pcCrid AND
                 shinvo = @pnInvo

          EXEC ap_crm01_jimai @pcShop,@pdTxdt,@pcCrid,@pnInvo

          SELECT @lcCard = rtrim(shcust)
          FROM   crsalh
          WHERE  shtxdt = @pdTxdt AND
                 shshop = @pcShop AND
                 shcrid = @pcCrid AND
                 shinvo = @pnInvo

          IF len(@lcCard) > 0
            BEGIN
                SELECT @lcKind = cdregn
                FROM   cccard
                WHERE  cdcard = @lcCard

                SELECT @lcIden = max(cmiden)
                FROM   crmeed
                WHERE  cmshop = @pcShop AND
                       cmfdat <= @pdTxdt AND
                       cmtdat >= @pdTxdt AND
                       charindex(@lcKind, cmkind) > 0 AND
                       cmcanx <> 'Y'

                IF NOT @lcIden IS NULL
                  BEGIN
                      SELECT @lcPomo = cmpomo
                      FROM   crmeed
                      WHERE  cmshop = @pcShop AND
                             cmiden = @lcIden

                      IF len(@lcPomo) = 0
                        SET @lcMeed = 'Y'
                      ELSE IF EXISTS( SELECT *
                                 FROM   crsald
                                 WHERE  sdtxdt = @pdTxdt AND
                                        sdshop = @pcShop AND
                                        sdcrid = @pcCrid AND
                                        sdinvo = @pnInvo AND
                                        sdprom = @lcPomo )
                        SET @lcMeed = 'Y'

                      IF @lcMeed = 'Y'
                        BEGIN
                            UPDATE crmeed
                            SET    cmfixc = CASE cmfixc
                                              WHEN 0 THEN floor(cmodds * rand() + 1)
                                              ELSE cmfixc
                                            END,
                                   cmcurc = cmcurc + 1
                            WHERE  cmshop = @pcShop AND
                                   cmiden = @lcIden

                            SELECT @lmEdcr = cmedcr,@lmEdpt = cmedpt,@lnOdds = cmodds,@lnFixc = cmfixc,@lnCurc = cmcurc
                            FROM   crmeed
                            WHERE  cmshop = @pcShop AND
                                   cmiden = @lcIden

                            IF @lnFixc = @lnCurc
                              BEGIN
                                  IF @lmEdcr <> 0
                                    BEGIN
                                        DECLARE @lcMeedCredit nvarchar(200)

                                        SET @lcMeedCredit = CONVERT(nvarchar(200), @lmEdcr)

                                        EXEC ap_Crm01_InsertProperty @pdTxdt,@pcShop,@pcCrid,@pnInvo,'MEEDCREDIT',@lcMeedCredit
                                    END

                                  IF @lmEdpt <> 0
                                    BEGIN
                                        DECLARE @lcMeedPoint nvarchar(200)

                                        SET @lcMeedPoint = CONVERT(nvarchar(200), @lmEdpt)

                                        EXEC ap_Crm01_InsertProperty @pdTxdt,@pcShop,@pcCrid,@pnInvo,'MEEDPOINT',@lcMeedPoint
                                    END
                              END

                            IF @lnOdds <= @lnCurc
                              UPDATE crmeed
                              SET    cmfixc = floor(cmodds * rand() + 1),
                                     cmcurc = 0
                              WHERE  cmshop = @pcShop AND
                                     cmiden = @lcIden
                        END
                  END
            --exec taskp_syproc_Sale    
            END

          COMMIT TRANSACTION

          IF EXISTS( SELECT *
                     FROM   crctdr
                     WHERE  cttxdt = @pdTxdt AND
                            ctshop = @pcShop AND
                            ctcrid = @pcCrid AND
                            ctinvo = @pnInvo AND
                            cttdrt = 'C' AND
                            ctlamt > 0 )
            BEGIN
                --select @pcShop = 'CCL69'
                IF NOT EXISTS( SELECT *
                               FROM   sydraw
                               WHERE  sdshop = @pcShop )
                  INSERT sydraw
                         (sdshop,sdstat)
                  VALUES(@pcShop,'')
                ELSE
                  UPDATE sydraw
                  SET    sdstat = ''
                  WHERE  sdshop = @pcShop
            END

          SELECT @lnError = 0
      END
    ELSE
      SELECT @lnError = 1

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

go 
