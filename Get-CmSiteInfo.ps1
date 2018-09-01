#requires -RunAsAdministrator
#requires -Version 5
<#
.SYNOPSIS
Query Configuration Manager Database information

.DESCRIPTION
Just what the Synopsis guy just said

.PARAMETER SiteServer
[string] FQDN for ConfigMgr SQL Database server (optional)

.PARAMETER SiteCode
[string] Site Code (optional)

.PARAMETER ConfigFile
[string] Path to XML configuration file. Default is cm-site-status.xml in same folder (optional)

.PARAMETER QueryName
[string] Specific query to run (only one at a time) (optional)

.PARAMETER Interactive
[switch] Display queries from config file in grid view for user selection

.PARAMETER About
[switch] Display version and basic information only

.EXAMPLE 
.\Get-CmSiteInfo.ps1 | Out-File "cm01.contoso.local.txt"

.EXAMPLE
.\Get-CmSiteInfo.ps1 -About

.EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -Interactive

.EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -QueryName "DB Index Fragmentation Details" -OutputLayout RAW | Set-Variable -Name frag
$frag | Where-Object {$_.FragPct -gt 50}

.NOTES
1808.30.01 - DS - First time getting drunk and passed out
1808.31.01 - DS - Oh no. Not again?!

#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Site SQL Server FQDN")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteServer="$($env:COMPUTERNAME+'.'+$env:USERDNSDOMAIN)",
    [parameter(Mandatory=$False, HelpMessage="Site Code")]
        [string] $SiteCode="",
    [parameter(Mandatory=$False, HelpMessage="Configuration XML file")]
        [string] $ConfigFile = ".\cm-site-status.xml",
    [parameter(Mandatory=$False, HelpMessage="Query Name")]
        [string] $QueryName = "",
    [parameter(Mandatory=$False, HelpMessage="Prompt for Selected Queries")]
        [switch] $Interactive,
    [parameter(Mandatory=$False)]
        [switch] $About
)

$ScriptVersion = "1808.31.1"
if ([string]::IsNullOrEmpty($SiteCode)) {
    try {
        $key = Get-Item -Path "HKLM:SOFTWARE\Microsoft\CCM\CcmEval" -ErrorAction SilentlyContinue
        $SiteCode = $key.GetValue("LastSiteCode")
    }
    catch {
        try {
            $key = Get-Item -Path "HKLM:SOFTWARE\Microsoft\SMS\Identification" -ErrorAction SilentlyContinue
            $SiteCode = $key.GetValue("Site Code")
        }
        catch {
            Write-Warning "ABORT: Unable to determine site code from local machine"
            break
        }
    }
}
if ($About) {
    Write-Host "Get-CmSiteInfo.ps1 - version: $ScriptVersion" -ForegroundColor Cyan
    Write-Host "Site Server : $SiteServer" -ForegroundColor Cyan
    Write-Host "Site Code   : $SiteCode" -ForegroundColor Cyan
    Write-Host "Config File : $ConfigFile" -ForegroundColor Cyan
    break
}
Write-Verbose "script version.. $ScriptVersion"
Write-Verbose "site server..... $SiteServer"
Write-Verbose "site code....... $SiteCode"
Write-Verbose "configfile...... $ConfigFile"
Write-Verbose "queryname....... $QueryName"

if (!(Test-Path $ConfigFile)) {
    Write-Warning "ABORT: configuration file not found: $ConfigFile"
    break
}
Write-Verbose "loading queries from: $ConfigFile"
[xml]$queryset = Get-Content $ConfigFile
if (!([string]::IsNullOrEmpty($QueryName))) {
    $qset = $queryset.queries.query | Where {$_.name -eq $QueryName}
    if (!$qset) {
        Write-Error "no matching query found"
        break
    }
    $time1 = Get-Date
    Write-Verbose "query was found in configuration file"
}
elseif ($Interactive) {
    Write-Verbose "interactive: displaying grid for user selection"
    $qset = $queryset.queries.query | Sort-Object name | Out-GridView -Title "Select Items to Run (CTRL or SHIFT select)" -OutputMode Multiple
    Write-Verbose "selected queries: $($qset.Count)"
    $time1 = Get-Date 
}
else {
    $time1 = Get-Date 
    Write-Verbose "all queries selected (default)"
    $qset = $queryset.queries.query
}
Write-Verbose "user context: $($env:USERNAME+'.'+$env:USERDNSDOMAIN)"
$cs = "Server=$SiteServer;Database=CM_$SiteCode;Integrated Security=True;"
Write-Verbose "connection string: $cs"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $cs
Write-Verbose "opening sql server connection"
try {
    $connection.Open()
    Write-Verbose "connection opened successfully"
}
catch {
    Write-Error $_.Exception.Message
    break
}
$command = $connection.CreateCommand()
Write-Verbose "processing queries"
foreach ($query in $qset) {
    $table = $null
    $queryName = $query.name
    Write-Verbose "query: $queryName"
    Write-Verbose "expression: $($query.exp)"
    $command.CommandText = $query.exp
    try {
        $result = $command.ExecuteReader()
        $table = New-Object System.Data.DataTable
        $table.Load($result)
        Write-Output $table
    }
    catch {
        Write-Verbose "null recordset ***"
    }
} # foreach
$connection.Close()
Write-Verbose "connection closed"
$time2 = Get-Date
$timex = New-TimeSpan -Start $time1 -End $time2
Write-Verbose "runtime: $($timex.TotalSeconds) seconds"
