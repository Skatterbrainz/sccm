#requires -module dbatools
<#
.SYNOPSIS
	Get SQL Express installations data from ConfigMgr inventory
.DESCRIPTION
	Same as Synopsis, only longer and more wordy stuff added with beer and french fries
.PARAMETER CsvFile
	Path to 'sqlserverversions.csv' data file
.PARAMETER SqlHost
	SQL Server instance name
.PARAMETER SiteCode
	Configuration Manager 3-character site code
.EXAMPLE
	Get-SqlExpressInstalls -SqlHost "cm01" -SiteCode "P01"
.NOTES
	B flat, C sharp, A minor 7
#>
function Get-SqlExpressInstalls {
    param (
      [parameter(Mandatory=$False)]
        [string] $CsvFile = 'https://raw.githubusercontent.com/Skatterbrainz/sccm/master/sqlserverversions.csv',
      [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $SqlHost,
      [parameter(Mandatory=$True)]
        [ValidateLength(3,3)]
        [string] $SiteCode
    )
    if ($CsvFile.StartsWith('http')) {
        $csvdata = Invoke-RestMethod -Method Get -Uri $CsvFile -UseBasicParsing | ConvertFrom-Csv
    }
    else {
        if (-not(Test-Path $CsvFile)) {
          Write-Warning "DOA: csv file not found $csvfile"
          break
        }
        $csvdata = Import-Csv -Path $CsvFile
    }
    # note: the Support column below could be moved to the CSV file, but I'm lazy and dumb

    $query = "SELECT DISTINCT
	    ProductName0 as ProductName, 
	    ProductVersion0 as Version, 
	    Publisher0 as Publisher, 
	    case
		    when (ProductVersion0 like '9.%') then 'UNSUPPORTED'
		    when (ProductVersion0 like '10.%') then 'EOL 2019/07/09'
		    else 'SUPPORTED' end as Support,
	    COUNT(*) AS Installs
    FROM 
	    v_GS_INSTALLED_SOFTWARE_CATEGORIZED
    WHERE 
	    ProductName0 LIKE 'Microsoft SQL Server % Express%'
    GROUP BY 
	    ProductName0, ProductVersion0, Publisher0 
    ORDER BY 
	    ProductName0"

    try {
        $rows = Invoke-DbaQuery -SqlInstance $SqlHost -Database "CM_$SiteCode" -Query $query -ErrorAction SilentlyContinue
        foreach ($row in $rows) {
            $v  = ($row.Version -split '\.')[0..3]
            if ($v[1] -in (0..5)) { 
                if ([int]$v[0] -lt 11) {
                    $v[1] = '00'
                }
                else {
                    $v[1] = '0'
                }
            }
            if ([int]$v[0] -lt 10) {
                $v = $v[0..2] -join '.'
            }
            else {
                $v = $v -join '.'
            }
            $vn = $($csvdata | ? {$_.Version -eq $v})
            $props = [ordered]@{
                ProductName = $row.ProductName
                Version     = $row.Version
                Version2    = $v
                BaseVersion = $vn.BASE
                ServicePack = $vn.SPK
                Update      = $vn.UPDATE
                Support     = $row.Support
                Installs    = $row.Installs
            }
            New-Object PSObject -Property $props
        }
    }
    catch {
      Write-Error $Error[0].Exception.Message
    }
}
