<# 
.SYNOPSIS
    Move AD computer account to specified OU
.DESCRIPTION
    Yeah, what he just said
.PARAMETER OU
    LDAP path to move account into
.PARAMETER TSVariable
    Name of custom TS variable to use in place of $OU
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
.EXAMPLE
    Move-ComputerOU.ps1 -TSVariable "MyOUPath"
    Move local computer account to OU specified by OSD task sequence variable "MyOUPath"
.NOTES
    Adapted from https://ccmexec.com/2018/03/move-the-computer-to-the-correct-ou-during-osd-ps-version/
    Updated 1911.21 to allow empty -OU and specify -TSVariable
#>
[CmdletBinding()]
param (
    [parameter(Position=1)][string] $OU = "",
    [parameter()][string] $TSVariable = "",
    [parameter()][string] $ComputerName = $($env:COMPUTERNAME)
)
try {
    Write-Verbose "*** searching for computer $ComputerName"
    $CompDN = ([ADSISEARCHER]"sAMAccountName=$ComputerName`$").FindOne().Path
    Write-Verbose "*** computer account found in directory: $ComputerName"
    $CompObj = [ADSI]"$CompDN"
    if (![string]::IsNullOrEmpty($TSVariable)) {
        Write-Verbose "*** reading ou path from variable $TSVariable"
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
        $OU = $($tsenv.Value("$TSVariable")).ToString().Trim()
    }
    Write-Verbose "*** path = $OU"
    if (![string]::IsNullOrEmpty($OU)) {
        $CompObj.psbase.MoveTo([ADSI]"LDAP://$($OU)")
        Write-Verbose "*** computer account has been moved"
        Write-Output 0    
    }
    else {
        throw "ou path was not specified or found"
    }
}
catch {
    $_.Exception.Message ; Exit 1
}