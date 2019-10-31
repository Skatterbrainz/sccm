<#
.DESCRIPTION
  Configure IIS app pool settings for WSUS
.PARAMETER QueueLength
.PARAMETER PrivateMemoryLimit
.NOTES
  Set-CmLab-WsusPoolOptions.ps1
  Author: David Stein
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Queue Length value")]
    [int32] $QueueLength = 2000,
    [parameter(Mandatory=$False, HelpMessage="Private Memory Limit value")]
    [int32] $PrivateMemoryLimit = 7372800
)
Import-Module WebAdministration
try {
  Set-ItemProperty IIS:\AppPools\WsusPool -Name queueLength -Value $QueueLength
  Set-ItemProperty IIS:\AppPools\WsusPool -Name recycling.periodicRestart.privateMemory -Value $PrivateMemoryLimit
}
catch {
  Write-Error $_.Exception.Message
}
