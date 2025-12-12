DROP PROC MPos_Crm01_GetPaymentType
GO
CREATE PROCEDURE MPos_Crm01_GetPaymentType
  @lcMakt       char(2),
  @lcMemberDate char(1)='N'
AS
	SET NOCOUNT ON
    DECLARE @ttdrt TABLE
    (
       tdtdrt char( 1 ),
       tdtcds nchar( 30 ),
       tdteds char( 30 ),
       tdcurr char( 3 ),
       tdshct int,
       tdtype int,
       tdccds nchar( 30 ),
       tdceds char( 30 ),
       tdextr decimal( 9, 4 ),
       tdseqn int DEFAULT 99,
       tdptyp char( 1 ) DEFAULT '' --'C' 现金 'Q' 代金券 'D' card Credit
    )
    DECLARE @tiden TABLE
    (
       titdrt char( 1 ),
       ticurr char( 3 ),
       tiiden int IDENTITY(1, 1)
    )
    DECLARE @lcGRC varchar(20)

    SELECT @lcGRC = cnvalu
    FROM   syconf,syshop
    WHERE  cnprop = 'GRCURRENCY' AND
           cnshop = syshop

    IF @lcGRC IS NULL
      SET @lcGRC=''

    -- 本币 现金 C
    INSERT @ttdrt
           (tdtdrt,tdtcds,tdteds,tdcurr,tdshct,tdtype,tdccds,tdceds,tdextr,tdptyp)
    SELECT tdtdrt,tdldes,tdedes,tdcurr,tdshct,tdtype,culdes,cuedes,cuextr,'C'
    FROM   mftdrt(nolock),mfcurr(nolock)
    WHERE  tdmakt = @lcMakt AND
           ( tdtdrt = 'C' ) AND
           tdcanx <> 'Y' AND
           tdmakt = cumakt AND
           tdcurr = cucurr AND
           cuextr = 1.000 AND
           cucanx <> 'Y'
    ORDER  BY tdtdrt

    -- 本币 储值卡 4
    INSERT @ttdrt
           (tdtdrt,tdtcds,tdteds,tdcurr,tdshct,tdtype,tdccds,tdceds,tdextr,tdptyp)
    SELECT tdtdrt,tdldes,tdedes,tdcurr,tdshct,tdtype,culdes,cuedes,cuextr,'D'
    FROM   mftdrt(nolock),mfcurr(nolock)
    WHERE  tdmakt = @lcMakt AND
           ( tdtdrt <> 'C' AND
             tdtype&4 = 4 ) AND
           tdcanx <> 'Y' AND
           tdmakt = cumakt AND
           tdcurr = cucurr AND
           cuextr = 1.000 AND
           cucanx <> 'Y'
    ORDER  BY tdtdrt

    INSERT @ttdrt
           (tdtdrt,tdtcds,tdteds,tdcurr,tdshct,tdtype,tdccds,tdceds,tdextr,tdptyp)
    SELECT tdtdrt,tdldes,tdedes,tdcurr,tdshct,tdtype,culdes,cuedes,cuextr,'Q'
    FROM   mftdrt(nolock),mfcurr(nolock)
    WHERE  tdmakt = @lcMakt AND
           ( tdtype&16 = 16 ) AND
           tdcanx <> 'Y' AND
           tdmakt = cumakt AND
           tdcurr = cucurr AND
           cuextr = 1.000 AND
           cucanx <> 'Y'
    ORDER  BY tdtdrt

    -- 积分  
    INSERT @ttdrt
           (tdtdrt,tdtcds,tdteds,tdcurr,tdshct,tdtype,tdccds,tdceds,tdextr,tdptyp)
    SELECT tdtdrt,tdldes,tdedes,cucurr,tdshct,tdtype,culdes,cuedes,cuextr,'Q'
    FROM   mftdrt(nolock),mfcurr(nolock)
    WHERE  tdmakt = @lcMakt AND
           tdtype&128 = 128 AND
           tdcanx <> 'Y' AND
           tdmakt = cumakt AND
           charindex(cucurr, @lcGRC) = 1 AND
           cucanx <> 'Y'
    ORDER  BY tdtdrt

    -- 外币 现金, 储值卡  
    INSERT @ttdrt
           (tdtdrt,tdtcds,tdteds,tdcurr,tdshct,tdtype,tdccds,tdceds,tdextr,tdptyp)
    SELECT tdtdrt,tdldes,tdedes,cucurr,tdshct,tdtype,culdes,cuedes,cuextr,'C'
    FROM   mftdrt(nolock),mfcurr(nolock)
    --      where (tdtdrt='C' or tdtype&4=4) and  
    WHERE  tdmakt = @lcMakt AND
           tdtdrt = 'C' AND
           tdcanx <> 'Y' AND
           tdmakt = cumakt AND
           cuextr <> 1.000 AND
           charindex(cucurr, @lcGRC) = 0 AND
           cucanx <> 'Y'
    ORDER  BY tdtdrt

    -- 本币 其他收银方式（银行卡，信用卡）  
    INSERT @ttdrt
           (tdtdrt,tdtcds,tdteds,tdcurr,tdshct,tdtype,tdccds,tdceds,tdextr,tdptyp)
    SELECT tdtdrt,tdldes,tdedes,tdcurr,tdshct,tdtype,culdes,cuedes,cuextr,'D'
    FROM   mftdrt(nolock),mfcurr(nolock)
    WHERE  tdmakt = @lcMakt AND
           tdtdrt <> 'C' AND
           tdtype&4 <> 4 AND
           tdtype&16 <> 16 AND
           tdtype&128 <> 128 AND
           tdcanx <> 'Y' AND
           tdmakt = cumakt AND
           tdcurr = cucurr AND
           cuextr = 1.000 AND
           cucanx <> 'Y'
    ORDER  BY tdtdrt

    DELETE FROM @ttdrt
    WHERE  tdtdrt = ''

    UPDATE @ttdrt
    SET    tdshct = 0
    WHERE  tdshct IS NULL

    UPDATE @ttdrt
    SET    tdtype = 0
    WHERE  tdtype IS NULL

    UPDATE @ttdrt
    SET    tdtype = 0
    WHERE  isnumeric(tdtype) = 0

    -- 不可退外币  
    UPDATE @ttdrt
    SET    tdtype = tdtype - 32
    WHERE  tdtdrt = 'C' AND
           tdextr <> 1.000 AND
           tdtype&32 = 32

    IF @lcMemberDate = 'Y'
      DELETE FROM @ttdrt
      WHERE  tdtype = 17

    INSERT @tiden
           (titdrt,ticurr)
    SELECT cttdrt,ctcurr
    FROM   crctdr WITH(nolock)
    WHERE  cttxdt >= dateadd(m, -3, getdate())
    GROUP  BY cttdrt,ctcurr
    ORDER  BY count(*) DESC

    UPDATE @ttdrt
    SET    tdseqn = tiiden
    FROM   @tiden
    WHERE  titdrt = tdtdrt AND
           ticurr = tdcurr

    IF NOT EXISTS( SELECT *
                   FROM   @ttdrt
                   WHERE  tdseqn <> 99 )
      BEGIN
          UPDATE @ttdrt
          SET    tdseqn = 1
          FROM   mfmakt
          WHERE  tdtdrt = 'C' AND
                 tdcurr = mkcurr AND
                 mkmakt = @lcMakt
      END

    SELECT tdtdrt [PaymentType], tdtcds [Description],tdteds [EnglishDescription],ltrim(rtrim(tdcurr)) [Currency],tdshct [KeyboardShortCut],tdseqn [Sequence],tdptyp [OperateType] --tdtype,tdccds,tdceds,tdextr,
    FROM   @ttdrt
    ORDER  BY tdseqn,tdtdrt

go 


--MPos_Crm01_GetPaymentType 'CN'