SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [SQLCop].[test Use schema names when referencing to tables]
AS
BEGIN
    SET NOCOUNT ON

	Declare @Output VarChar(max) = ''

	DECLARE @Position INT = 0
	DECLARE @End INT = 0
	DECLARE @tables TABLE (name VARCHAR(128))
	DECLARE @Ref INT = 0
	DECLARE @Procedures TABLE (name VARCHAR(128))
	DECLARE @table VARCHAR(128)
	DECLARE @searched VARCHAR(128)
	DECLARE @code VARCHAR(max) 
	DECLARE @name VARCHAR(128)

	DECLARE spCursor CURSOR FAST_FORWARD 
	FOR 

		SELECT OBJECT_DEFINITION(object_id), name
		From	sys.all_objects
		Where	Type = 'P'
				AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram')
				And is_ms_shipped = 0
				and schema_id = Schema_id('dbo')
				AND name NOT IN ( --legacy. would be nice to fix though				
					'GetOperatorProductivitySummary',
					'GetQueuedItems',
					'GetUserHistory',
					'SearchChats',
					'SearchChatsByAccountIDFromDateToDate',
					'SearchDeletedItemsByAccountIDFromDateToDate',
					'SearchFirstChatByAccountID',
					'SearchFirstDeletedItemByAccountID',
					'SearchHistory',
					'spGet_AutoAnswers_AskQuestion',
					'spGet_ChatSkills_ForQuestion',
					'spGet_ConversionsByContactID',
					'spGet_ExperimentGroupsByVisitID',
					'spGet_InactiveVisitsByFolderID',
					'spGet_PageViewsByAccountID',
					'spGet_VisitsByVisitorID',
					'spRpt_EmailProductivitySummary',
					'spRpt_InvatationSummary_ByRule',
					'udpRebuildFilegroups'
				
				)


	OPEN spCursor

	FETCH NEXT FROM spCursor INTO @code, @name

	WHILE @@FETCH_STATUS = 0
	BEGIN
    
				DELETE FROM @tables

				DECLARE tableCursor CURSOR FAST_FORWARD 
				FOR 
					SELECT t.TABLE_NAME
					FROM INFORMATION_SCHEMA.TABLES AS t 
					WHERE t.TABLE_SCHEMA = 'dbo'

				OPEN tableCursor

				FETCH NEXT FROM tableCursor INTO @table

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @Ref = 0

					WHILE @Ref <> -4 --find all occurences of table in the sp
					BEGIN
						SET @Ref = CHARINDEX(@table, @code, @Position) - 4 -- -4 for dbo schema
						IF @Position =  @Ref
							BREAK
						ELSE 
							SELECT @Position = @Ref
        
						SELECT @End = CHARINDEX(' ', @code, @Position + 1)

						SELECT @searched = SUBSTRING(@code,@Position,@end-@Position)

						INSERT INTO @tables ( name )
						SELECT @searched WHERE @searched NOT LIKE '%CREATE%'

					END 

    
					FETCH NEXT FROM tableCursor INTO @table
				END

				CLOSE tableCursor
				DEALLOCATE tableCursor

				IF EXISTS (SELECT 1 FROM @tables AS t WHERE SUBSTRING(t.name, 1,4) <> 'dbo.')
				INSERT INTO @Procedures ( name ) VALUES (@name)

		FETCH NEXT FROM spCursor INTO @code, @name
	END

	CLOSE spCursor
	DEALLOCATE spCursor

  
	SELECT DISTINCT @Output = @Output + rt.name + Char(13) + Char(10)
	FROM @Procedures AS rt
	

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'Please use schema name by referencing to tables in the following procedures:  '
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End

  
END;



GO
