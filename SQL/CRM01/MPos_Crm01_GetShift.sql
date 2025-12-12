DROP PROC MPos_Crm01_GetShift

go

CREATE PROCEDURE MPos_Crm01_GetShift
  @PCSHOP char(5),
  @PDTXDT smalldatetime,
  @PCCRID char(3)
AS
    DECLARE @lcClrf char(1)
    DECLARE @lnShft int
    DECLARE @lnInvo int

    SELECT @lnShft = max(dhshft)
    FROM   crcdwh
    WHERE  dhtxdt = @pdTxdt AND
           dhshop = @pcShop AND
           dhcrid = @pcCrid

    IF @lnShft IS NULL
      BEGIN
          INSERT crcdwh
                 (dhtxdt,dhshop,dhcrid,dhshft,dhfinv,dhtinv,dhclrf,dhconf,dhdinv,dhdqty,dhdamt,dhrinv,dhrqty,dhramt)
          VALUES (@pdTxdt,@pcShop,@pcCrid,1,1,0,' ',' ',0,0,0,0,0,0)

          SELECT @lnShft = 1
      END
    ELSE
      BEGIN
          SELECT @lcClrf = dhclrf,@lnInvo = dhtinv + 1
          FROM   crcdwh
          WHERE  dhtxdt = @pdTxdt AND
                 dhshop = @pcShop AND
                 dhcrid = @pcCrid

          IF @lcClrf = 'Y'
            BEGIN
                SELECT @lnShft = @lnShft + 1

                INSERT crcdwh
                       (dhtxdt,dhshop,dhcrid,dhshft,dhfinv,dhtinv,dhclrf,dhconf,dhdinv,dhdqty,dhdamt,dhrinv,dhrqty,dhramt)
                VALUES (@pdTxdt,@pcShop,@pcCrid,@lnShft,@lnInvo,0,' ',' ',0,0,0,0,0,0)
            END
      END

    SELECT @lnShft

go 

MPos_Crm01_GetShift 'GZ86','2025-12-05','001'