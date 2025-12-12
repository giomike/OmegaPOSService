DROP PROC MPos_crm01_SaveCartMemberCard

GO

CREATE PROC MPos_crm01_SaveCartMemberCard
  @TransDate smalldatetime,
  @Shop      char(5),
  @Crid      char(3),
  @CartID    uniqueidentifier,
  @memberCard   char(10)
AS
    IF EXISTS( SELECT *
               FROM   crcarh
               WHERE  transdate = @TransDate AND
                      shop = @Shop AND
                      crid = @Crid AND
                      cartid = @CartID )
      UPDATE crcarh
      SET    wwscard = @memberCard
      WHERE  transdate = @TransDate AND
             shop = @Shop AND
             crid = @Crid AND
             cartid = @CartID
    ELSE
      INSERT crcarh
             (TransDate,shop,crid,cartid,wwscard,salm)
      SELECT @TransDate,@Shop,@Crid,@CartID,@memberCard,''

go 
