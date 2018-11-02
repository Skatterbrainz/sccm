#requires -version 3.0
<#
.DESCRIPTION
    Return query results for specific devices within ConfigMgr SQL database
.PARAMETER ServerName
    ConfigMgr SQL Server hostname
.PARAMETER SiteCode
    ConfigMgr site code
.PARAMETER ComputerNames
    Names of computers to query information about
.EXAMPLE
    $data = .\Get-CMDeviceInfo.ps1 -ServerName "cm01.contoso.local" -SiteCode "P01" -ComputerNames "DT123","DT456"
.NOTES
    1.0.1 - DS - Initial release
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr SQL Server host name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr site code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode,
    [parameter(Mandatory=$True, HelpMessage="Computer Names to query")]
        [ValidateNotNullOrEmpty()]
        [string[]] $ComputerNames
)
Write-Verbose "(Get-CmDeviceInfo - getting configmgr data)"
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
Write-Verbose $query
.\Get-CMSQLQueryData.ps1 -Query $query -SQLServerName $ServerName -SiteCode $SiteCode
