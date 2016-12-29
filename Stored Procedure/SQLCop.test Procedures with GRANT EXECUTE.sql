SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [SQLCop].[test Procedures with GRANT EXECUTE]
AS
BEGIN

    set NOCOUNT ON

	Declare @Output VarChar(max)
	Set @Output = ''
  
	SELECT @Output = @Output + p.name + Char(13) + Char(10)
	FROM sys.procedures AS p
	WHERE p.type_desc = 'SQL_STORED_PROCEDURE'
	AND schema_id = Schema_id('dbo')
	AND p.name NOT IN (
		SELECT OBJECT_NAME(major_id)
		FROM sys.database_permissions p
		WHERE OBJECT_NAME(major_id) IS NOT NULL AND p.type = 'EX'
		AND permission_name = 'EXECUTE' AND USER_NAME(grantee_principal_id) = 'public'
	)

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'Please grant execute permission for the following procedures:  '
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End


  
END;



GO
