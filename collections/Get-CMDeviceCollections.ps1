<#
.DESCRIPTION
    Query collection memberships for a specific device
.PARAMETER ComputerName
    Name of the device
.PARAMETER ServerName
    ConfigMgr SQL Server host name (FQDN)
.PARAMETER SiteCode
    ConfigMgr Site Code
.EXAMPLE
    $colls = .\Get-CmDeviceCollections.ps1 -ComputerName "DT12345" -ServerName "cm01.contoso.local" -SiteCode "P01"
.NOTES
    1.0.0 - DS - initial release
    1.0.1 - DS - general cleanup and documentation
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True, HelpMessage="Computer Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName,
    [parameter(Mandatory=$True, HelpMessage="Site Database Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode
)
$qtext = @"
SELECT DISTINCT 
  dbo.v_ClientCollectionMembers.CollectionID, 
  dbo.v_Collection.Name AS CollectionName, 
  dbo.v_ClientCollectionMembers.ResourceID, 
  dbo.v_ClientCollectionMembers.Name, 
  dbo.v_ClientCollectionMembers.Domain, 
  dbo.v_ClientCollectionMembers.SiteCode, 
  dbo.v_ClientCollectionMembers.IsClient
FROM dbo.v_ClientCollectionMembers INNER JOIN
  dbo.v_Collection ON dbo.v_ClientCollectionMembers.CollectionID = dbo.v_Collection.CollectionID
WHERE (dbo.v_ClientCollectionMembers.Name = '$ComputerName')
ORDER BY CollectionName
"@

$DatabaseName = "CM_$SiteCode"
$QueryTimeout = 120
$ConnectionTimeout = 30
#Action of connecting to the Database and executing the query and returning results if there were any.
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
try {
    $conn.Open()
    Write-Verbose "connection opened successfully"
}
catch {
    Write-Error $_.Exception.Message
    break
}
$cmd = New-Object System.Data.SqlClient.SqlCommand($qtext,$conn)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
$rowcount = $($ds.Tables).Rows.Count
if ($rowcount -gt 0) {
    Write-Host "$rowcount rows returned" -ForegroundColor Green
    $($ds.Tables).Rows
}
