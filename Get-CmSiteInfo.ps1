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
1809.01 - DS - OutputFile and progress bar stuff added

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
    [parameter(Mandatory=$False, HelpMessage="Output file path")]
        [string] $OutputFile = "$SiteServer`_$SiteCode.txt",
    [parameter(Mandatory=$False)]
        [switch] $About
)

$ScriptVersion = "1809.01"
$PbCaption = "ConfigMgr Site Assessment"

function Write-Custom {
    param (
        [parameter(Mandatory=$True, HelpMessage="Caption for progress bar")]
            [ValidateNotNullOrEmpty()]
            [string] $Caption,
        [parameter(Mandatory=$True, HelpMessage="Task for progress bar and output file")]
            [ValidateNotNullOrEmpty()]
            [string] $TaskName,
        [parameter(Mandatory=$True, HelpMessage="Percent complete (0 to 100)")]
            [ValidateRange(0,100)]
            [int] $Percent,
        [parameter(Mandatory=$False, HelpMessage="Output file path")]
            [string] $LogFile = ""
    )
    Write-Progress -Activity $Caption -Status $TaskName -PercentComplete $Percent
    if ($LogFile -ne "") {
        "*** $($TaskName.ToUpper()) ***" | Out-File $LogFile -Append
    }
}

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

Write-Output "context: $($env:USERNAME).$($env:USERDNSDOMAIN)" | Out-File $OutputFile
Write-Output "hostname: $($env:COMPUTERNAME)" | Out-File $OutputFile -Append
Write-Output "version: $ScriptVersion" | Out-File $OutputFile -Append

if (!(Test-Path $ConfigFile)) {
    Write-Warning "ABORT: configuration file not found: $ConfigFile"
    break
}
Write-Custom -Caption $PbCaption -TaskName "Loading queries" -Percent 1
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

Write-Custom -Caption $PbCaption -TaskName "Preparing" -Percent 10
Write-Output "user context: $($env:USERNAME+'.'+$env:USERDNSDOMAIN)" | Out-File $OutputFile -Append

$cs = "Server=$SiteServer;Database=CM_$SiteCode;Integrated Security=True;"
Write-Verbose "connection string: $cs"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $cs

Write-Custom -Caption $PbCaption -TaskName "Connecting to SQL Server" -Percent 20
#Write-Verbose "opening sql server connection"
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

$qty = $qset.Count
$idx = 1
foreach ($query in $qset) {
    $table = $null
    $queryName = $query.name
    Write-Verbose "query: $queryName"
    Write-Verbose "expression: $($query.exp)"
    Write-Verbose "index number: $idx of $pct"
    $pct = ([math]::Round($idx/$qty,2)*100)
    Write-Custom -Caption $PbCaption -TaskName "[$idx of $qty] $queryName" -Percent $pct -LogFile $OutputFile
    $command.CommandText = $query.exp
    try {
        $result = $command.ExecuteReader()
        $table = New-Object System.Data.DataTable
        $table.Load($result)
        Write-Output $table | Out-File $OutputFile -Append
    }
    catch {
        Write-Output "null recordset" | Out-File $OutputFile -Append
        #Write-Verbose "null recordset ***"
    }
    $idx++
} # foreach
$connection.Close()
Write-Custom -Caption $PbCaption -TaskName "Closing Connection" -Percent 95
Write-Verbose "connection closed"
$time2 = Get-Date
$timex = New-TimeSpan -Start $time1 -End $time2
Write-Custom -Caption $PbCaption -TaskName "Completed" -Percent 100
Write-Verbose "runtime: $($timex.TotalSeconds) seconds"
