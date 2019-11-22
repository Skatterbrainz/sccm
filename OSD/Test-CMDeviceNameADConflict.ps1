<#
.SYNOPSIS
    Checks if Computer Name already exists in AD domain
.DESCRIPTION
    Checks if Computer Name already exists in AD domain.
    Sets task sequence variable (TSVariable) to "TRUE" if found.
.PARAMETER URI
    URI to web service.This is typically the "http://<SMSProvider>/ConfigMgrWebService/ConfigMgr.asmx"
.PARAMETER SecretKey
    The secret key string set during ConfigMgrWebService installation
.PARAMETER TSVariable
    Name of task sequence variable to set/update
.PARAMETER ComputerName
    Explicit computer name to use, for testing purposes.
    The default is "", and TS variable OSDComputerName is used during task sequence execution
.PARAMETER Delete
    Delete computer account in AD and CM DB if found in AD
.EXAMPLE
    Test-CMDeviceNameADConflict.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "12352342" -TSVariable "ACCTEXISTS"
    Sets TS variable "ACCTEXISTS" to "TRUE" if %OSDComputerName% value exists in Active Directory domain
.EXAMPLE
    Test-CMDeviceNameADConflict.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "12352342" -TSVariable "ACCTEXISTS" -Delete
    Sets TS variable "ACCTEXISTS" to "FALSE" if %OSDComputerName% value is found and deleted in Active Directory domain
.EXAMPLE
    Test-CMDeviceNameADConflict.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "12352342" -TSVariable "ACCTEXISTS" -ComputerName "WS004"
    Sets TS variable "ACCTEXISTS" to "TRUE" if computer "WS004"" exists in Active Directory domain
    This is mainly for testing outside of a task sequence environment
.NOTES
    Requires the ConfigMgrWebService from SCConfigMgr.com
    added RemoveCMDeviceByName step after AD account delete (only if -Delete is used)
#>
[CmdletBinding()]
param (
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $URI,
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SecretKey,
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TSVariable,
    [parameter()][string] $ComputerName = "",
    [switch] $Delete
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
        if ($tsActive) { $tsenv.Value("$TSVariable") = "TRUE" }
        Write-Verbose "*** Set $TSVariable = 'TRUE'"
        if ($Delete) {
            Write-Verbose "*** deleting $ComputerName`$ from Active Directory"
            $ws.RemoveADComputer($SecretKey, "$ComputerName`$") | Out-Null
            Write-Verbose "*** deleting $ComputerName from cm database"
            $ws.RemoveCMDeviceByName($SecretKey, "$ComputerName") | Out-Null
            if ($tsActive) { $tsenv.Value("$TSVariable") = "FALSE" }
            Write-Verbose "*** account has been deleted"
        }
    }
    else {
        if ($tsActive) { $tsenv.Value("$TSVariable") = "FALSE" }
        Write-Verbose "*** account was not found"
    }
}
catch {
    $_.Exception.Message; Exit 1
}