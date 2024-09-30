[CmdletBinding()]
param (
  [parameter()][string]$Path = $PSScriptRoot
)
if (!(Get-Module dbatools -ListAvailable)) {
  Install-Module dbatools -Scope CurrentUser -Force
}
$queryFiles = Get-ChildItem -Path $Path -Filter "*.sql"
if ($queryFiles.Count -gt 0) {
  $queryFile = $queryFiles | Out-GridView -Title "Select Query to Run" -OutputMode Single
  if ($queryFile) {
    $query = Invoke-DbaQuery -SqlInstance $SqlInstance -Query $query
  }
}
