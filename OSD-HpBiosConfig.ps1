<#
'****************************************************************
' Filename..: OSD-HpBiosConfig.ps1
' Author....: David M. Stein
' Date......: 06/14/2016
' Purpose...: load HP bios configuration utility with custom template
'****************************************************************
#>

$templatesFolder = ""
$NewConfigFile = "COMPUTERNAME_BiosConfig.txt"

$modelName = Get-WmiObject -Class "Win32_Computersystem" -Namespace "root\cimv2" | Select -ExpandProperty "Model"
$ComputerName = Get-WmiObject -Class "Win32_Computersystem" -Namespace "root\cimv2" | Select -ExpandProperty "Name"

$mlist = ("2540","2550","2560","8530","8540","8510","7600","7700","7800","7900","8000","8100","8200","8300","Z220","Z230","Z240","HP")

$templateFile = ""
foreach ($mx in $mlist) {
    if ($modelName.contains($mx)) {
        $templateFile = "$templatesFolder\GetCOmputerName`-$mx.txt"
    }
} 
if ($templateFile -eq "") {
    $templateFile = "$templatesFolder\GetCOmputerName.txt"
    $HpDetected = $False
}
else {
    $HpDetected = $True
}

if ($HpDetected -eq $True) {
    if (Test-Path $templateFile) {
        $templateData = Get-Content -Path $templateFile
        $newData = $templateData.Replace("[COMPUTERNAME]", $ComputerName)
        Set-Content -Path $NewConfigFile -Value $newData
        if (Test-Path $NewConfigFile) {
            Start-Process "BiosConfigUtility.exe" -ArgumentList "/setconfig:$NewConfigFile" -Wait
            ## iReturn=objShell.Run(StartupPath & "BiosConfigUtility.EXE /setconfig:" & TargetTemplateFile,0,True) ' RUN BIOSCONFIGUTILITY USING CUSTOM TEMPLATE TEXT FILE 
        }
    }
}
