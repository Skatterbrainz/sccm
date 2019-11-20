<#
.SYNOPSIS
    Query AD for next available sequential device name
.DESCRIPTION
    Query AD for next available sequential device name
.PARAMETER URI
    URI to web service. This is typically the "http://<SMSProvider>/ConfigMgrWebService/ConfigMgr.asmx"
.PARAMETER SecretKey
    The secret key string set during ConfigMgrWebService installation
.PARAMETER Prefix
    Prefix portion of the device name. If desired format is "WS001" then prefix would be "WS"
.PARAMETER NameLength
    Total length of desired device name. For "WS001" the value would be 5
.EXAMPLE
    Get-NextADDeviceName.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -Prefix "WS" -NameLength 5
    Would return "WSxxx" where "xxx" is the next numeric suffix not found in the current AD domain
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
	Write-Verbose "connecting to web service at $URI"
    $ws = New-WebServiceProxy -Uri $URI -ErrorAction 'stop'
    for ($index = 1; $index -lt 100; $index++) {
        $nextname = $Prefix + $([string]$index).PadLeft($NameLength - $($Prefix.Length), "0")
		Write-Verbose "checking name: $nextname"
		$found = ($ws.GetADComputer($SecretKey, $nextname)).SamAccountName
        if (![string]::IsNullOrEmpty($found)) {
			Write-Verbose "name exists: $nextname"
		}
		else {
            return $nextname
        }
    }
    Write-Output "no names for this prefix available from 1 to 100"
}
catch {
    Write-Error $_.Exception.Message 
}