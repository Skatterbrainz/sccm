#requires -module dbatools
function Get-SqlExpressInstalls [
  param (
    [parameter(Mandatory=$False)]
      [string] $CsvFile = ".\sqlserverversions.csv",
    [parameter(Mandatory=$True)]
      [ValidateNotNullOrEmpty()]
      [string] $SqlHost,
    [parameter(Mandatory=$True)]
      [ValidateLength(3,3)]
      [string] $SiteCode
  )

  if (-not(Test-Path $CsvFile)) {
    Write-Warning "DOA: csv file not found $csvfile"
    break
  }

  $csvdata = Import-Csv -Path $CsvFile

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
          # shoehorn the weird version into less weird: 
          # 12.1.4100.1 --> 12.0.4100.1
          if ($v[1] -in (1..5)) { $v[1] = 0 }
          $v = $v -join '.'
          $vn = $($csvdata | ? {$_.Version -eq $v})
          $props = [ordered]@{
              ProductName = $row.ProductName
              Version     = $row.Version
              Version2    = $v
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
