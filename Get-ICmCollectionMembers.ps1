#requires -Modules dbatools

function Get-ICmCollectionMembers {
    param (
		[parameter(Mandatory=$True, HelpMessage="Collection ID", ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=0)]
		[ValidateLength(8,8)]
        [string] $CollectionID,
		[parameter(Mandatory=$True, HelpMessage="Collection ID")]
		[ValidateNotNullOrEmpty()]
        [string] $SqlInstance,
		[parameter(Mandatory=$True, HelpMessage="Collection ID")]
		[ValidateLength(3,3)]
        [string] $SiteCode
    )
    try {
        $query = "SELECT DISTINCT 
v_ClientCollectionMembers.Name, 
v_ClientCollectionMembers.ResourceID, 
v_ClientCollectionMembers.Domain, 
v_ClientCollectionMembers.SiteCode, 
v_ClientCollectionMembers.IsClient, 
vWorkstationStatus.ClientVersion, 
vWorkstationStatus.UserName, 
vWorkstationStatus.LastHardwareScan, 
vWorkstationStatus.OperatingSystem, 
v_R_System.AD_Site_Name0 as ADSiteName, 
v_R_System.Last_Logon_Timestamp0 as LastLogon 
FROM v_ClientCollectionMembers INNER JOIN
vWorkstationStatus ON v_ClientCollectionMembers.ResourceID = vWorkstationStatus.ResourceID INNER JOIN
v_R_System ON v_ClientCollectionMembers.ResourceID = v_R_System.ResourceID
WHERE (v_ClientCollectionMembers.CollectionID = '$CollectionID')
ORDER BY Name"
        @(Invoke-DbaQuery -SqlInstance $SqlInstance -Database "CM_$SiteCode" -Query $query -ErrorAction Stop)
    }
    catch {
        Write-Error $Error[0].Exception.Message
    }
}
