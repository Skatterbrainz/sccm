# configuration item for SCCM baseline detection rule
# used with cb_chocolatey.ps1
if (Test-Path "$($env:PROGRAMDATA)\chocolatey\choco.exe") {
  Write-Output $True
}
else {
  Write-Output $False
}
