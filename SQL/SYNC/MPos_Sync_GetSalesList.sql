/*
    Procedure: MPos_Sync_GetSalesList
    Description: 获取制定时间段内有更新的销售单据列表，这里没有明细，因为怕数据太大，不放便在rest接口中传输，具体在循环中再一单一单获取明细提交到目的地服务器
    author: Mike Chan
    date: 2025-12-25
*/
drop PROCEDURE IF EXISTS MPos_Sync_GetSalesList;
GO
create PROCEDURE MPos_Sync_GetSalesList
(
    @ShopID        VARCHAR(5),
    @fromDate     smalldatetime,
    @toDate       smalldatetime
)
as

select * from crsalh(nolock) a where a.shshop= @ShopID and a.shtxdt between @fromDate and @toDate and a.shupdt='Y'
go