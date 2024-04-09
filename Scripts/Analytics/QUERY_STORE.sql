-- Enable Query Store for your database
USE [master];
GO

ALTER DATABASE [LibraryManagementSystem] SET QUERY_STORE = ON;
GO

-- Configure Query Store settings
ALTER DATABASE [LibraryManagementSystem] SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE, -- Enable Query Store to read and write data
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), -- Data older than 30 days will be cleaned up
    DATA_FLUSH_INTERVAL_SECONDS = 900, -- Data will be flushed to disk every 15 minutes
    MAX_STORAGE_SIZE_MB = 500, -- Maximum storage space for Query Store data
    INTERVAL_LENGTH_MINUTES = 60, -- Aggregates runtime stats into 60-minute intervals
    QUERY_CAPTURE_MODE = AUTO, -- Automatic query capture mode
    SIZE_BASED_CLEANUP_MODE = AUTO -- Automatic cleanup mode based on size
);
GO

-- Start Query Store if it's not already started
ALTER DATABASE [LibraryManagementSystem] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
GO

-- Common Query Store Commands:

-- 1. View top N queries by total CPU time
SELECT TOP 10
    qsqs.query_id,
    qsqt.query_sql_text,
    SUM(qsrs.count_executions) AS total_executions,
    SUM(qsrs.avg_cpu_time * qsrs.count_executions) AS total_cpu_time_ms -- Calculate total CPU time
FROM sys.query_store_query AS qsqs
INNER JOIN sys.query_store_query_text AS qsqt ON qsqs.query_text_id = qsqt.query_text_id
INNER JOIN sys.query_store_plan AS qsqp ON qsqs.query_id = qsqp.query_id
INNER JOIN sys.query_store_runtime_stats AS qsrs ON qsqp.plan_id = qsrs.plan_id
GROUP BY qsqs.query_id, qsqt.query_sql_text
ORDER BY total_cpu_time_ms DESC;

-- 2. Force a specific plan for a query
-- Note: Replace {plan_id} and {query_id} with actual values obtained from Query Store views
-- EXEC sp_query_store_force_plan {query_id}, {plan_id};
-- GO

-- 3. Remove forced plan for a query
-- Note: Replace {query_id} with the actual value obtained from Query Store views
-- EXEC sp_query_store_unforce_plan {query_id};
-- GO

-- 4. Clear Query Store data
-- ALTER DATABASE [YourDatabaseName] SET QUERY_STORE CLEAR;
-- GO

-- 5. Disable Query Store
-- ALTER DATABASE [YourDatabaseName] SET QUERY_STORE = OFF;
-- GO
