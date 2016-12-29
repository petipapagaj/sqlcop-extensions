
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  Comments here are associated with the test.
--  For test case examples, see: http://tsqlt.org/user-guide/tsqlt-tutorial/
CREATE PROCEDURE [SQLCop].[test Unused variable found]
AS
BEGIN 
SET NOCOUNT ON

DECLARE @code NVARCHAR(max)
DECLARE @declarations TABLE (declaration VARCHAR(128))
DECLARE @Position INT = 0
DECLARE @start INT, @end INT
DECLARE @name VARCHAR(128)
DECLARE @issues TABLE (sp_name VARCHAR(128), variable_name VARCHAR(128))

DECLARE procedures CURSOR FAST_FORWARD FOR 

	SELECT	REPLACE(OBJECT_DEFINITION(object_id), CHAR(9), ' '), name
	FROM	sys.all_objects
	WHERE	Type = 'P'
			AND name Not In('sp_helpdiagrams','sp_upgraddiagrams','sp_creatediagram')
			And is_ms_shipped = 0
			and schema_id = Schema_id('dbo') 

OPEN procedures

FETCH NEXT FROM procedures INTO @code, @name

WHILE @@FETCH_STATUS = 0
BEGIN
    
	WHILE (@Position <> 8)
	BEGIN
		SELECT @Position = CHARINDEX('DECLARE @', @code, @Position) + 8

		SELECT @end = CHARINDEX(' ', @code, @Position + 1)

		INSERT INTO @declarations ( declaration )
		SELECT SUBSTRING(@code,@Position,@end-@Position)

	END

	INSERT INTO @issues (sp_name, variable_name)
	SELECT DISTINCT @name, d.declaration
	FROM @declarations AS d
	    CROSS APPLY (SELECT ((LEN(@code) - LEN(REPLACE(@code, d.declaration, ''))) -(LEN(@code) - 
        LEN(REPLACE(@code, d.declaration, ''))) % 2)  / LEN(d.declaration)) CA (occurences)
	WHERE d.declaration LIKE '@%' AND CA.occurences = 1

	DELETE FROM @declarations
	SET @Position = 0
    FETCH NEXT FROM procedures INTO @code, @name
END

CLOSE procedures
DEALLOCATE procedures


Declare @Output VarChar(max)
Set @Output = ''
  
SELECT	@Output = @Output + sp_name + ': ' + variable_name + Char(13) + Char(10)
FROM @issues AS p

If @Output > '' 
	Begin
		Set @Output = Char(13) + Char(10) 
						+ 'There are unused variables in the following procedures/functions:  '
						+ Char(13) + Char(10) 
						+ Char(13) + Char(10) 
						+ @Output
		EXEC tSQLt.Fail @Output
	End






  
END;




GO
