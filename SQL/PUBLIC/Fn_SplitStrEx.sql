DROP FUNCTION Fn_SplitStrEx
go
CREATE FUNCTION Fn_SplitStrEx
(
  @s     nvarchar(4000),
  @split nvarchar(4000)
)
Returns @re TABLE(
  row int IDENTITY(0, 1),col nvarchar( 4000 ))
AS
  BEGIN
      DECLARE @splitlen int

      SET @splitlen=Len(@split + 'a') - 2

      WHILE Charindex(@split, @s) > 0
        BEGIN
            INSERT @re
                   (col)
            VALUES(LEFT(@s, Charindex(@split, @s) - 1))

            SET @s=Stuff(@s, 1, Charindex(@split, @s) + @splitlen, '')
        END

      INSERT @re
      VALUES(@s)

      RETURN
  END

go 
