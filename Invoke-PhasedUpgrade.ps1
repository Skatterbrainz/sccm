#requires -version 3
<#
.DESCRIPTION
    I really don't know how to describe this.
    Must be executed on a machine that has a ConfigMgr CB console installed
.PARAMETER SiteCode
    ConfigMgr Site Code
.PARAMETER SiteServer
    Site server FQDN
.PARAMETER SourceCollection
    Source collection from which to copy resources to target1 and target2
.PARAMETER TargetCollection1
    Intermedia target collection name
.PARAMETER TargetCollection2
    Final target collection name
.PARAMETER RowCount
    Number of resources to add to collection1 per cycle
.PARAMETER DelayHours
    Time delay between adding to collection1 and moving to collection2
.PARAMETER LogPath
.NOTES
    0.1 - DS - Initial release
.EXAMPLE
    .\Invoke-PhasedUpgrade.ps1 -RowCount 2 -DelayHours 2
#>
[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$False, HelpMessage="Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "P01",
    [parameter(Mandatory=$False, HelpMessage="Site Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteServer = "cm01.contoso.local",
    [parameter(Mandatory=$False, HelpMessage="Source Collection Name")]
        [ValidateNotNullOrEmpty()]
        [string] $SourceCollection = "OSD Upgrade to Windows 10 1803 (targets)",
    [parameter(Mandatory=$False, HelpMessage="Target Collection1 Name")]
        [ValidateNotNullOrEmpty()]
        [string] $TargetCollection1 = "OSD Upgrade to Windows 10 1803 (available)",
    [parameter(Mandatory=$False, HelpMessage="Target Collection2 Name")]
        [ValidateNotNullOrEmpty()]
        [string] $TargetCollection2 = "OSD Upgrade to Windows 10 1803 (mandatory)",
    [parameter(Mandatory=$False, HelpMessage="Max resources to copy per cycle")]
        [ValidateRange(1,1000)]
        [int] $RowCount = 10,
    [parameter(Mandatory=$False, HelpMessage="Hours to allow resources to sit in target collection1")]
        [ValidateRange(1,240)]
        [int] $DelayHours = 36,
    [parameter(Mandatory=$False, HelpMessage="Path for resource log files")]
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$($env:WINDIR)\temp"
)
$time1 = Get-Date
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change the following block of lines

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $SiteServer @initParams
}

# Set the current location to be the site code.
$Loc = Get-Location
Push-Location "$($SiteCode):\" @initParams

function Get-TrackingLog {
    param (
        [string] $ComputerName, 
        [string] $CollectionName
    )
    $fn = Join-Path -Path $LogPath -ChildPath "$ComputerName`_addto_$CollectionName`.txt"
    if (Test-Path $fn) {
        $ts = $(Get-ChildItem -Path $fn).CreationTime
    }
    $ts
}

function New-TrackingLog {
    param (
        [string] $ComputerName,
        [string] $CollectionName
    )
    Write-Verbose "creating device log: $ComputerName"
    $ts = "$((Get-Date).ToShortDateString()) $((Get-Date).ToLongTimeString())"
    $fn = Join-Path -Path $LogPath -ChildPath "$ComputerName`_addto_$CollectionName`.txt"
    $ComputerName | Out-File -FilePath $fn -Force
}

function Get-CmDeviceCollectionDelta {
    param (
        [parameter(Mandatory=$True, HelpMessage="Device Collection1 name")]
            [ValidateNotNullOrEmpty()]
            [string] $Collection1,
        [parameter(Mandatory=$True, HelpMessage="Device Collection2 name")]
            [ValidateNotNullOrEmpty()]
            [string] $Collection2,
        [parameter(Mandatory=$True, HelpMessage="Max number of resources to return")]
            [ValidateRange(1,1000)]
            [int] $Count = 10
    )
    try {
        $r1 = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $Collection1 -ErrorAction SilentlyContinue | Select -ExpandProperty RuleName
        $r2 = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $Collection2 -ErrorAction SilentlyContinue | Select -ExpandProperty RuleName
        $result = $r1 | Where-Object {$r2 -notcontains $_} | Select -First $Count 
    }
    catch {
        Write-Error $_.Exception.Message
    }
    , $result
}

Function Send-MailMessageEx {
    param (
        [parameter(Mandatory=$True, HelpMessage='Collection of object with ComputerName and Email properties')]
            [ValidateNotNullOrEmpty()]
            [string[]] $ComputerNameAndEmailList,
        [parameter(Mandatory=$False, HelpMessage='Email Subject)]
            [string] $EmailSubject = 'Updating Windows 10 on your computer',
        [parameter(Mandatory=$False, HelpMessage='Email Body Header')]
            [string] $EmailBodyHeader = 'A computer used by you will install an update for Windows 10. `Computer Name:',
        [parameter(Mandatory=$False, HelpMessage='SMTP Mail Server')]
            [string] $SMTPServer = 'stmp.contoso.com',
    )
    $Date = (get-date -f MM-dd-yyyy)
    ForEach ($Object in $ComputerNameAndEmailList) {
        Send-MailMessage -To $Object.email -From "<SCCMAdmin@contoso.com>" -Subject $EmailSubject -body "$(EmailBodyHeader) $(Object.ComputerName)" -SmtpServer $SMTPServer
    }
}

Write-Verbose "begin processing"

<#
1. get list of source collection members
2. get list of members in target c1 and c2
3. check for c1 member logs which are 36 hrs or older (group 1)
4. move group1 members to c2
5. 
#>

Write-Verbose "getting device collection member lists"

$CollSource    = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $SourceCollection | Select-Object -ExpandProperty RuleName
$CollAvailable = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection1 | Select-Object -ExpandProperty RuleName
$CollMandatory = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection2 | Select-Object -ExpandProperty RuleName

Write-Verbose "CollSource...... $($CollSource.count) members [$SourceCollection]"
Write-Verbose "CollAvailable... $($CollAvailable.count) members [$TargetCollection1]"
Write-Verbose "CollMandatory... $($CollMandatory.count) members [$TargetCollection2]"

$NextAvailable = Get-CmDeviceCollectionDelta -Collection1 $SourceCollection -Collection2 $TargetCollection1 -Count $RowCount
$count1 = 0
$count2 = 0

Write-Verbose "------------ available -------------"

if ($NextAvailable.count -gt 0) {
    Write-Verbose "next available.. $($NextAvailable.count) members -`> $($NextAvailable -join ',')"
    if ($CollMandatory.count -gt 0) {
        Write-Verbose "skipping computers which are already in the mandatory collection..."
        $NextAvailable = $NextAvailable | Where-Object {$CollMandatory -notcontains $_}
        Write-Verbose "CollAvailable... $($CollAvailable.count) members -`> $($CollAvailable -join ',')"
    }
    else {
        Write-Verbose "mandatory collection is empty"
    }
    if ($NextAvailable.count -gt 0) {
        Write-Verbose "adding members"
        foreach ($rn in $NextAvailable) {
            $device = Get-CMDevice -Name $rn
            try {
                if ($WhatIfPreference) {
                    Write-Verbose "--- adding $rn to: $TargetCollection1 (WhatIf)"
                    Add-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection1 -Resource $device -WhatIf
                    $count1++
                }
                else {
                    Write-Verbose "--- adding $rn to: $TargetCollection1"
                    Add-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection1 -Resource $device
                }
                Write-Verbose "...added: $rn"
                New-TrackingLog -ComputerName $rn -CollectionName $TargetCollection1
            }
            catch {
                Write-Error $_.Exception.Message
            }
        }
    }
    else {
        Write-Verbose "no changes - already member of collection"
    }
}
else {
    Write-Verbose "next available.. null"
}

Write-Verbose "------------ mandatory -------------"

$alist = Get-ChildItem -Path $LogPath -Filter "*.txt" | Where-Object {$_.Name -like "*_addto_*"}
foreach ($rn in $alist) {
    $ts = (New-TimeSpan -Start $rn.LastWriteTime -End (Get-Date)).Hours
    Write-Verbose "$ts hrs = $rn"
    $dat = $($rn -split '_addto_')
    $res = $dat[0] # resource name
    $col = $($dat[1] -replace '.txt','') # collection name
    
    if ( $col -eq $TargetCollection1 ) {
        Write-Verbose "--- $res should currently be sitting in the available collection"
    }
    if ( $col -eq $TargetCollection2 ) {
        Write-Verbose "--- $res should already in the mandatory collection"
    }
    if ($ts -ge $DelayHours) {
        Write-Verbose "--- time to move $res to the mandatory collection!"
        try {
            $device = Get-CMDevice -Name $res
            if ($WhatIfPreference) {
                Write-Verbose "--- adding $res to: $TargetCollection2 (WhatIf)"
                Add-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection2 -Resource $device -WhatIf
                Write-Verbose "--- removing $res from: $TargetCollection1 (WhatIf)"
                Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection1 -Resource $device -WhatIf
            }
            else {
                Write-Verbose "--- adding $res to: $TargetCollection2"
                Add-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection2 -Resource $device
                Write-Verbose "--- removing $res from: $TargetCollection1"
                Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $TargetCollection1 -Resource $device -Confirm:$False
                New-TrackingLog -ComputerName $res -CollectionName $TargetCollection2
                $count2++
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
} # foreach

Set-Location $Loc

Write-Verbose "$count1 members added to $TargetCollection1"
Write-Verbose "$count2 members moved to $TargetCollection2"

$time2 = Get-Date
New-TimeSpan -Start $time1 -End $time2

Write-Output "processing complete"
