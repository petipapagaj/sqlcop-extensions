SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [SQLCop].[test Select statement with *]
AS
BEGIN
    SET NOCOUNT ON


    --legacy
    declare @except table (name varchar(max))
    insert into @except ( name )
    values  ( 'test Select statement with *'), 
            ('udpCopyInsertTable'), 
            ('spRpt_InvatationSummary_ByRule'),
            ('spRpt_EmailProductivitySummary'),
            ('spGet_PageViewsByAccountID'),
            ('spGet_InactiveVisitsByFolderID'),
            ('spGet_AutoAnswers_AskQuestion'),
            ('GetQueuedItems'),
            ('GetChatOperatorProductivitySummary'),
            ('spRpt_AutoAnswers_VisitorQuestionDetail')
    

	Declare @Output VarChar(max)
	Set @Output = ''
  
	SELECT	@Output = @Output + Schema_Name(schema_id) + '.' + name + Char(13) + Char(10)
	From	sys.all_objects
	Where	Type = 'P'
			AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram')
			And Object_Definition(Object_id) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%SELECT *%'
			And is_ms_shipped = 0
			--and schema_id <> Schema_id('tSQLt')
			--and schema_id <> Schema_id('SQLCop')
			and schema_id = Schema_id('dbo')
            and object_name(object_id) not in (select e.name from @except as e)	
	ORDER BY Schema_Name(schema_id) + '.' + name

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'Please specify all columns. For more information:  '
						  + 'https://wiki.3amlabs.net/display/AMDB/CoreDB%3A+LIVE+Server+Guidelines'
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End


  
END;





GO
