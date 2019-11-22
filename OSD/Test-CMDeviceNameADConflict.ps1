<#
.SYNOPSIS
.DESCRIPTION

#>
[CmdletBinding()]
param (
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $URI,
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SecretKey,
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TSVariable,
    [parameter()][string] $ComputerName = ""
)
try {
    $tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
    $tsActive = $True
    Write-Verbose "*** task sequence environment detected"
}
catch {
    Write-Verbose "*** not running in a task sequence"
}
try {
    $ws = New-WebServiceProxy -Uri $URI -ErrorAction 'stop'
    if ([string]::IsNullOrEmpty($ComputerName)) {
        if ($tsActive) {
            $ComputerName = $($tsenv.Value("OSDComputerName")).Trim()
        }
    }
    if ([string]::IsNullOrEmpty($ComputerName)) {
        throw "computer name is null or empty - boo!"
    }
    Write-Verbose "*** searching for account: $ComputerName"
    if (![string]::IsNullOrEmpty(($ws.GetADComputer($SecretKey, $ComputerName)).SamAccountName)) {
        if ($tsActive) {
            $tsenv.Value("$TSVariable") = "TRUE"
        }
        else {
            Write-Verbose "*** $TSVariable = 'TRUE'"
        }
    }
}
catch {
    $_.Exception.Message; Exit 1
}