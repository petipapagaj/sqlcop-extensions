SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [SQLCop].[test Tables with invalid PK name]
AS
BEGIN

	-- convention PK__<tablename>
	
	SET NOCOUNT on
    
	Declare @Output VarChar(max)
	Set @Output = ''
  
    SELECT  @Output = @Output + Col.TABLE_NAME + Char(13) + Char(10)
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col ON Col.CONSTRAINT_NAME = Tab.CONSTRAINT_NAME AND Col.TABLE_NAME = Tab.TABLE_NAME
	WHERE Constraint_Type = 'PRIMARY KEY' AND Tab.CONSTRAINT_NAME <> 'PK__' + Col.TABLE_NAME AND Col.TABLE_SCHEMA = 'dbo'


	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'should keep the convention: PK__<tablename>  '
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
  
END;



GO
