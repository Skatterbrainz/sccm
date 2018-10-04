<#
.DESCRIPTION
    Query ConfigMgr SQL database for software product installs
.PARAMETER ProductName
    List: Office, ProjectStd, ProjectPro, VisioStd, VisioPro, All, Custom
.PARAMETER AppFilter
    Product Name filter when using ProductName = Custom. Use % for wildcards
.PARAMETER ServerName
    ConfigMgr SQL Server host name
.PARAMETER SiteCode
    ConfigMGr site code
.PARAMETER TotalCount
    Show total row counts only (default is show all rows)
.PARAMETER Detailed
    Show additional columns in output
.PARAMETER NoCount
    Do not show total row count when displaying row-level results (does not apply to -TotalCount)
.EXAMPLE
    .\Get-CmAppInstalls.ps1 -ProductName ProjectPro
.EXAMPLE
    .\Get-CmAppInstalls.ps1 -ProductName ProjectPro -Detailed
.EXAMPLE
    .\Get-CmAppInstalls.ps1 -ProductName ProjectPro -TotalCount
.EXAMPLE
    .\Get-CmAppInstalls.ps1 -ProductName Custom -AppFilter "Microsoft Project Standard 2013%" -Detailed
.EXAMPLE
    .\Get-CmAppInstalls.ps1 -AppFilter "Microsoft Project%" -ServerName "cm01.contoso.local" -SiteCode "P01"
.EXAMPLE
    .\Get-CmAppInstalls.ps1 -ProductName ProjectPro -NoCount) | Where {$_.Computer -like 'ABC123*'}
.EXAMPLE
    .\Get-CmAppInstalls.ps1 -ProductName ProjectPro -NoCount) | Out-GridView
.NOTES
    2018.10.03 - DS - First release
    2018.10.04 - DS - Added ProductName list, NoCount and Detailed params
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Product Name Filter")]
        [ValidateSet('Office','ProjectStd','ProjectPro','VisioStd','VisioPro','All','Custom')]
        [string] $ProductName = 'Office',
    [parameter(Mandatory=$False, HelpMessage="Product Name to filter on")]
        [ValidateNotNullOrEmpty()]
        [string] $AppFilter = "Microsoft Office 365 ProPlus%",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr DB Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName = "cm01.contoso.local",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "P01",
    [parameter(Mandatory=$False, HelpMessage="Show Total row count only")]
        [switch] $TotalCount,
    [parameter(Mandatory=$False, HelpMessage="Show Detailed Columns")]
        [switch] $Detailed,
    [parameter(Mandatory=$False, HelpMessage="Suppress total count on detailed results")]
        [switch] $NoCount
)
switch ($ProductName) {
    'Office' {
        $AppFilter = "Microsoft Office 365 ProPlus%"
        break
    }
    'ProjectPro' {
        $AppFilter = "Microsoft Project Professional%"
        break
    }
    'ProjectStd' {
        $AppFilter = "Microsoft Project Standard%"
        break
    }
    'VisioPro' {
        $AppFilter = "Microsoft Visio Professional%"
        break
    }
    'VisioStd' {
        $AppFilter = "Microsoft Visio Standard%"
        break
    }
    default {
        break
    }
}

$DatabaseName = "CM_$SiteCode"

$columns = @"
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 AS ProductName, 
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductVersion0 AS [Version],
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.Publisher0 AS Publisher
"@

$groupby = @"
GROUP BY ProductName0, ProductVersion0, Publisher0
"@

if ($Detailed) {
    $columns += @"
,dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstallSource0 AS [Source],
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstalledLocation0 AS [Location]
"@
    $groupby += ",InstallSource0,InstalledLocation0"
}

if ($Product -eq 'ALL') {
    $query = @"
SELECT DISTINCT 
$columns, COUNT(*) AS Installs
FROM dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED 
$groupby
"@
}
else {
    $query = @"
SELECT DISTINCT 
dbo.v_R_System.Name0 AS Computer, $columns 
FROM dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED INNER JOIN
dbo.v_R_System ON dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ResourceID = dbo.v_R_System.ResourceID
WHERE (dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE '$AppFilter')
"@
}

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
    $rows = $($ds.Tables).Rows.Count
    $($ds.Tables).Rows
    if (!$NoCount) { Write-Output "rows: $rows" }
}
