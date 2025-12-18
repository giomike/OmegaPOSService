# 广百接口一些请求入参/出仓的实体
from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, Any

# ================ 基础响应模型 ================
class BaseResponse(BaseModel):
    success: bool
    code: int
    message: str
    data: Optional[Dict[str, Any]] = None

# ================ 各接口请求模型 ================
class FindMemberInfoBrandRequest(BaseModel):
    """会员识别接口请求模型"""
    strCustomer: str = Field(..., description="会员卡号/会员码/手机号")


class QueryXfkInfoRequest(BaseModel):
    """积分卡查询接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vtrack2: str = Field(..., description="磁道信息，刷卡获取的内容")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v


class PayWithXfkRequest(BaseModel):
    """积分卡核销接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vtrack2: str = Field(..., description="磁道信息，刷卡获取的内容")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    vtype: str = Field(..., description="交易类型，默认 01")
    vseqno: str = Field(..., description="交易流水号，4位门店号+小票号+3位序列号")
    vje: float = Field(..., description="交易金额", gt=0)
    requestId: str = Field(..., description="交易请求ID，一次交易行为的唯一标识")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v
    
    @validator('vtype')
    def validate_vtype(cls, v):
        if v != '01':
            raise ValueError('交易类型目前只支持 01')
        return v


class XfkWriteoffCancelRequest(BaseModel):
    """积分卡冲正接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vtrack2: str = Field(..., description="磁道信息，刷卡获取的内容")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    vtype: str = Field(..., description="交易类型，默认 01")
    vseqno: str = Field(..., description="交易流水号，4位门店号+小票号+3位序列号")
    vje: float = Field(..., description="交易金额", gt=0)
    vmemo: str = Field(..., description="原交易流水号")
    requestId: str = Field(..., description="交易请求ID，一次交易行为的唯一标识")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v


class GetXfkTradeConfirmInfoRequest(BaseModel):
    """积分卡交易确认接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v


class XfkSettlementRequest(BaseModel):
    """积分卡日结接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v


class QueryByTmqRequest(BaseModel):
    """条码现金券查询接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vtrack2: str = Field(..., description="磁道信息，刷卡获取的内容")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v


class PayWithTmqRequest(BaseModel):
    """条码现金券核销接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vtrack2: str = Field(..., description="磁道信息，刷卡获取的内容")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    vtype: str = Field(..., description="交易类型，默认 01")
    vseqno: str = Field(..., description="交易流水号，4位门店号+小票号+3位序列号")
    vje: float = Field(..., description="交易金额", gt=0)
    requestId: str = Field(..., description="交易请求ID，一次交易行为的唯一标识")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v
    
    @validator('vtype')
    def validate_vtype(cls, v):
        if v != '01':
            raise ValueError('交易类型目前只支持 01')
        return v


class ReturnWithTmqRequest(BaseModel):
    """条码现金券冲正接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vtrack2: str = Field(..., description="磁道信息，刷卡获取的内容")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    vtype: str = Field(..., description="交易类型，默认 01")
    vseqno: str = Field(..., description="交易流水号，4位门店号+小票号+3位序列号")
    vje: float = Field(..., description="交易金额", gt=0)
    vmemo: str = Field(..., description="原交易流水号")
    requestId: str = Field(..., description="交易请求ID，一次交易行为的唯一标识")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v


class GetTmqTradeConfirmInfoRequest(BaseModel):
    """条码现金券交易确认接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    orderNo: str = Field(..., description="销售小票号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v


class TmqSettlementRequest(BaseModel):
    """条码现金券日结接口请求模型"""
    storeNo: str = Field(..., description="门店编号")
    cashierId: str = Field(..., description="收款员号")
    terminalId: str = Field(..., description="授权终端号，4位门店号+5位收款终端号")
    vcardbrand: str = Field(..., description="卡类型，201广百积分卡，202友谊积分卡")
    
    @validator('vcardbrand')
    def validate_vcardbrand(cls, v):
        if v not in ['201', '202']:
            raise ValueError('卡类型必须是 201(广百积分卡) 或 202(友谊积分卡)')
        return v