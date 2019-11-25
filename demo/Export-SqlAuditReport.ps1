#requires -modules dbatools,importexcel
<#
.SYNOPSIS
    Export SQL Server audit report to Excel spreadsheet
.DESCRIPTION
    Export SQL Server audit report to Excel spreadsheet
.PARAMETER SQLServer
    SQL Server instance hostname
.PARAMETER SQLCMDBName
    ConfigMgr / MEMCM SQL Server database name
.PARAMETER SQLDBName
    SQL Server Master database name. Default is "master"
.PARAMETER TempDir
    Output folder. Default is user profile "Documents" folder
.PARAMETER CSV
    Output to CSV rather than Excel .xlsx file
.NOTES
    based entirely on Steve Thompson's work:
    https://stevethompsonmvp.wordpress.com/2014/05/19/powershell-sql-audit-script/
#>

[CmdletBinding()]
param (
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SQLServer,
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SQLCMDBName,
    [parameter()][ValidateNotNullOrEmpty()][string] $SQLDBName = "Master",
    [parameter()][ValidateNotNullOrEmpty()][string] $TempDir = "$env:USERPROFILE\Documents",
    [parameter()][switch] $CSV
)

# Change path as appropriate
$dir = $TempDir
$xlFile = Join-Path -Path $dir -ChildPath "$SQLServer`_SqlAudit`_$(Get-Date -f 'yyMM.dd.hh.mm.ss').xlsx"

Write-Host "Connecting to host $SQLServer"

Write-Verbose "01-Server Properties"

$SqlQuery = "SELECT SERVERPROPERTY('MachineName') AS [MachineName], SERVERPROPERTY('ServerName') AS [ServerName],  
SERVERPROPERTY('InstanceName') AS [Instance], SERVERPROPERTY('IsClustered') AS [IsClustered], 
SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
SERVERPROPERTY('Edition') AS [Edition], SERVERPROPERTY('ProductLevel') AS [ProductLevel], 
SERVERPROPERTY('ProductVersion') AS [ProductVersion], SERVERPROPERTY('ProcessID') AS [ProcessID],
SERVERPROPERTY('Collation') AS [Collation], SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly];"
 
$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "01-Server Properties.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "ServerProps" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "02-Windows Info"

$SqlQuery = "SELECT windows_release, windows_service_pack_level, 
       windows_sku, os_language_version
FROM sys.dm_os_windows_info WITH (NOLOCK) OPTION (RECOMPILE);"

$DataSet = Invoke-DbaQuery -SqlInstance cm01 -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "02-Windows Info.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "Windows" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "03-Version Info"

$SqlQuery = "SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "03-Version Info.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "SQLVersion" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "04-SQL Server Install Date"

#$SqlQuery = "SELECT @@SERVERNAME AS [Server Name], createdate AS [SQL Server Install Date] 
#FROM sys.syslogins WITH (NOLOCK)
#WHERE [sid] = 0x010100000000000512000000;" 

$SqlQuery = "SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "04-SQL Server Install Date.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "InstallDate" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "05-Configuration Values"

$SqlQuery = "SELECT name, value, value_in_use, [description] 
FROM sys.configurations WITH (NOLOCK)
ORDER BY name OPTION (RECOMPILE);" 

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "05-Configuration Values.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "Config" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "06-DB File Names and paths"

$SqlQuery = "SELECT DB_NAME([database_id])AS [Database Name], 
 [file_id], name, physical_name, type_desc, state_desc, 
 CONVERT( bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
OR [database_id] = 2
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "06-DB File Names and paths.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "DBFiles" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "07-DB Properties"

$SqlQuery = "SELECT db.[name] AS [Database Name], 
suser_sname( owner_sid ) As [Database Owner],
db.recovery_model_desc AS [Recovery Model], 
db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
ls.cntr_value AS [Log Size (KB)], lu.cntr_value AS [Log Used (KB)],
CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
db.[compatibility_level] AS [DB Compatibility Level], 
db.page_verify_option_desc AS [Page Verify Option], db.is_auto_create_stats_on, db.is_auto_update_stats_on,
db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on,
db.is_auto_close_on, db.is_auto_shrink_on, db.is_cdc_enabled
FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK) 
ON db.name = ls.instance_name
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 OPTION (RECOMPILE);"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "07-DB Properties.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "DBProps" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "08-Server Hardware"
# was: physical_memory_in_bytes/1048576 / now: physical_memory_kb/1024 (for SQL 2017)

$SqlQuery = "SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count], 
physical_memory_kb/1024 AS [Physical Memory (MB)], 
sqlserver_start_time --, affinity_type_desc -- (affinity_type_desc is only in 2008 R2)
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "08-Server Hardware.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "Hardware" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "09-System Manufacturer"

