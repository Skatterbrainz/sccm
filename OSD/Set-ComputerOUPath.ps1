<#
.SYNOPSIS
    Set AD OU Path in CM OSD Task Sequence using IP Gateway
.DESCRIPTION
    Set AD OU Path in CM OSD Task Sequence using IP Gateway
.PARAMETER Gateway
    Forced IP gateway value (for testing only). Default is empty string
.PARAMETER DataFile
    Name of OU mapping txt file. Must be in same path as script. Default is oulocations.txt
.PARAMETER WorkstationsOU
    Name of leaf OU for desktops and workstations. Default is "Workstations"
.PARAMETER LaptopsOU
    Name of leaf OU for Laptops. Default is "Laptops"
.PARAMETER ServersOU
    Name of leaf OU for servers. Default is "Servers"
.EXAMPLE
    Set-ComputerOUPath.ps1
    Look for matching row in oulocations.txt using actual IPv4 gateway
.EXAMPLE
    Set-ComputerOUPath.ps1 -Gateway "192.168.3.1"
    Look for matching row in oulocations.txt using forced IPv4 gateway value
.EXAMPLE
    Set-ComputerOUPath.ps1 -DataFile "mygateways.txt"
    Look for matching row in custom data file using actual IPv4 gateway
#>
[CmdletBinding()]
param (
    [parameter()][string] $Gateway = "",
    [parameter()][string] $WorkstationsOU = "Workstations",
    [parameter()][string] $LaptopsOU = "Laptops",
    [parameter()][string] $ServersOU = "Servers",
    [parameter()][ValidateNotNullOrEmpty()][string] $DataFile = "oulocations.txt"
)

$cfgfile = Join-Path $PSScriptRoot $DataFile
$result = 0

function Get-FormFactorCode {
    [CmdletBinding()]
    param ()
    try {
        $mn = (Get-CimInstance -Namespace root/cimv2 -Class Win32_ComputerSystem).Model
        $ct = ((Get-CimInstance -Namespace root/cimv2 -Class Win32_SystemEnclosure).ChassisTypes)
        # ignore docks/port replicators which often 
        # return an array rather than one value
        if ($mn -match 'Virtual') { $ff = 'V' }
        else {
            if ($ct.Count -gt 1) { 
                $ct = $ct[0]
                Write-Verbose "*** multiple values returned"
            }
            Write-Verbose "*** wmi chassis type = $ct"
            switch ($ct) {
                {($_ -in (3,4,5,6,7,13,15,24,35))} { $ff = 'D' }
                {($_ -in (8,9,10,12,14,18,21))} { $ff = 'L' }
                {($_ -in (17,19,20,22,23,25,26,27,28,29))} { $ff = 'S' }
                {($_ -in (30,31,32))} { $ff = 'T' }
                {($_ -in (11))} { $ff = 'M' }
                {($_ -in (1,2,33))} { $ff = 'O' }
                {($_ -in (34))} { $ff = 'E' }
            }
        }
        Write-Output $ff
    }
    catch {}
}

try {
    if (!(Test-Path $cfgfile)) {
        throw "file not found: $cfgfile"
    }
    Write-Verbose "*** reading data from $cfgfile"
    $cfgdata = Get-Content -Path $cfgfile
    if ([string]::IsNullOrEmpty($Gateway)) {
        $Gateway = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | 
            Where-Object {$_.IPEnabled -eq $True -and $_.DefaultIPGateway -ne '::'} | 
                Select-Object -ExpandProperty DefaultIPGateway
    }
    Write-Verbose "*** current IP gateway is $Gateway"
    $i = 0
    while ([string]::IsNullOrEmpty($oupath)) {
        $row = $cfgdata[$i] -split ':'
        if ($row[0] -eq $Gateway) {
            $oupath = $row[2]
        }
        $i++
    }
    if ([string]::IsNullOrEmpty($oupath)) {
        throw "no matching value found"
    }
    else {
        $ffcode = Get-FormFactorCode
        switch ($ffcode) {
            'D' {$oupath = "OU=$WorkstationsOU,$oupath"}
            'V' {$oupath = "OU=$WorkstationsOU,$oupath"}
            'L' {$oupath = "OU=$LaptopsOU,$oupath"}
            'S' {$oupath = "OU=$ServersOU,$oupath"}
            default { throw "no mapping for form factor $ffcode" }
        }
    }
    try {
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
        $tsActive = $true 
    }
    catch {}
    if ($tsActive) {
        # suppress progress form only if presenting a new UI
        # $tsui  = New-Object -COMObject Microsoft.SMS.TSProgressUI
        Write-Verbose "*** assigning OSDDomainOUName to $oupath"
        $tsenv.Value("OSDDomainOUName") = $oupath
    }
    else {
        Write-Verbose "*** running in interactive mode ***"
        Write-Verbose "*** OSDDomainOUName = $oupath"
    }
}
catch {
    $result = -1
    Write-Verbose $Error[0].Exception.Message
}
finally {
    Write-Output $result
}