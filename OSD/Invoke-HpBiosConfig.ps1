<#
.SYNOPSIS
    Run HP BIOS config utility
.DESCRIPTION
    Run HP BIOS config utility with fries and a coke
.PARAMETER TemplatesPath
    Folder path where template files are stored
.PARAMETER ConfigFile
    Name of configuration file (.txt extension)
.PARAMETER Models
    Name of one or more models
#>
param (
    [string] $TemplatesPath = "",
    [string] $ConfigFile = "COMPUTERNAME_BiosConfig.txt",
    [string[]] $Models = "2540","2550","2560","8530","8540","8510","7600","7700","7800","7900","8000","8100","8200","8300","Z220","Z230","Z240","HP"
)
try {
    if (-not (Test-Path ".\BiosConfigUtility.exe")) {
        throw "BiosConfigUtility.exe was not found in current path"
    }
    $modelName = Get-WmiObject -Class "Win32_Computersystem" -Namespace "root\cimv2" | Select -ExpandProperty "Model"
    $ComputerName = Get-WmiObject -Class "Win32_Computersystem" -Namespace "root\cimv2" | Select -ExpandProperty "Name"

    $templateFile = ""
    foreach ($mx in $Models) {
        if ($modelName.contains($mx)) {
            $templateFile = Join-Path -Path $TemplatesPath -ChildPath "GetComputerName`-$mx.txt"
        }
    } 
    if ($templateFile -eq "") {
        $templateFile = Join-Path -Path $TemplatesPath -ChildPath "GetComputerName.txt"
        $HpDetected = $False
    }
    else {
        $HpDetected = $True
    }

    if ($HpDetected -eq $True) {
        if (Test-Path $templateFile) {
            $templateData = Get-Content -Path $templateFile
            $newData = $templateData.Replace("[COMPUTERNAME]", $ComputerName)
            Set-Content -Path $ConfigFile -Value $newData
            if (Test-Path $ConfigFile) {
                Start-Process ".\BiosConfigUtility.exe" -ArgumentList "/setconfig:$ConfigFile" -Wait
            }
        }
    }
}
catch {
    Write-Error $Error[0].Exception.Message
}
