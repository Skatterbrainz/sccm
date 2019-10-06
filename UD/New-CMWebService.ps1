# Example --> Invoke-RestMethod http://localhost:10001/api/cmdevices

[CmdletBinding()]
param (
    [parameter()][string] $SiteCode = "P01",
    [parameter()][int] $Port = 10001
)
try {
    if (!(Get-Module UniversalDashboard.Community)) {
        Install-Module UniversalDashboard.Community
    }
    Import-Module UniversalDashboard.Community
}
catch {
    Write-Error $_.Exception.Message
    Exit
}

try {
    $devices = Get-WmiObject -Class "SMS_R_System" -Namespace "root\SMS\Site_$SiteCode" |
        Select ResourceID,Name,Client,ClientVersion,ADSiteName,DistinguishedName,MACAddresses,IPAddresses,LastLogonTimestamp,OperatingSystemNameandVersion,Build
    $Cache:CMDevices = @( $devices )
    $Endpoints = @()

    $Endpoints += New-UDEndpoint -Url 'cmdevices' -Endpoint {
    	$Cache:CMDevices | ConvertTo-Json
    }
    Start-UDRestApi -Endpoint $Endpoints -Port $Port -AutoReload -Name "cmdevices"
}
catch {
    Write-Error $_.Exception.Message
}
