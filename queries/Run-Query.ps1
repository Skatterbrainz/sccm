[CmdletBinding()]
param (
  [parameter()][string]$Path = $PSScriptRoot
)
if (!(Get-Module dbatools -ListAvailable)) {
  Install-Module dbatools -Scope CurrentUser -Force
}
$queryFiles = Get-ChildItem -Path $Path -Filter "*.sql"
if ($queryFiles.Count -gt 0) {
  $queryFile = $queryFiles | Select-Object Name,FullName | Out-GridView -Title "Select Query to Run" -OutputMode Single
  if ($queryFile) {
    $query = Get-Content $queryFile.FullName
    Invoke-DbaQuery -SqlInstance $SqlInstance -Query $query
  }
}
