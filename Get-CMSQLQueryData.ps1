#requires -version 3.0
<#
.DESCRIPTION
    Returns ADO dataset from SQL query to ConfigMgr database
.PARAMETER AdoConnection
    Optional ADO connection object for sequential/iterative invocations to this function
    Otherwise, the connection is opened explicitly per invocation
.PARAMETER Query
    The SQL query statement, function or stored procedure statement
.PARAMETER SQLServerName
    ConfigMgr SQL Server hostname
.PARAMETER SiteCode
    ConfigMgr site code
.EXAMPLE
    .\Get-CMSQLQueryData.ps1 -Query "select top 5 * from dbo.v_R_System" -SQLServerName "cm01.contoso.local" -SiteCode "P01"
.EXAMPLE
    $conn = Get-CMAdoConnection -SQLServerName "cm01.contoso.local" -SiteCode "P01"
    .\Get-CMSQLQueryData.ps1 -AdoConnection $conn -Query "select * from dbo.v_R_System where Name0='DT123" -SiteCode "P01"
    .\Get-CMSQLQueryData.ps1 -AdoConnection $conn -Query "select * from dbo.v_R_System where Name0='DT456" -SiteCode "P01"
    $conn.Close()
.EXAMPLE
    $query = Get-Content -Path "c:\queries\cm_devices.sql" | Out-String
    $data = .\Get-CMSQLQueryData.ps1 -Query $query -SQLServerName "cm01.contoso.local" -SiteCode "HHQ"

.NOTES
    1.0.0 - DS - initial release
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True, HelpMessage="SQL Query Statement")]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
    [parameter(Mandatory=$False, HelpMessage="SQL Server ADO Connection Object")]
        $AdoConnection,
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr SQL Server Host Name")]
        [string] $SQLServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode
)
$DatabaseName = "CM_$SiteCode"
if (!$AdoConnection) {
    Write-Verbose "opening new connection"
    $AdoConnection = .\tools\Get-CMAdoConnection.ps1 -SQLServerName $SQLServerName -DatabaseName $DatabaseName
    if (!$AdoConnection) {
        Write-Warning "failed to open SQL connection!"
        break
    }
}
$cmd = New-Object System.Data.SqlClient.SqlCommand($Query,$AdoConnection)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
if ($IsOpen) { 
    Write-Verbose "closing connection"
    $AdoConnection.Close() 
}
$rows = $($ds.Tables).Rows.Count
Write-Output $($ds.Tables).Rows
