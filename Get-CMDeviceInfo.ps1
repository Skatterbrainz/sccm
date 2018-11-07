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
    1.0.2 - DS - fixed SQL query to correct outer join issue
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
Write-Verbose "----------------------------------------------"
if ($ComputerNames.Count -gt 1) {
    Write-Verbose "(Get-CmDeviceInfo - $($ComputerNames.Count) names)"
}
else {
    Write-Verbose "(Get-CmDeviceInfo - $ComputerNames)"
}
$DatabaseName = "CM_$SiteCode"
Write-Verbose "database name is $DatabaseName"
$queryBase = @"
SELECT DISTINCT 
	dbo.v_R_System.Name0 AS [Name], 
	dbo.v_R_System.ResourceID, 
	dbo.v_R_System.AD_Site_Name0 AS [ADSite], 
	dbo.vWorkstationStatus.ClientVersion, 
	dbo.vWorkstationStatus.LastHardwareScan AS [LastHwScan], 
    DATEDIFF(dd,dbo.vWorkstationStatus.LastHardwareScan,GETDATE()) AS InvAge,
    dbo.vWorkstationStatus.LastPolicyRequest,
    dbo.vWorkstationStatus.LastHealthEvaluationResult AS [LastHealthEval],  
	dbo.v_GS_COMPUTER_SYSTEM.Model0 AS [Model], 
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS [OperatingSystem], 
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
    dbo.vWorkstationStatus.LastDDR, 
	dbo.vWorkstationStatus.SystemType, 
	CASE 
		WHEN (dbo.vWorkstationStatus.IsVirtualMachine = 1) THEN 'Y' 
		ELSE 'N' END AS IsVM, 
	dbo.vWorkstationStatus.UserName, 
	dbo.vWorkstationStatus.UserDomain, 
	dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0 AS [SerialNumber]
FROM 
	dbo.v_R_System 
	LEFT OUTER JOIN
    dbo.v_GS_SYSTEM_ENCLOSURE ON dbo.v_R_System.ResourceID = dbo.v_GS_SYSTEM_ENCLOSURE.ResourceID 
	LEFT OUTER JOIN
    dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID 
	LEFT OUTER JOIN
    dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID 
	LEFT OUTER JOIN
    dbo.vWorkstationStatus ON dbo.v_R_System.ResourceID = dbo.vWorkstationStatus.ResourceID
"@
$query = $queryBase
if ($ComputerNames.Count -gt 1) {
    $complist = ($ComputerNames | %{"'$_'"}) -join ','
    $query += " WHERE (dbo.v_R_System.Name0 IN ($complist)) ORDER BY dbo.v_R_System.Name0"
}
else {
    $query += " WHERE (dbo.v_R_System.Name0 = '$ComputerNames')"
}
#Write-Verbose $query
.\tools\Get-CMSQLQueryData.ps1 -Query $query -SQLServerName $ServerName -SiteCode $SiteCode
