CREATE PROCEDURE dbo.MPos_Public_GetShopAndCridConfig
   @pShopId AS varchar(5),
   @pCrid   AS varchar(3)
AS
   BEGIN
      SET NOCOUNT ON

      CREATE TABLE #gbInfo
      (
         shopid     varchar( 10 ),
         crid       varchar( 10 ),
         storeNo    varchar( 10 ),
         cashierId  varchar( 10 ),
         terminalId varchar( 10 ),
      )

      IF EXISTS ( SELECT *
                  FROM   dbo.syconf(NOLOCK)
                  WHERE  cnshop = @pShopId ) AND
         EXISTS ( SELECT *
                  FROM   dbo.mfcrid(NOLOCK)
                  WHERE  mcshop = @pShopId AND
                         mccrid = @pCrid )
         BEGIN
            INSERT #gbInfo
                   (shopid,crid)
            VALUES ( @pShopId,@pCrid )

            UPDATE a
            SET    a.storeNo = b.cnvalu
            FROM   #gbInfo a,
                   dbo.syconf(NOLOCK) b
            WHERE  a.shopid = b.cnshop AND
                   b.cnprop = 'STORENO'

            UPDATE a
            SET    a.cashierId = b.cnvalu
            FROM   #gbInfo a,
                   dbo.syconf(NOLOCK) b
            WHERE  a.shopid = b.cnshop AND
                   b.cnprop = 'CASHIERID'

            UPDATE a
            SET    a.terminalId = '99993'
            FROM   #gbInfo a,
                   dbo.mfcrid(NOLOCK) b
            WHERE  a.shopid = LTRIM(b.mcshop) AND
                   a.crid = b.mccrid
         END

      SELECT *
      FROM   #gbInfo
   END

 
