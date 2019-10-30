#requires -modules dbatools,importexcel

<#
.SYNOPSIS
    Dump inventory data from ConfigMgr site database
.DESCRIPTION
    Dump inventory summary data from ConfigMgr SQL database into Excel spreadsheet
.PARAMETER SiteCode
    Configuration Manager site code
.PARAMETER DbHost
    SQL Server instance hostname (default is "localhost")
.PARAMETER DbName
    SQL Server Database name (default is "CM_$SiteCode")
.PARAMETER ReportPath
    Path to output report files
.PARAMETER ConfigFile
    Path to SQL query configurations JSON file (default is .\config.json)
.PARAMETER Excel
    Export to Excel XLSX file, otherwise output to CSV files (one for each query)
.EXAMPLE
    .\Export-CmInventory.ps1 -SiteCode "P01"
    Export from P01 site database on localhost to Excel xlsx file
.EXAMPLE
    .\Export-CmInventory.ps1 -SiteCode "P01" -DbHost "server2" -DbName "SCCM_P01"
    Export from P01 site database "SCCM_PO1" hosted on server2 to Excel xlsx file
.NOTES
    1.0.0 - 1910.30 - David Stein - First release
    Requires config.json from this same repo location
#>
[CmdletBinding()]
param(
    [parameter(Mandatory)][ValidateLength(3,3)][string] $SiteCode,
    [parameter()][ValidateNotNullOrEmpty()][string] $DbHost = "localhost",
    [parameter()][ValidateNotNullOrEmpty()][string] $DbName = "CM_$SiteCode",
    [parameter()][ValidateNotNullOrEmpty()][string] $ReportPath = "$env:USERPROFILE\documents",
    [parameter()][ValidateNotNullOrEmpty()][string] $ConfigFile = ".\config.json",
    [parameter()][bool] $Excel = $True
)
$ErrorActionPreference = 'stop'
$XlFile = $(Join-Path $ReportPath "$SiteCode`_Inventory.xlsx")

if (Test-Path $XlFile) { Remove-Item -Path $XlFile -Force }

function Invoke-DataExport {
    [CmdletBinding()]
    param (
        [parameter(Position=0)][ValidateNotNullOrEmpty()][string] $Query,
        [parameter(Position=1)][ValidateNotNullOrEmpty()][string] $ReportName,
        [parameter()][string[]] $Properties
    )
    try {
        Write-Host "exporting: $ReportName" -ForegroundColor Cyan
        if ($Excel -eq $True) {
            Invoke-DbaQuery -SqlInstance $DbHost -Database $DbName -Query $Query | 
                Select-Object $Properties |
                    Export-Excel -Path $XlFile -WorksheetName $ReportName
        }
        else {
            Invoke-DbaQuery -SqlInstance $DbHost -Database $DbName -Query $Query | 
                Select-Object $Properties |
                    Export-Csv -Path $(Join-Path $ReportPath "$SiteCode`_$ReportName.csv") -NoTypeInformation -Force
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

if (-not(Test-Path $ConfigFile)) {
    Write-Warning "configuration file not found: $ConfigFile"
    break
}

try {
    $cfg = Get-Content $ConfigFile | ConvertFrom-Json
    $keys = ($cfg.psobject.Properties).Name

    foreach ($key in $keys) {
        $qset  = $cfg."$key"
        $qtext = $qset.query
        $props = $qset.properties -split ','
        Invoke-DataExport -Query $qtext -ReportName $key -Properties $props
    }
    Write-Host "processing complete" -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message 
}