#requires -Version 3.0
<#
.DESCRIPTION
    Get ConfigMgr Collection Members
.PARAMETER CollectionID
    ConfigMgr Collection ID
.PARAMETER ServerName
    ConfigMgr SQL Server hostname (FQDN)
.PARAMETER SiteCode
    ConfigMgr Site Code
.PARAMETER Choose
    Display collection names and ID numbers in grid view for selecting
.PARAMETER Ping
    Perform a ping test on each machine
.PARAMETER Grid
    Display results in gridview
.EXAMPLE 
    .\Get-CmCollectionMember.ps1 -CollectionID "P010015E" -ServerName "cm01.contoso.local" -SiteCode "P01"
.EXAMPLE
    .\Get-CmCollectionMember.ps1 -Choose -ServerName "cm01.contoso.local" -SiteCode "P01"
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True, HelpMessage="Collection ID")]
        [ValidateNotNullOrEmpty()]
        [string] $CollectionID = "SMS00001",
    [parameter(Mandatory=$True, HelpMessage="Site Database Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode,
    [parameter(Mandatory=$False, HelpMessage="Select Collection using Gridview")]
        [switch] $Choose,
    [parameter(Mandatory=$False, HelpMessage="Query if computer is online")]
        [switch] $Ping,
    [parameter(Mandatory=$False, HelpMessage="Display results in gridview")]
        [switch] $Grid
)
$DatabaseName = "CM_$SiteCode"
$QueryTimeout = 120
$ConnectionTimeout = 30
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

if ($Choose) {
    $q1 = "SELECT DISTINCT CollectionID, Name, MemberCount FROM dbo.v_Collection ORDER BY Name"
    $cmd = New-Object System.Data.SqlClient.SqlCommand($q1,$conn)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$da.Fill($ds)

    $rowcount = $($ds.Tables).Rows.Count
    if ($rowcount -gt 0) {
        Write-Host "$rowcount collections returned" -ForegroundColor Cyan
        $x = $($ds.Tables).Rows | Out-GridView -Title "Select Collection" -OutputMode Single
    }
    $conn.Close()
    if ($x) {
        $CollectionID = $x | Select -ExpandProperty CollectionID
    }
    else {
        Write-Warning "No selection made"
        break
    }
}

$qtext = @"
SELECT DISTINCT 
    dbo.v_R_System.Name0 AS ComputerName, 
    dbo.v_R_System.ResourceID, 
    dbo.v_R_System.User_Name0 AS UserName, 
    dbo.v_R_System.AD_Site_Name0 AS ADSite, 
    dbo.v_R_System.Operating_System_Name_and0 AS OS, 
    dbo.v_R_System.Build01 AS OSBuild, 
    CASE WHEN (Client0 = 1) THEN 'YES' ELSE 'NO' END AS Client, 
    dbo.v_R_System.Client_Version0 AS ClientVersion, 
    CASE WHEN (Active0 = 1) THEN 'YES' ELSE 'NO' END AS Active, 
    dbo.v_R_System.Distinguished_Name0, 
    dbo.v_R_System.Full_Domain_Name0 AS DNSDomain, 
    dbo.v_R_System.Is_Virtual_Machine0 AS IsVirtual, 
    dbo.v_R_System.Last_Logon_Timestamp0 AS LogonTime, 
    dbo.v_R_System.User_Domain0 AS Domain 
FROM dbo.v_R_System INNER JOIN
    dbo.v_ClientCollectionMembers ON dbo.v_R_System.ResourceID = dbo.v_ClientCollectionMembers.ResourceID
WHERE (dbo.v_ClientCollectionMembers.CollectionID = '$CollectionID')
ORDER BY ComputerName
"@

$cmd = New-Object System.Data.SqlClient.SqlCommand($qtext,$conn)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
$conn.Close()
$rowcount = $($ds.Tables).Rows.Count
if ($rowcount -gt 0) {
    if ($Grid) {
        $($ds.Tables).Rows | Out-GridView -Title "Collection Members: $CollectionID"
    }
    else {
        $result = $($ds.Tables).Rows
        foreach ($row in $result) {
            if ($Ping) {
                if (Test-NetConnection -ComputerName $row.ComputerName -InformationLevel Quiet) {
                    $Online = $True
                }
                else {
                    $Online = $False
                }
                $data = [ordered]@{
                    ComputerName  = $row.ComputerName
                    ResourceID    = $row.ResourceID
                    UserName      = $row.UserName
                    ADSiteName    = $row.ADSite
                    OSName        = $row.OS
                    OSBuild       = $row.OSBuild
                    IsVirtual     = $row.IsVirtual
                    LastLogon     = $row.LogonTime
                    IsClient	  = $row.Client
                    ClientVersion = $row.ClientVersion
                    IsActive      = $row.Active
                    Domain        = $row.Domain
                    SiteCode      = $SiteCode
                    IsOnline      = $Online
                }
            }
            else {
                $data = [ordered]@{
                    ComputerName  = $row.ComputerName
                    ResourceID    = $row.ResourceID
                    UserName      = $row.UserName
                    ADSiteName    = $row.ADSite
                    OSName        = $row.OS
                    OSBuild       = $row.OSBuild
                    IsVirtual     = $row.IsVirtual
                    LastLogon     = $row.LogonTime
                    IsClient	  = $row.Client
                    ClientVersion = $row.ClientVersion
                    IsActive      = $row.Active
                    Domain        = $row.Domain
                    SiteCode      = $SiteCode
                }
            }
            New-Object -TypeName PSObject -Property $data
        } # foreach
    } # if-else
}
