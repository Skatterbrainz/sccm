<#
.DESCRIPTION
    Query ConfigMgr SQL database for software product installs
.PARAMETER AppFilter
    Product Name filter. Use % for wildcards
.PARAMETER ServerName
    ConfigMgr SQL Server host name
.PARAMETER SiteCode
    ConfigMGr site code
.PARAMETER TotalCount
    Show total row counts only (default is show all rows)
.EXAMPLE
    .Get-CmAppInstalls.ps1 -AppFilter "Microsoft Project%"
.EXAMPLE
    .Get-CmAppInstalls.ps1 -AppFilter "Microsoft Project%" -TotalCount
.EXAMPLE
    .Get-CmAppInstalls.ps1 -AppFilter "Microsoft Project%" -ServerName "cm01.contoso.local" -SiteCode "P01"
.NOTES
    2018.10.03 - DS - First release
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Product Name to filter on")]
        [ValidateNotNullOrEmpty()]
        [string] $AppFilter    = "Microsoft Office 365 ProPlus%",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr DB Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName   = "cm01.contoso.local",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "P01",
    [parameter(Mandatory=$False, HelpMessage="Show Total row count only")]
        [switch] $TotalCount
)
$DatabaseName = "CM_$SiteCode"

$query = @"
SELECT DISTINCT dbo.v_R_System.Name0, dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0, 
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductVersion0
FROM dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED INNER JOIN
dbo.v_R_System ON dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ResourceID = dbo.v_R_System.ResourceID
WHERE (dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE '$AppFilter')
"@

Write-Verbose "query...... $query"
Write-Verbose "server..... $ServerName"
Write-Verbose "database... $DatabaseName"
#Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30

#Action of connecting to the Database and executing the query and returning results if there were any.
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
$conn.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
$conn.Close()
if ($TotalCount) {
    $($ds.Tables).Rows.Count
}
else {
    $ds.Tables
}
