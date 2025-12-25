drop PROCEDURE if EXISTS MPos_Crm01_GetMemberTypies;
GO
CREATE PROCEDURE MPos_Crm01_GetMemberTypies
(
    @ShopID        VARCHAR(5)
)
AS
    select  a.cnregn MemberType, a.cndesc MemberName from crregn(nolock)  a
GO

