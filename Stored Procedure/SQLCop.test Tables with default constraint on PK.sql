SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [SQLCop].[test Tables with default constraint on PK]
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

    AND EXISTS (
    
               SELECT 1 
               FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
            INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
        WHERE 
            Col.Constraint_Name = Tab.Constraint_Name
            AND Col.Table_Name = Tab.Table_Name
            AND Constraint_Type = 'PRIMARY KEY' 
            AND t.name = tab.TABLE_NAME AND ac.name = col.COLUMN_NAME
    )

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'should not add default constraint for primary key '
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
						
END;



GO
