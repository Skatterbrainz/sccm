<#
.SYNOPSIS
  Install PowerShell Module from Local Folder
.DESCRIPTION
  This script is intended for installing an offline PowerShell module
  into the system modules folder (%programfiles%\WindowsPowerShell\Modules)
  within an MDT or ConfigMgr task sequence.
.EXAMPLE
  Install-PSModule.ps1 -Verbose
.NOTES
  Use ```Save-Module -Name <modulename> -Path <localpath>```
  to download the offline copy.  Then copy this script into
  the module folder.  Create a package in ConfigMgr with or without
  a program.  Then use Run PowerShell task to run it in a
  Task Sequence.
  2.0.0 - DS - Rewritten to lower the cholesteral level
#>
[CmdletBinding()]
param()
try {
    $ModuleName = Split-Path $PSScriptRoot -Leaf
    Write-Verbose "module: $ModuleName"
    $ModuleVersion = Get-ChildItem -Path $PSScriptRoot -Directory
    Write-Verbose "version: $ModuleVersion"
    $TargetPath = Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell\Modules\$ModuleName\$ModuleVersion"
    if (-not (Test-Path $TargetPath)) {
        $SourcePath = Join-Path -Path $PSScriptRoot -ChildPath $ModuleVersion
        Write-Verbose "installing module"
        mkdir $TargetPath -Force -ErrorAction Stop | Out-Null
        xcopy $SourcePath\*.* $TargetPath /s
        $result = 0
    }
    else {
        Write-Verbose "module already installed"
        $result = 1
    }
}
catch {
    if ($_.Exception.Message -match 'denied'){
        Write-Verbose "Access denied!"
        $result = -1
    }
    else {
        Write-Verbose $_.Exception.Message
        $result = -2
    }
}
finally {
    Write-Output $result
}
