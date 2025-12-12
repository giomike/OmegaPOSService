DROP PROC MPos_Crm01_NewInvo

GO

CREATE PROCEDURE MPos_Crm01_NewInvo
  @PCSHOP char(5),
  @PDTXDT smalldatetime,
  @PCCRID char(3)
AS
    DECLARE @lnInvo int
    DECLARE @lnShft int
    DECLARE @lcMakt char(2)
    DECLARE @ldMaxDate smalldatetime

    SELECT @lcMakt = shmakt
    FROM   mfshop(nolock)
    WHERE  shshop = @pcshop

    CREATE TABLE #tinvo
    (
       tshft int NULL
    )

    SET nocount ON

    SELECT @lnShft = dhshft
    FROM   crcdwh(nolock)
    WHERE  dhshop = @pcShop AND
           dhtxdt = @pdTxdt AND
           dhcrid = @pcCrid AND
           rtrim(dhclrf) = ''

    IF @lnShft IS NULL
      INSERT #tinvo
             (tshft)
      EXEC MPos_Crm01_GetShift @pcShop,@pdTxdt,@pcCrid

    IF upper(@lcMakt) = 'TH'
      BEGIN
          SELECT @ldMaxDate = max(shtxdt)
          FROM   crsalh(nolock)

          SELECT @lnInvo = max(shinvo)
          FROM   crsalh(nolock)
          WHERE  shshop = @pcShop AND
                 shtxdt = @ldMaxDate AND
                 shcrid = @pcCrid
      END
    ELSE
      SELECT @lnInvo = max(shinvo)
      FROM   crsalh
      WHERE  shshop = @pcShop AND
             shtxdt = @pdTxdt AND
             shcrid = @pcCrid

    IF @lnInvo = 9999  OR
       @lnInvo IS NULL
      SELECT @lnInvo = 0

    SELECT @lnInvo = @lnInvo + 1

    WHILE EXISTS ( SELECT *
                   FROM   crsalh
                   WHERE  shtxdt = @ldMaxDate AND
                          shshop = @pcShop AND
                          shcrid = @pcCrid AND
                          shinvo = @lnInvo )
      SELECT @lnInvo = @lnInvo + 1

    SELECT @lnInvo

go 
