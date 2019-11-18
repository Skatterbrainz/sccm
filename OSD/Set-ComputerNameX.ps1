<#
.SYNOPSIS
    Yet another device naming script for OSD
.DESCRIPTION
    Yet another device naming script for OSD and yes I know thats a repeat
.PARAMETER Format
    Naming format: Serial or Form-Serial (default: Serial)
    Serial = BIOS Serial Number
    Form-Serial = Form-Factor + BIOS Serial Number
.PARAMETER WorkstationPrefix
    Default prefix for Desktop/Workstation devices: D, DT, W, WS (default: WS)
.PARAMETER LaptopPrefix
    Default prefix for Laptop devices: L, LT (default: LT)
.PARAMETER NameLength
    Maximum characters to limit new device name (truncate if needed). Default is 8
.PARAMETER TrimSerialFrom
    Which side of BIOS Serial Number to trim when necessar: Left or Right (default: Left)
.PARAMETER Delimiter
    Option for joining naming components when -Format is Form-Serial: None, Hyphen, Underscore (default: None)
    Hyphen: Form-SerialNumber
    Underscore: Form_SerialNumber
    None: FormSerialNumber
.EXAMPLE
    Set-ComputerNameX.ps1 -Format Form-Serial -Delimiter Hyphen
    (laptop) "LT-67890"
.EXAMPLE
    Set-ComputerNameX.ps1 -Format Form-Serial -Delimiter Hyphen -NameLength 5
    (laptop) "LT-90"
.EXAMPLE
    Set-ComputerNameX.ps1 -Format Form-Serial -Delimiter Hyphen -TrimSerialFrom Right
    (laptop) "LT-12345"
.EXAMPLE
    Set-ComputerNameX.ps1 -Format Form-Serial
    (laptop) "LT123456"
#>
[CmdletBinding()]
param (
    [parameter()][ValidateSet('Serial','Form-Serial')][string] $Format = 'Serial',
    [parameter()][ValidateSet('D','DT','W','WS')][string] $WorkstationPrefix = 'WS',
    [parameter()][ValidateSet('L','LT')][string] $LaptopPrefix = 'L',
    [parameter()][int] $NameLength = 8,
    [parameter()][ValidateSet('Left','Right')][string] $TrimSerialFrom = 'Left',
    [parameter()][ValidateSet('None','Hyphen','Underscore')][string] $Delimiter = 'None'
)
$ErrorActionPreference = 'stop'

function Get-FormFactorCode {
	[CmdletBinding()]
    param ()
    $cff = $(Get-CimInstance -ClassName Win32_SystemEnclosure -Namespace root\cimv2).ChassisTypes
	# ignore docks/port replicators which return an array rather than one value
    if ($cff.Count -gt 1) {
        $cff = $cff[0]
        Write-Verbose "*** filtering out duplicate for external device"
    }
    Write-Verbose "*** chassis type = $cff"
    # as of Q1-2018, codes are from 1 to 36
    # see https://blogs.technet.microsoft.com/brandonlinton/2017/09/15/updated-win32_systemenclosure-chassis-types/
    # desktops
    if ($cff -in (3..7)+(13,34,35)) { $ff = $WorkstationPrefix }
    # laptops
    elseif ($cff -in (10,11,12,14)+(15..30)+(31,32,33,36)) { $ff = $LaptopPrefix }
    # servers, but whatever, I do what I want!
    elseif ($cff -in (17..24)) { $ff = $WorkstationPrefix }
    # unknown
    else { $ff = $WorkstationPrefix }
    Write-Output $ff
}

try {
    $result = ""
    # get serial number
    $sn = $(Get-CimInstance -ClassName Win32_SystemEnclosure -Namespace root\cimv2).SerialNumber
    Write-Verbose "*** serial number... $sn"
    
    if ($sn.Length -gt $NameLength) {
        if ($TrimSerialFrom -eq 'Left') {
            $curlen = $sn.Length
            $sn = $sn.Substring($curlen - $NameLength, $NameLength)
        }
        else {
            $sn = $sn.Substring(0, $NameLength)
        }
    }
    Write-Verbose "*** trimmed value... $sn"
    if ($Format -eq 'Serial') {
        $result = $sn
    }
    else {
        $pfx = Get-FormFactorCode -Verbose:$VerbosePreference
        switch ($Delimiter) {
            'Hyphen' {$result = "$pfx`-$sn"}
            'Underscore' {$result = "$pfx`_$sn"}
            Default {$result = "$pfx$sn"}
        }
    }
    try {
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
        # suppress progress form only if presenting a new UI
        # $tsui  = New-Object -COMObject Microsoft.SMS.TSProgressUI
        Write-Verbose "*** assigning OSDComputerName to $result"
        $tsenv.Value("OSDComputerName") = $result
    }
    catch {
        Write-Verbose "*** not running in a task sequence environment"
    }
}
catch {
    Write-Error $Error[0].Exception.Message
}
finally {
    Write-Output $result
}