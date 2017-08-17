/*
Title:   handy_tricks_MsSql.sql
Desc:    Useful tricks for mssql
Author:  Yassin Eltahir
*/

-- Find procedures & functions that contain a certain word
SELECT OBJECT_NAME(object_id)
    FROM sys.sql_modules
    WHERE OBJECTPROPERTY(object_id, 'IsProcedure') = 1
    AND definition LIKE '%tenure%'



-- List all tables & their size
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name    



-- Get Database Query
SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') [Machine Name]
   ,SERVERPROPERTY('InstanceName') AS [Instance Name]
   ,LOCAL_NET_ADDRESS AS [IP Address Of SQL Server]
   ,CLIENT_NET_ADDRESS AS [IP Address Of Client]
 FROM SYS.DM_EXEC_CONNECTIONS 
 WHERE SESSION_ID = @@SPID


-- See Running Queries
SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
order by req.total_elapsed_time desc





-- Truncate timestamp to given interval
dateadd(hour, datediff(hour, 0, <timestamp field>), 0) as time_stamp



-- DB Size
SELECT
    DB_NAME(db.database_id) DatabaseName,
    (CAST(mfrows.RowSize AS FLOAT)*8)/1024 RowSizeMB,
    (CAST(mflog.LogSize AS FLOAT)*8)/1024 LogSizeMB,
    (CAST(mfstream.StreamSize AS FLOAT)*8)/1024 StreamSizeMB,
    (CAST(mftext.TextIndexSize AS FLOAT)*8)/1024 TextIndexSizeMB
FROM sys.databases db
    LEFT JOIN (SELECT database_id, SUM(size) RowSize FROM sys.master_files WHERE type = 0 GROUP BY database_id, type) mfrows ON mfrows.database_id = db.database_id
    LEFT JOIN (SELECT database_id, SUM(size) LogSize FROM sys.master_files WHERE type = 1 GROUP BY database_id, type) mflog ON mflog.database_id = db.database_id
    LEFT JOIN (SELECT database_id, SUM(size) StreamSize FROM sys.master_files WHERE type = 2 GROUP BY database_id, type) mfstream ON mfstream.database_id = db.database_id
    LEFT JOIN (SELECT database_id, SUM(size) TextIndexSize FROM sys.master_files WHERE type = 4 GROUP BY database_id, type) mftext ON mftext.database_id = db.database_id


-- Query scheduled jobs
SELECT JOB.NAME AS JOB_NAME,
       STEP.STEP_ID AS STEP_NUMBER,
       STEP.STEP_NAME AS STEP_NAME,
       STEP.COMMAND AS STEP_QUERY,
       DATABASE_NAME
FROM Msdb.dbo.SysJobs JOB
INNER JOIN Msdb.dbo.SysJobSteps STEP ON STEP.Job_Id = JOB.Job_Id
WHERE JOB.Enabled = 1
ORDER BY JOB.NAME, STEP.STEP_ID



-- Row number partition
ROW_NUMBER() OVER(PARTITION BY TerritoryName ORDER BY SalesYTD DESC) 


-- Check if table exists
IF EXISTS(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '<table name>' AND TABLE_SCHEMA = 'dbo')
	DROP TABLE <table name>;



