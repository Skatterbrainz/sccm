#requires -Modules dbatools
#requires -Version 5.1
<#
.SYNOPSIS
    Export CSV file of Collection Members
.DESCRIPTION
    Export CSV file of Collection Members
.PARAMETER SiteServer
    Name of ConfigMgr site database host
.PARAMETER SiteCode
    3 character ConfigMgr site code
.PARAMETER CollectionType
    'Device' or 'User' (default is 'Device')
    User option is not yet ready
.EXAMPLE
    Export-CmCollectionMembers.ps1 -SiteServer "CM01" -SiteCode "P01"
    Exports all members of selected device collection to file
    Filename is COLLECTIONID-COLLECTIONNAME-Members.csv in the current working folder
.EXAMPLE
    Export-CmCollectionMembers.ps1 -SiteServer "CM01" -SiteCode "P01" -CollectionType 'User'
    Exports all members of selected user collection to file
    Filename is COLLECTIONID-COLLECTIONNAME-Members.csv in the current working folder
.NOTES
    1.0.0 - DS - Initial release

    PROVIDED "AS-IS" WITHOUT WARRANTY OR GUARANTEE OF ANY KIND FOR ANY PURPOSE
    USE AT YOUR OWN RISK.
#>
[CmdletBinding()]
param (
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SiteServer,
    [parameter(Mandatory)][ValidateLength(3,3)][string] $SiteCode,
    [parameter()][ValidateSet('Device')][string] $CollectionType = "Device"
)
try {
    if ($CollectionType -eq 'Device') {$Ctype = 2} else {$Ctype = 1}
    $qs = "select Name,CollectionID,MemberCount as Members,Comment from v_collection where CollectionType=$Ctype order by Name"
    $colls = Invoke-DbaQuery -SqlInstance $SiteServer -Database "CM_$SiteCode" -Query $qs
    Write-Verbose "$($colls.Count) collections returned from query"
    $coll = $colls | Out-GridView -Title "Select Collection to Export" -OutputMode Single
    if ($coll) {
        $cid = $coll.CollectionID
        $cn  = $coll.Name
        if ($coll.Members -eq 0) {
            Write-Warning "collection has no members to export"
        }
        else {
            $qm = "SELECT DISTINCT ccm.Name, ccm.IsClient AS Client, 
    sys.User_Name0 AS UserName, sys.Operating_System_Name_and0 AS OSName, 
    cs.Model0 AS Model, sys.AD_Site_Name0 AS ADSiteName 
    FROM v_ClientCollectionMembers AS ccm INNER JOIN 
    v_R_System AS sys ON ccm.ResourceID = sys.ResourceID INNER JOIN 
    v_GS_COMPUTER_SYSTEM AS cs ON ccm.ResourceID = cs.ResourceID 
    WHERE ccm.CollectionID = '$cid' ORDER BY Name"
            Write-Verbose "query: $qm"
            $csvFile = Join-Path $PSScriptRoot "$cid`-$cn`-Members.csv"
            $mbrs = Invoke-DbaQuery -SqlInstance $SiteServer -Database "CM_$SiteCode" -Query $qm | Foreach-Object {
                [pscustomobject]@{
                    Name       = [string]$_.Name
                    UserName   = [string]$_.UserName
                    OSName     = [string]$_.OSName
                    Model      = [string]$_.Model
                    ADSiteName = [string]$_.ADSiteName
                }
            }
            Write-Verbose "$($mbrs.Count) members returned from query"
            $mbrs | Export-Csv -Path $csvFile -NoTypeInformation -Force
            Write-Host "exported to $csvFile" -ForegroundColor Cyan
        }
    }
}
catch {
    Write-Error $Error[0].Exception.Message
}