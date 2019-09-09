<#
.SYNOPSIS
    Set OSDComputerName variable to custom format
.DESCRIPTION
    Set name format (LocationCode + FormatFactor + SerialNumber)
    Example "NYCD12345678901" ("NYC" + "D" + "12345678901")
.PARAMETER LocationFile
    Name of file containing location/gateway mapping information (same folder path as script)
.PARAMETER TrimFrom
    Which side (left/right) to trim serialnumber when exceeds 15 overall
#>
[CmdletBinding()]
param (
    [parameter()] [string] $LocationFile = $(Join-Path $PSScriptRoot 'locations.txt'),
    [parameter()] [ValidateSet('Left','Right')] [string] $TrimFrom = 'Left'
)

function Get-SerialNumber {
	[CmdletBinding()]
    param ()
    $csn = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty SerialNumber
    if ($csn.Count -gt 1) { $csn = $csn[0] }
    Write-Verbose "full serial number = $csn"
    if ($csn.Length -gt 15) {
        Write-Verbose "trim side = $TrimFrom"
        if ($TrimFrom -eq 'Left') {
            $csn = $csn.Substring($csn.Length - 15)
        }
        else {
            $csn = $csn.Substring(0, 15)
        }
    }
    Write-Verbose "constrained serial number = $csn"
    Write-Output $csn
}

function Get-FormFactorCode {
	[CmdletBinding()]
    param ()
    $cff = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
	# ignore docks/port replicators which return an array rather than one value
    if ($cff.Count -gt 1) { $cff = $cff[0] }
    Write-Verbose "chassis type is $cff"
    # as of Q1-2018, codes are from 1 to 36
    # see https://blogs.technet.microsoft.com/brandonlinton/2017/09/15/updated-win32_systemenclosure-chassis-types/
    # desktops
    if ($cff -in (3..7)+(13,34,35)) { $ff = 'D' }
    # laptops
    elseif ($cff -in (15..30)+(14,31,32,33,36)) { $ff = 'L' }
    # servers
    elseif ($cff -in (17..24)) { $ff = 'S' }
    # unknown
    else { $ff = 'X' }
    Write-Verbose "form factor code: $ff"
    Write-Output $ff
}

function Get-LocationCode {
	[CmdletBinding()]
    param (
        [parameter(Mandatory=$False, HelpMessage="Default Location Code")]
        [string] $DefaultLoc = "",
        [parameter(Mandatory=$False, HelpMessage="Path to Location codes text file")]
        [string] $DataFile = $LocationFile
    )
    try {
        $gwa = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $True} | Select-Object -ExpandProperty DefaultIPGateway
        <#
        format of location data is as follows:
        GATEWAY=FULLNAME,ABBREV (no headings in file, shown here just for explanation)
        10.0.0.1=NEWYORK,NYC
        10.2.0.1=LOSANGELES,LAX
        #>
        if (!(Test-Path -Path $DataFile)) {
            Write-Verbose "data file not found: $DataFile"
            Write-Output ""
            break
        }
        $shortname = ""
        $dataset = Get-Content -Path $DataFile
        if ($dataset.length -gt 0) {
            Write-Verbose "data loaded from text file"
        }
        foreach ($row in $dataset) {
            $rowdata = $row -split '='
            $gateway = $rowdata[0]
            if ($gateway -eq $GatewayIPAddress) {
                $location  = $rowdata[1]
                $fullname  = ($location -split ',')[0]
                $shortname = ($location -split ',')[1]
                Write-Verbose "location: $fullname"
                Write-Verbose "shortname: $shortname"
                break
            }
        }
        if ($shortname -eq "") { $shortname = $DefaultLoc }
        Write-Verbose "location code is: $shortname"
        Write-Output $shortname
    }
    catch {
        Write-Error $Error[0].Exception.Message
        Write-Output ""
    }
}

[string]$sn = Get-SerialNumber
[string]$fc = Get-FormFactorCode
[string]$lc = Get-LocationCode
Write-Verbose "serial number = $sn"
Write-Verbose "form factor code = $fc"
Write-Verbose "location code = $lc"
$tempname = $lc + $fc + $sn
Write-Verbose "temp name = $tempname"
$newname = $tempname
if ($tempname.Length -gt 15) {
    $newname = $tempname.Substring(0,15)
}
Write-Verbose "new name = $newname"
# try to get TS environment if available
try {
    $tsenv = New-Object -COMObject "Microsoft.SMS.TSEnvironment" -ErrorAction SilentlyContinue
}
catch {
    Write-Verbose "no task sequence running"
}
if ($null -ne $tsenv) {
    Write-Verbose "task sequence environment is active"
    $OSDComputername = $tsenv.Value("OSDComputername")
    Write-Verbose "current OSDcomputername = $OSDComputername"
    $tsenv.Value("OSDComputername") = $newname
    Write-Output "Set OSDComputername = $($tsenv.value("OSDComputername"))"
}
else {
    Write-Verbose "not running in a task sequence"
    Write-Output "OSDComputer would be set to $newname"
}
