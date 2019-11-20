<#
.SYNOPSIS
    Query CM for next available sequential device name
.DESCRIPTION
    Query CM for next available sequential device name
.PARAMETER URI
    URI to web service. This is typically the "http://<SMSProvider>/ConfigMgrWebService/ConfigMgr.asmx"
.PARAMETER SecretKey
    The secret key string set during ConfigMgrWebService installation
.PARAMETER Prefix
    Prefix portion of the device name. If desired format is "WS001" then prefix would be "WS"
.PARAMETER NameLength
    Total length of desired device name. For "WS001" the value would be 5
.EXAMPLE
    Get-NextCMDeviceName.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -Prefix "WS" -NameLength 5
    Would return "WSxxx" where "xxx" is the next numeric suffix not found in the CM database
.NOTES
    Requires the ConfigMgrWebService from SCConfigMgr.com
#>
[CmdletBinding()]
param (
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $URI,
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $SecretKey,
    [parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Prefix,
    [parameter()][ValidateRange(3,15)][int] $NameLength = 4
)
$ErrorActionPreference = 'stop'
try {
    [string]$nextname = ""
    [int]$sfxlen = ($NameLength - $Prefix.Length)
    Write-Verbose "*** connecting to web service at $URI"
    $ws = New-WebServiceProxy -Uri $URI
    Write-Verbose "*** requesting next suffix for $Prefix (suffix = $sfxlen)"
    $found = ($ws.GetCMFirstAvailableNameSequence($SecretKey, $sfxlen, $Prefix))
    if (![string]::IsNullOrEmpty($found)) {
        Write-Verbose "*** next available suffix = $found"
        $nextname = "$Prefix$found"
    }
    else {
        Throw "*** no suffix returned for this prefix"
    }
    try {
        $tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
        $tsenv.Value("OSDComputerName") = $nextname
        Write-Verbose "*** assigned OSDComputerName = $nexname"
    }
    catch {
        Write-Verbose "*** not running in a task sequence"
        Write-Verbose "*** would have assigned OSDComputerName to $nextname"
    }
    Write-Output 0
}
catch {
    Write-Verbose $_.Exception.Message 
    Write-Output 1
}
