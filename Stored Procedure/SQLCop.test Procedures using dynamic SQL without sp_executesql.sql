SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [SQLCop].[test Procedures using dynamic SQL without sp_executesql]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/avoid-conversions-in-execution-plans-by-
	
	SET NOCOUNT on
    
    --legacy
    declare @except table (name nvarchar(150))
    insert into @except ( name )
    values ('spRpt_EmailProductivity_Accepted_ByDate'),('spRpt_EmailProductivity_Accepted_ByDayOfWeek'),('spRpt_EmailProductivity_Accepted_ByEmailAccount'),('spRpt_EmailProductivity_Accepted_ByFolder'),('spRpt_EmailProductivity_Accepted_ByOperator'),('spRpt_EmailProductivity_Answered_ByDate'),('spRpt_EmailProductivity_Answered_ByDayOfWeek'),('spRpt_EmailProductivity_Answered_ByEmailAccount'),('spRpt_EmailProductivity_Answered_ByFolder'),('spRpt_EmailProductivity_Answered_ByOperator'),('spRpt_EmailProductivity_Assigned_ByDate'),('spRpt_EmailProductivity_Assigned_ByDayOfWeek'),('spRpt_EmailProductivity_Assigned_ByEmailAccount'),('spRpt_EmailProductivity_Assigned_ByFolder'),('spRpt_EmailProductivity_Assigned_ByOperator'),('spRpt_EmailProductivity_ClosedAnswered_ByDate'),('spRpt_EmailProductivity_ClosedAnswered_ByDayOfWeek'),('spRpt_EmailProductivity_ClosedAnswered_ByEmailAccount'),('spRpt_EmailProductivity_ClosedAnswered_ByFolder'),('spRpt_EmailProductivity_ClosedAnswered_ByOperator'),('spRpt_EmailProductivity_ClosedUnAnswered_ByDate'),('spRpt_EmailProductivity_ClosedUnAnswered_ByDayOfWeek'),('spRpt_EmailProductivity_ClosedUnAnswered_ByEmailAccount'),('spRpt_EmailProductivity_ClosedUnAnswered_ByFolder'),('spRpt_EmailProductivity_ClosedUnAnswered_ByOperator'),('spRpt_EmailProductivity_Received_ByDate'),('spRpt_EmailProductivity_Received_ByDayOfWeek'),('spRpt_EmailProductivity_Received_ByEmailAccount'),('spRpt_EmailProductivity_Received_ByFolder'),('spRpt_EmailProductivity_Received_ByOperator'),('spRpt_EmailProductivity_Sent_ByDate'),('spRpt_EmailProductivity_Sent_ByDayOfWeek'),('spRpt_EmailProductivity_Sent_ByEmailAccount'),('spRpt_EmailProductivity_Sent_ByFolder'),('spRpt_EmailProductivity_Sent_ByOperator'),('spRpt_EmailProductivity_TimeToRespond_ByDate'),('spRpt_EmailProductivity_TimeToRespond_ByDayOfWeek'),('spRpt_EmailProductivity_TimeToRespond_ByEmailAccount'),('spRpt_EmailProductivity_TimeToRespond_ByFolder'),('spRpt_EmailProductivity_TimeToRespond_ByOperator')
	
	Declare @Output VarChar(max)
	Set @Output = ''

	SELECT	@Output = @Output + SCHEMA_NAME(so.uid) + '.' + so.name + Char(13) + Char(10)
	From	sys.sql_modules sm
			Inner Join sys.sysobjects so
				On  sm.object_id = so.id
				And so.type = 'P'
	Where	so.uid = Schema_Id('dbo')
			And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%Exec(%'
			And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Not Like '%sp_Executesql%'
			And OBJECTPROPERTY(so.id, N'IsMSShipped') = 0
            and so.Name not in (select e.name from @except as e)
	Order By SCHEMA_NAME(so.uid),so.name

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/avoid-conversions-in-execution-plans-by-'
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC tSQLt.Fail @Output
		End
 
END;


GO
