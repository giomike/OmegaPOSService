# public 接口API

from fastapi import APIRouter, Query
from db import CheckStyl, GetCrid

# 创建API路由器
public_router = APIRouter(prefix="/public", tags=["公共接口"])



## 检查货号/款号信息（调用存储过程 MPos_CheckStyl）
@public_router.get("/check-styl")
def api_check_styl(
    pcSkun: str = Query(..., description="SKU 字符串/条形码（varchar(21)），例如完整 SKU 或部分码"),
    pcMakt: str = Query('', description="市场代码（char(2)，可选，默认空字符串）"),
    pcShop: str = Query('', description="店铺代码（char(5)，可选，默认空字符串）"),
):
    data = CheckStyl(pcSkun, pcMakt, pcShop)
    if data is None:
        count = 0
    elif isinstance(data, (list, tuple, set, dict)):
        count = len(data)
    else:
        try:
            count = len(data)
        except Exception:
            count = 1
    return {"success": True, "count": count, "data": data}


## 获取机器号（调用存储过程 MPos_Public_CreateCrid
@public_router.get("/get-crid")
def api_get_crid(
    shopid: str = Query(..., description="店铺代码（char(5)）"),
    machine: str = Query(..., description="设备唯一码"),
):
    crid = GetCrid(shopid, machine)
    if crid is None:
        return {"success": True, "count": 0, "data": None}
    return {"success": True, "count": 1, "data": crid}