<# 
.SYNOPSIS
    Move AD computer account to specified OU
.DESCRIPTION
    Yeah, what he just said
.PARAMETER OU
    LDAP path to move account into
.PARAMETER ComputerName
    Name of computer account. Default is $env:COMPUTERNAME
.EXAMPLE
    Move-ComputerOU.ps1 -OU "OU=Workstations,OU=Chicago,OU=CORP,DC=contoso,DC=local"
    Move local computer account into OU path
.EXAMPLE
    Move-ComputerOU.ps1 -OU "OU=Workstations,OU=Chicago,OU=CORP,DC=contoso,DC=local" -ComputerName "WS001"
    Move computer WS001 to OU path
.EXAMPLE
    Move-ComputerOU.ps1 -OU %MachinObjectOU%
    Move local computer account to OU specified by OSD task sequence variable
.NOTES
    Adapted from https://ccmexec.com/2018/03/move-the-computer-to-the-correct-ou-during-osd-ps-version/
#>
[CmdletBinding()]
param (
    [parameter()][string] $OU = "",
    [parameter()][string] $ComputerName = $($env:COMPUTERNAME),
    [parameter()][string] $DefaultOU = 'OU=DisabledComputers,OU=CORP,DC=contoso,DC=local'
)
$ErrorActionPreference = 'stop'
if ([string]::IsNullOrEmpty($OU)) {
    Write-Verbose "*** path not specified / using default path"
    $OU = $DefaultOU
}
try {
    $CompDN = ([ADSISEARCHER]"sAMAccountName=$ComputerName`$").FindOne().Path
    Write-Verbose "*** computer account found in directory: $env:COMPUTERNAME"
    $CompObj = [ADSI]"$CompDN"
    $CompObj.psbase.MoveTo([ADSI]"LDAP://$($OU)")
    Write-Verbose "*** computer account has been moved"
    Write-Output 0
}
catch {
    $_.Exception.Message ; Exit 1
}