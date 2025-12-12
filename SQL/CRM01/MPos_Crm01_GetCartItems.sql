DROP PROC MPos_Crm01_GetCartItems

go

CREATE PROC MPos_Crm01_GetCartItems
  @TransDate smalldatetime,
  @Shop      char(5),
  @Crid      char(3),
  @CartID    uniqueidentifier
AS
    SELECT TransDate,
           Shop,
           Crid,
           CartID,
           InputTime,
           Seqn,
           ItemType,
           Sku SkuBarcode,
           StyleCode,
		   b.smedes LocalDescription,
		   b.smldes EnglishDescription,
           Color,
           Size,
           Price,
           Discount,
           Qty,
           DiscountType,
           PromotionCode,
           Amnt,
           OPrice UnitPrice,
           OAmnt UnitPriceAmount,
           SaleType,
           Line,
           Change,
           Brand,
           Cate,
           Ptype,
           DMark [Weight],
           Commision,
           PromotionID,
           DiscountID,
           DiscountBrandBit,
           DiscountPtyp,
           GPrice,
           LostSales,
           CumulateValue,
           VoucherID,
           BrandBit,
           SupplierID,
           PantsLength,
           Calced,
           Message,
           IsEshop
    FROM   crcart(nolock) a, dbo.mfstyl(NOLOCK) b
    WHERE  [TransDate] = @TransDate AND
           [Shop] = @Shop AND
           [Crid] = @Crid AND
           [CartID] = @CartID AND
           a.StyleCode = b.smcode
    ORDER  BY seqn

go 

