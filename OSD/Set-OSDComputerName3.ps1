<#
.SYNOPSIS
  .\OSDComputerName3.ps1
.NOTES
  written by me. :D
#>

$chType    = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
$serialNum = Get-WmiObject -Class Win32_SystemEnclosure | Select-Object -ExpandProperty SerialNumber

Write-Output "INFO: wmi chassistypes = $chType"
Write-Output "INFO: wmi serialnumber = $serialNum"

switch ($chType) {
    3  { $prefix = "D" }
    4  { $prefix = "D" }
    5  { $prefix = "D" }
    6  { $prefix = "D" }
    7  { $prefix = "D" }
    8  { $prefix = "L" }
    9  { $prefix = "L" }
    10 { $prefix = "L" }
    11 { $prefix = "M" }
    13 { $prefix = "D" }
    14 { $prefix = "L" }
    15 { $prefix = "D" }
    16 { $prefix = "D" }
    17 { $prefix = "S" }
    18 { $prefix = "X" }
    19 { $prefix = "S" }
    20 { $prefix = "S" }
    21 { $prefix = "S" }
    22 { $prefix = "S" }
    23 { $prefix = "S" }
    24 { $prefix = "S" }
    default { $prefix = "U" }
}
try {
	if ($serialNum.Length -gt 8) {
		$sn = $serialNum.Substring($serialNum.length -8, 8)
	}
	else {
		$sn = $serialNum
	}
	$newName = $prefix +"-$sn"
	Write-Output "INFO: New Name = $newName"

	$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
	$tsenv.Value("OSDComputerName") = $newName
}
catch {
	Write-Output $Error[0].Exception.Message
}
