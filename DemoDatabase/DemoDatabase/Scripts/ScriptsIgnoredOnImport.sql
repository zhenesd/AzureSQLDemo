
--View SYS.CONFIGURATIONS
SELECT
  [name],
  [value_in_use]
FROM SYS.CONFIGURATIONS
WHERE NAME IN ('min server memory (MB)',
'max server memory (MB)',
'optimize for ad hoc workloads',
'cost threshold for parallelism',
'max degree of parallelism')
GO

--attempt reconfigure
RECONFIGURE
GO

EXEC sp_configure 'cost threshold for parallelism', 25 ;
GO

RECONFIGURE
GO

--Common tuning query
SELECT
  usecounts,
  cacheobjtype,
  objtype,
  text
FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
WHERE usecounts > 1
AND objtype IN (N'Adhoc', N'Prepared')
ORDER BY usecounts DESC;
GO

--attempt to clear the procedure cache
DBCC FREEPROCCACHE
GO

--SQL 2016 and Azure SQL Database method to clear cache
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
