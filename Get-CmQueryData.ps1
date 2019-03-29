#requires -module dbatools
<#
.SYNOPSIS
  Demonstrate dbatools with query files and ConfigMgr SQL data
.DESCRIPTION
  (same)
.PARAMETER SqlHost
  Name of ConfigMgr site database SQL Server host
.PARAMETER SiteCode
  ConfigMgr site code
.PARAMETER BaseUrl
  URL Path to folder with queries.txt and .sql query files
.EXAMPLE
  .\Get-CmQueryData.ps1 -SqlHost "cm01" -SiteCode "P01"
.NOTES
  1.0.0 - DS - 2019.03.28 - initial release
  *****************************************************************************
  ***               NO WARRANTY OR GUARANTEE OF ANY KIND!!                  ***
  ***    USE AT YOUR OWN RISK / DO NOT USE IN A PRODUCTION ENVIRONMENT      ***
  *** AUTHOR ASSUMES NO LIABILITY OR RESPONSIBLITY FOR ANY USE OF THIS CODE ***
  *****************************************************************************
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr database SQL Server hostname")]
        [ValidateNotNullOrEmpty()]
        [string] $SqlHost,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateLength(3,3)]
        [string] $SiteCode,
    [parameter(Mandatory=$False, HelpMessage="URL to common source files")]
        [ValidateLength(3,3)]
        [string] $BaseUrl = 'https://raw.githubusercontent.com/Skatterbrainz/sccm/master/queries'
)
try {
    Write-Verbose "requesting list of queries from $BaseUrl/queries.txt"
    $qlist = (Invoke-RestMethod -Method Get -UseBasicParsing -Uri "$BaseUrl/queries.txt" -ErrorAction SilentlyContinue)
    $qlist = $qlist -split [char]10
    Write-Verbose "sending list to gridview for user selection"
    $qname = $qlist | Out-GridView -Title "Select Query to run, or Cancel to quit" -OutputMode Single
    if ($qname) {
        Write-Verbose "selected: $qname ($BaseUrl/$qname`.sql)"
        $qtext = Invoke-RestMethod -Method Get -UseBasicParsing -Uri "$BaseUrl/$qname`.sql" -ErrorAction Stop
        Invoke-DbaQuery -SqlInstance $SqlHost -Database "CM_$SiteCode" -Query $qtext
    }
}
catch {
    Write-Warning $Error[0].Exception.Message 
}
