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
    [parameter(Mandatory,Position=1)][ValidateNotNullOrEmpty()][string] $OU,
    [parameter()][string] $ComputerName = $($env:COMPUTERNAME)
)
try {
    $CompDN = ([ADSISEARCHER]"sAMAccountName=$ComputerName`$").FindOne().Path
    Write-Verbose "*** computer account found in directory: $ComputerName"
    $CompObj = [ADSI]"$CompDN"
    $CompObj.psbase.MoveTo([ADSI]"LDAP://$($OU)")
    Write-Verbose "*** computer account has been moved"
    Write-Output 0
}
catch {
    $_.Exception.Message ; Exit 1
}