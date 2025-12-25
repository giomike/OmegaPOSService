/*
    Procedure: MPos_Crm01_GetMemberTypies
    Description: 获取会员类型列表，暂时简单实现，后续可以加上什么类型的门店适用什么会员类型的逻辑
    author: Mike Chan
    date: 2025-12-25
*/
drop PROCEDURE if EXISTS MPos_Crm01_GetMemberTypies;
GO
CREATE PROCEDURE MPos_Crm01_GetMemberTypies
(
    @ShopID        VARCHAR(5)
)
AS
    select  a.cnregn MemberType, a.cndesc MemberName from crregn(nolock)  a
GO

