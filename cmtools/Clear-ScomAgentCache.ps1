<#
.SYNOPSIS
    Clear SCOM agent cache on remote computers
.DESCRIPTION
    Clear SCOM agent cache on remote computers
.PARAMETER InputFile
    Text file containing names of remote computers to process
    One computer name on each line, avoid empty lines
.EXAMPLE
    .\Clear-ScomAgentCache.ps1 -InputFile ".\computernames.txt"
.NOTES
    Adapted from http://www.ms-opsmgr.eu/?tag=maintenancemode-scom-scom2012-powershell
    by David Stein / 1910.25
#>
[CmdletBinding()]
param(
    [parameter(Mandatory,Position=0)][string]$InputFile
)
$ErrorActionPreference = 'SilentlyContinue'

if (!(Get-Module OperationsManager -ListAvailable)) {
    Write-Warning "OperationsManager module is not installed. Aborting."
    exit
}
try {
    $computers = Get-Content $InputFile
    if ($null -eq $computers) {
        Write-Warning "no computer names were imported"
        break
    }
    foreach ($computer in $computers) {
        $RemoteComputer = Get-SCOMClassInstance -Name $computer
        if ($null -ne $RemoteComputer) {
            $CurrentimePlus10Minutes = ((Get-Date).AddMinutes(10)) 
            Write-Verbose "$computer : Setting Maintenance mode for remote Computer"
            Start-SCOMMaintenanceMode -Instance $RemoteComputer -EndTime $CurrentimePlus10Minutes -Comment "Flushing System Center Operations Manager Agent Cache"
            Write-Verbose "$computer : is in Maintenance mode for 10 Minutes"

            Write-Verbose "$computer : Stopping service: HealthService"
            Invoke-Command -ComputerName $RemoteComputer {Net Stop "HealthService"}

            Write-Verbose "$computer : clearing agent cache"
            Invoke-Command -ComputerName $RemoteComputer {Get-ChildItem -Recurse -Path "C:\Program Files\System Center Operations Manager\Agent\Health Service State" | Remove-Item -Force -Recurse}
            Write-Verbose "$computer : The System Center Agent Cache is cleared."

            Write-Verbose "$computer : Restarting service: HealthService"
            Invoke-Command -ComputerName $RemoteComputer {Net Start "HealthService"}
            Write-Host "$computer : Cache has been cleared"
        }
        else {
            Write-Host "$computer : Computer is offline or inaccessible"
        }
    }
}
catch {
    Write-Error $_.Exception.Message 
}
