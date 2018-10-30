[CmdletBinding()]
param (
    [parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $ServerName,
    [parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $SiteCode,
    [parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string[]] $ComputerNames
)
Write-Host "getting configmgr data"
$DatabaseName = "CM_$SiteCode"
Write-Verbose "database name is $DatabaseName"
$queryBase = @"
SELECT DISTINCT 
	dbo.vWorkstationStatus.Name, 
	dbo.vWorkstationStatus.UserName,
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OperatingSystem, 
	CASE 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 10586) THEN '1511' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 14393) THEN '1607' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 15063) THEN '1703' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 16299) THEN '1709' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 17134) THEN '1803' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 17604) THEN '1809' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 7601) THEN 'SP1' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 9600) THEN 'RTM' 
		ELSE dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 END AS OsBuild, 
	dbo.vWorkstationStatus.SystemType, 
	dbo.vWorkstationStatus.ClientVersion, 
	dbo.vWorkstationStatus.UserDomain, 
	dbo.v_R_System.AD_Site_Name0 AS ADSite, 
	dbo.v_GS_COMPUTER_SYSTEM.Model0 AS Model, 
	dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0 AS SerialNumber, 
	CASE 
		WHEN (dbo.vWorkstationStatus.IsVirtualMachine = 1) THEN 'Y' 
		ELSE 'N' END AS IsVM, 
	dbo.vWorkstationStatus.LastHealthEvaluationResult AS LastHealthEval, 
	dbo.vWorkstationStatus.LastHardwareScan AS LastHwScan, 
	DATEDIFF(dd,dbo.vWorkstationStatus.LastHardwareScan,GETDATE()) AS InvAge,
	dbo.vWorkstationStatus.LastDDR
FROM 
	dbo.vWorkstationStatus INNER JOIN
	dbo.v_R_System ON dbo.vWorkstationStatus.ResourceID = dbo.v_R_System.ResourceID LEFT OUTER JOIN
	dbo.v_GS_SYSTEM_ENCLOSURE ON dbo.vWorkstationStatus.ResourceID = dbo.v_GS_SYSTEM_ENCLOSURE.ResourceID LEFT OUTER JOIN
	dbo.v_GS_COMPUTER_SYSTEM ON dbo.vWorkstationStatus.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID LEFT OUTER JOIN
	dbo.v_GS_OPERATING_SYSTEM ON dbo.vWorkstationStatus.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID
"@
$query = $queryBase
if ($ComputerNames.Count -gt 1) {
    $complist = ($ComputerNames | %{"'$_'"}) -join ','
    $query += " WHERE (dbo.vWorkstationStatus.Name IN ($complist)) ORDER BY dbo.vWorkstationStatus.Name"
}
else {
    $query += " WHERE (dbo.vWorkstationStatus.Name = '$ComputerNames')"
}
#Write-Host $query
#break
$QueryTimeout = 120
$ConnectionTimeout = 30
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
$rows = $($ds.Tables).Rows.Count
$($ds.Tables).Rows
