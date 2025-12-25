drop PROCEDURE IF EXISTS MPos_Sync_GetSales;
GO
create PROCEDURE MPos_Sync_GetSales
(
    @ShopID        VARCHAR(5),
    @trandate     DATETIME,
    @Crid         char(3),
    @invoiceID     Int
)
as
    select * from crsalh(nolock) a where a.shshop= @ShopID and a.shtxdt = @trandate and a.shcrid = @Crid and a.shinvo = @invoiceID
    select * from crsald(nolock) b where b.sdshop= @ShopID and b.sdtxdt = @trandate and b.sdcrid = @Crid and b.sdinvo = @invoiceID
    select * from crctdr(nolock) c where c.ctshop= @ShopID and c.cttxdt = @trandate and c.ctcrid = @Crid and c.ctinvo = @invoiceID
    select * from crprop(nolock) d where d.cpshop= @ShopID AND d.cptxdt = @trandate AND d.cpcrid = @Crid AND d.cpinvo = @invoiceID
GO