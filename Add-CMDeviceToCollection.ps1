[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$True, HelpMessage="Computer Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Collection ID")]
        [ValidateNotNullOrEmpty()]
        [string] $CollectionID,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr MP")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode
)

$oldLoc = Get-Location
Write-Verbose "current location is $oldLoc"
Write-Verbose "setting location to $SiteCode`:"
Set-Location "$($SiteCode):"

try {
    $ResourceID = Get-CMDevice -Name $ComputerName | Select -ExpandProperty ResourceID
    Write-Verbose "resourceID = $ResourceID"
    try {
        Add-CMDeviceCollectionDirectMembershipRule -CollectionId $CollectionID -ResourceId $ResourceID -ErrorAction SilentlyContinue
        $result = 0
    }
    catch {
        $result = $Error[0].Errors[0].ErrorId
    }
}
catch {
    Write-Warning $Error[0].Exception.Message
    $result = 2
}
finally {
    Write-Verbose "restoring previous location"
    Set-Location $oldLoc
}
Write-Verbose "process completed with $result"
Write-Output $result
