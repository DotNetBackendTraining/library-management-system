-- Drop the existing session if it exists
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LibraryManagementSystemProfileSession')
    DROP EVENT SESSION [LibraryManagementSystemProfileSession] ON SERVER
GO

-- Create the Extended Events session
CREATE EVENT SESSION [LibraryManagementSystemProfileSession] ON SERVER 
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.sql_text, sqlserver.database_name, sqlserver.plan_handle)
    WHERE ([duration] > 5000)), -- Filter: duration longer than 5 ms
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.sql_text, sqlserver.database_name, sqlserver.plan_handle)
    WHERE ([duration] > 5000)), -- Filter: duration longer than 5 ms  
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.sql_text, sqlserver.database_name, sqlserver.plan_handle)
    WHERE ([duration] > 5000000)), -- Filter: duration longer than 5 seconds
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.sql_text, sqlserver.database_name, sqlserver.plan_handle)
    WHERE ([duration] > 5000000)) -- Filter: duration longer than 5 seconds
ADD TARGET package0.event_file(SET filename=N'LibraryManagementSystemProfileSession.xel', max_file_size=(5), max_rollover_files=(2))
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=ON, STARTUP_STATE=OFF)
GO

-- Start the Extended Events session
ALTER EVENT SESSION [LibraryManagementSystemProfileSession] ON SERVER STATE = START;
GO
