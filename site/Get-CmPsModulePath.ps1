<#
.SYNOPSIS
	Returns path to the ConfigurationManager.psd1 library file
.DESCRIPTION
	Yes, what he said
.EXAMPLE
	Import-Module $(Get-CmPsModulePath)
#>

function Get-CmPsModulePath {
	param()
	$result = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Setup" | Select-Object -ExpandProperty "UI Installation Directory"
	$cpath = "$result\bin\ConfigurationManager.psd1"
	if (Test-Path $cpath) { $cpath }
}
