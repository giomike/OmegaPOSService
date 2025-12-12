MPos_Crm01_ListDiscount 'GZ86','super'
GO
DROP PROC MPos_Crm01_ListDiscount;
GO
CREATE PROCEDURE MPos_Crm01_ListDiscount
    @pcShop CHAR(5),
    @pcUser VARCHAR(40) = '',
    @pcDefective CHAR(1) = ''
AS
SET NOCOUNT ON;
DECLARE @tDsct TABLE
(
    tdcode CHAR(2),
    tdptyp CHAR(2),
    tdbbit INT,
    tddesc NCHAR(50),
    tddsct DECIMAL(5, 2),
    tdflag CHAR(1),
    tdshop CHAR(5)
        DEFAULT '',
    PRIMARY KEY CLUSTERED (
                              tdcode,
                              tdshop
                          )
);
DECLARE @lcShopType CHAR(1);
DECLARE @lcShopStyp CHAR(1);
DECLARE @lnDsct INT;

SELECT @lcShopType = shtype,
       @lcShopStyp = shstyp
FROM mfshop (NOLOCK)
WHERE shshop = @pcShop;

SELECT @lnDsct = uadsct
FROM mfuser (NOLOCK)
WHERE uauser = @pcUser;

--PRINT 'Max Discount:'
--PRINT @lnDsct

IF @lnDsct IS NULL
    SET @lnDsct = 100;

IF @pcDefective = 'Y'
    SET @lnDsct = 90;

INSERT @tDsct
(
    tdcode,
    tdptyp,
    tdbbit,
    tddesc,
    tddsct,
    tdflag,
    tdshop
)
SELECT dscode,
       dsptyp,
       dsbbit,
       dsdesc,
       dsdsct,
       dsflag,
       dsshop
FROM dbo.mfdsct
WHERE (
          dsshty = @lcShopType
          OR TRIM(dsshty) = ''
      )
      AND
      (
          dsssty = @lcShopStyp
          OR TRIM(dsssty) = ''
      )
      AND dsdsct <= @lnDsct
      AND dsflag <> 'Y'
      AND
      (
          dsshop = ''
          OR dsshop = @pcShop
      );



UPDATE @tDsct
SET tddesc = ''
WHERE tddesc IS NULL;

SELECT tdcode AS DiscountCode,        -- 折扣代码
       tdptyp AS PaymentTypeLimit,    -- 支付类型限制
       tdbbit AS AllowedBrands,       -- 允许使用的品牌
       tddesc AS DiscountDescription, -- 折扣描述
       tddsct AS Discount,            -- 折扣值
       tdflag AS Flag,                -- 标记
       tdshop AS ApplicableShops      -- 折扣可用门店
FROM @tDsct
ORDER BY tdcode;

GO



