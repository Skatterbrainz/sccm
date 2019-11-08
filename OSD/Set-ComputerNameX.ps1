<#
.SYNOPSIS
	Set Computer Name in Task Sequence
.DESCRIPTION
	Set OSDComputerName variable using serial number and form factor
.PARAMETER Format
	Naming format. Either "Form-Serial" or "Serial". Default is "Serial"
.PARAMETER WorkstationPrefix
	Prefix for Desktop/Workstation devices. Default is "WS"
.PARAMETER LaptopPrefix
	Prefix for Laptop devices.  Default is "LT"
.PARAMETER NameLength
	Overall length of name. Default is 8 characters
.PARAMETER TrimSerialFrom
	Which end of serial number to trim when name is too long, "Left" or "Right". Default is "Left"
.EXAMPLE
	Set-ComputerNameX.ps1 -Format Form-Serial -NameLength 5 -TrimSerialFrom Left -Verbose
.EXAMPLE
	Set-ComputerNameX.ps1 -Format Form-Serial -NameLength 4 -WorkstationPrefix "W" -Verbose
#>
[CmdletBinding()]
param (
    [parameter()][ValidateSet('Serial','Form-Serial')][string] $Format = 'Serial',
    [parameter()][ValidateSet('D','DT','W','WS')][string] $WorkstationPrefix = 'WS',
    [parameter()][ValidateSet('L','LT')][string] $LaptopPrefix = 'LT',
    [parameter()][int] $NameLength = 8,
    [parameter()][ValidateSet('Left','Right')][string] $TrimSerialFrom
)

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
    # get chassis type
    if ($sn.Length -gt $NameLength) {
        if ($TrimSerialFrom -eq 'Left') {
            $curlen = $sn.Length
            $sn = $sn.Substring($NameLength - $curlen-1, $NameLength)
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
        $result = "$pfx`-$sn"
    }
    try {
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
        #$tsui  = New-Object -COMObject Microsoft.SMS.TSProgressUI
        Write-Verbose "*** assigning OSDComputerName to $result"
        $tsenv.Value("OSDComputerName") = $result
    }
    catch {
        Write-Verbose "*** not running in a task sequence environment"
    }
}
catch {
    Write-Error $_.Exception.Message 
}
finally {
    Write-Output $result
}