$SqlQuery = "EXEC sp_readerrorlog 0,1,'Manufacturer';" 
$dataset = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery
if ($CSV) {
    $DataSet | Export-Csv ($dir + "09-System Manufacturer.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "SystemMfr" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "10-Fixed Drive Freespace"

$SqlQuery = "EXEC xp_fixeddrives;" 

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "10-Fixed Drive Freespace.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "DriveSpace" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "11-IO Util by DB"

$SqlQuery = "WITH Aggregate_IO_Statistics
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id)
SELECT ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [Database Name], io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM Aggregate_IO_Statistics
ORDER BY [I/O Rank] OPTION (RECOMPILE);"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "11-IO Util by DB.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "IO Utils by DB" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "12-System Memory"

$SqlQuery = "SELECT total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
       available_physical_memory_kb/1024 AS [Available Memory (MB)], 
       total_page_file_kb/1024 AS [Total Page File (MB)], 
       available_page_file_kb/1024 AS [Available Page File (MB)], 
       system_cache_kb/1024 AS [System Cache (MB)],
       system_memory_state_desc AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);" 

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "12-System Memory.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "System Memory" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "13-Process Memory"

$SqlQuery = "SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
       large_page_allocations_kb, locked_page_allocations_kb, page_fault_count, 
       memory_utilization_percentage, available_commit_limit_kb, 
       process_physical_memory_low, process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "13-Process Memory.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "Process Memory" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "14-SQL Log file freespace"

$SqlQuery = "DBCC SQLPERF(LOGSPACE);"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery 
if ($CSV) {
    $DataSet | Export-Csv ($dir + "14-SQL Log file freespace.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "Log Files" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "15-CM File Sizes"

# DB Name needed here...
$SqlQuery = "SELECT f.name AS [File Name] , f.physical_name AS [Physical Name], 
CAST((f.size/128.0) AS decimal(15,2)) AS [Total Size in MB],
CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS decimal(15,2)) 
AS [Available Space In MB], [file_id], fg.name AS [Filegroup Name]
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) 
ON f.data_space_id = fg.data_space_id OPTION (RECOMPILE);"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery -Database $SQLCMDBName
if ($CSV) {
    $DataSet | Export-Csv ($dir + "15-CM File Sizes.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "CM FileSizes" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "16-CM DB Statistics"

$SqlQuery = "SELECT DISTINCT
     OBJECT_NAME(s.[object_id]) AS TableName,
     c.name AS ColumnName,
     s.name AS StatName,
     s.auto_created,
     s.user_created,
     s.no_recompute,
     s.[object_id],
     s.stats_id,
     sc.stats_column_id,
     sc.column_id,
     STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated
 FROM sys.stats s JOIN sys.stats_columns sc ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id
     JOIN sys.columns c ON c.[object_id] = sc.[object_id] AND c.column_id = sc.column_id
     JOIN sys.partitions par ON par.[object_id] = s.[object_id]
     JOIN sys.objects obj ON par.[object_id] = obj.[object_id]
 WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
    AND (s.auto_created = 1 OR s.user_created = 1);"  
    
$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery -Database $SQLCMDBName
if ($CSV) {
    $DataSet | Export-Csv ($dir + "16-CM DB Statistics.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "CM DB Stats" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "17-CM Index Frag (be patient)"

<# 
# This one may be a long running query, it is important to determine if the indeses are fragmented.

$SqlQuery = "SELECT DB_NAME(database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], 
i.name AS [Index Name], ps.index_id, index_type_desc,
CONVERT(decimal,  avg_fragmentation_in_percent), fragment_count, page_count
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,N'LIMITED') AS ps 
INNER JOIN sys.indexes AS i WITH (NOLOCK)
ON ps.[object_id] = i.[object_id] 
AND ps.index_id = i.index_id
WHERE database_id = DB_ID()
AND page_count > 1500
ORDER BY avg_fragmentation_in_percent DESC OPTION (RECOMPILE);" 
#>

$SqlQuery = "SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent desc"

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery -Database $SQLCMDBName
if ($CSV) {
    $DataSet | Export-Csv ($dir + "17-CM Index Frag.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "CM Index Frag" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Verbose "18-VLF Information"

# Virtual Log File - numbers below 50 are generally good. Large numbers of VLF can affect write performance, and startup times
$SqlQuery = "DBCC LOGINFO;" 

$DataSet = Invoke-DbaQuery -SqlInstance $SQLServer -Query $SqlQuery -Database $SQLCMDBName
if ($CSV) {
    $DataSet | Export-Csv ($dir + "18-CM VLF Info.csv") -NoTypeInformation -Force
}
else {
    $DataSet | Export-Excel -Path $xlFile -WorksheetName "CM VLF Info" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -ClearSheet
}

Write-Host "report saved to $xlFile"