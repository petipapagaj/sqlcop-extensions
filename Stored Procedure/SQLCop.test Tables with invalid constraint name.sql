SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [SQLCop].[test Tables with invalid constraint name]
AS
BEGIN
	-- convention DF__<tablename>__<columnname>
	
	SET NOCOUNT on
    
	Declare @Output VarChar(max)
	Set @Output = ''
  
    SELECT  @Output = @Output + t.name + Char(13) + Char(10)
    FROM    sys.all_columns AS ac
            INNER JOIN sys.tables AS t ON ac.object_id = t.object_id
            INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
            INNER JOIN sys.default_constraints AS dc ON ac.default_object_id = dc.object_id
    WHERE   s.name = 'dbo'
    AND dc.name <> 'DF__' + t.name + '__' + ac.name


	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'should keep the convention: DF__<tablename>__<columnname>  '
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
						
END;


GO
