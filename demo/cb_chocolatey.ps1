# sccm configuration baseline script to enforce chocolatey installation
# when ci_chocolatey.ps1 returns $False

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
