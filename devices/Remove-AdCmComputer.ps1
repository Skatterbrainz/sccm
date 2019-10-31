<#
.SYNOPSIS
    Deletes computers from AD and ConfigMgr

.DESCRIPTION
    Deletes computers from AD domain and ConfigMgr site using explicit input or file input

.PARAMETER InputFile
    Name of TXT file with computer names to process. Overrides -ComputerName

.PARAMETER ComputerName
    Explicit computer names to process

.NOTES
    2018-05-05 - DS - first time getting drunk
    2018-07-05 - DS - added DeleteFrom parameter, no drinking this time
    2018-08-31 - DS - added whatif support, still sober

.EXAMPLE
    .\Remove-AdCmComputer.ps1 -ComputerName DT001 -SiteServer cm01.contoso.local -SiteCode P01 -DeleteFrom 'CM'

.EXAMPLE
	.\Remove-AdCmComputer.ps1 -InputFile .\computers.txt -SiteServer cm01.contoso.local -SiteCode P01

#> 
[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Server FQDN")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteServer,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateLength(3,3)]
        [string] $SiteCode,
    [parameter(Mandatory=$False, HelpMessage="Input TXT File")]
        [string] $InputFile = "",
    [parameter(Mandatory=$False, HelpMessage="Computer Names")]
        [string[]] $ComputerName = "",
    [parameter(Mandatory=$False, HelpMessage="Delete from AD or ConfigMgr or Both")]
        [ValidateSet('BOTH','AD','CM')]
        [string] $DeleteFrom = 'BOTH'
)

$time1 = Get-Date
# find and delete the computer from AD
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root   = $domain.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root
$forest = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Forest.Name

if (![string]::IsNullOrEmpty($InputFile)) {
    if (Test-Path $InputFile) {
        $ComputerName = Get-Content $InputFile
    }
    else {
        Write-Warning "ABORT: Input file not found: $InputFile"
        break
    }
}
foreach ($Computer in $ComputerName) {
    if ($DeleteFrom -eq 'AD' -or $DeleteFrom -eq 'BOTH') {
        Write-Verbose "searching domain for: $Computer"
        $search.Filter = "(&(objectClass=computer)(name=$Computer))"
        try {
            $result = $search.FindAll() | Foreach-Object {$_.GetDirectoryEntry() }
            if ($result) {
                if ($WhatIfPreference) {
                    Write-Host "WHATIF: delete $Computer from $forest" -ForegroundColor Yellow
                }
                else {
                    $result | Foreach-Object {$_.DeleteObject(0)}
                    Write-Host "deleted from domain: $Computer" -ForegroundColor Cyan
                }
            }
            else {
                Write-Warning "$Computer not found in domain"
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    if ($DeleteFrom -eq 'CM' -or $DeleteFrom -eq 'BOTH') {
        try {
            $res = Get-WmiObject -Query "select * from SMS_R_SYSTEM WHERE Name='$Computer'" -ComputerName $SiteServer -Namespace "ROOT\SMS\site_$SiteCode"
            if ($res) {
                if ($WhatIfPreference) {
                    Write-Host "WHATIF: delete $Computer from $SiteServer / $SiteCode" -ForegroundColor Yellow
                }
                else {
                    $res.psbase.Delete()
                    Write-Host "deleted from sccm: $Computer" -ForegroundColor Green
                }
            }
            else {
                Write-Warning "$Computer not found in Configuration Manager site database"
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}
$time2 = Get-Date
$tdiff = New-TimeSpan -Start $time1 -End $time2
Write-Host "completed. runtime: $($tdiff.TotalSeconds) seconds" -ForegroundColor Cyan
