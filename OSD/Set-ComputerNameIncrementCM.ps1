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
    Set-ComputerNameIncrementCM.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -Prefix "WS" -NameLength 5
    If WS001 and WS002 exist in the CM database, but not WS003, then this would return WS003
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

function Get-NextCMDeviceName {
    param()
    function Get-NextADDeviceName {
        param()
        try {
            Write-Verbose "connecting to web service at $URI"
            $ws = New-WebServiceProxy -Uri $URI -ErrorAction 'stop'
            [int]$sfxlen = ($NameLength - $Prefix.Length)
            Write-Verbose "*** requesting next suffix for $Prefix (suffix = $sfxlen)"
            $found = ($ws.GetCMFirstAvailableNameSequence($SecretKey, $sfxlen, $Prefix))
            if (![string]::IsNullOrEmpty($found)) {
                $nextname = "$Prefix$found"
                Write-Verbose "*** next available name = $nextname"
                return $nextname
            }
            else {
                Throw "*** no suffix returned for this prefix"
            }
            Write-Output "no names for this prefix available from 1 to 100"
        }
        catch {
            Write-Error $_.Exception.Message 
        }
    }
}

$cn = Get-NextCMDeviceName

try {
    $tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
    $tsenv.Value("OSDComputerName") = $cn
    Write-Verbose "*** assigned OSDComputerName = $cn"
}
catch {
    Write-Verbose "*** not running in a task sequence"
    Write-Verbose "*** would have assigned OSDComputerName to $cn"
}
