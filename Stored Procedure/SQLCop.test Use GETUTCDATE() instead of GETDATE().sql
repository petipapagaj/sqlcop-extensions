SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [SQLCop].[test Use GETUTCDATE() instead of GETDATE()]
AS
BEGIN

    --legacy
    declare @except table (name varchar(max))
    insert into @except ( name )
    values  ( 'GetChatOperatorProductivitySummary'), 
            ('test Use GETUTCDATE() instead of GETDATE()'),
            ('searchActiveAssists')
    
    set NOCOUNT ON

	Declare @Output VarChar(max)
	Set @Output = ''
  
	SELECT	@Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
	From	sys.all_objects
	Where	Type = 'P'
			AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram')
			And Object_Definition(Object_id) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%GETDATE()%'
			And is_ms_shipped = 0
			and schema_id = Schema_id('dbo')
            and object_name(object_id) not in (select e.name from @except as e)	
	ORDER BY Schema_Name(schema_id) + '.' + name

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'Please use UTC DATE. For more information:  '
						  + 'https://wiki.3amlabs.net/display/AMDB/CoreDB%3A+LIVE+Server+Guidelines'
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End


END;




GO
