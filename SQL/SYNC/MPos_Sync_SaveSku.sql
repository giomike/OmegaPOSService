DROP PROCEDURE MPos_Sync_SaveSku
GO
CREATE PROCEDURE MPos_Sync_SaveSku
   @barcode varchar(50),
   @styleID varchar(15),
   @colorID char(3),
   @sizeID  char(3)
AS
   SET NOCOUNT ON;

   DECLARE @rtn TABLE
   (
       returnID      int,
       returnMessage varchar( 256 )
   )

   IF NOT EXISTS( SELECT *
                  FROM   mfskun a
                  WHERE  a.skskun = @barcode )
      BEGIN
         INSERT dbo.mfskun
                (skstyl,skcolr,sksize,skskun)
         VALUES ( @styleID,-- skstyl - char(15)
                  @colorID,-- skcolr - char(3)
                  @sizeID,-- sksize - char(3)
                  @barcode -- skskun - char(21)
         )

         INSERT @rtn
                (returnID,returnMessage)
         VALUES ( 1,-- returnID - int
                  '成功' -- returnMessage - varchar(256)
         );
      END
   ELSE
      BEGIN
         INSERT @rtn
                (returnID,returnMessage)
         VALUES ( 0,-- returnID - int
                  '已经存在' -- returnMessage - varchar(256)
         );
      END

   SELECT *
   FROM   @rtn 
 
