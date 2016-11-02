<#
.SYNOPSIS
   Returns full path and filename of SCCM PowerShell cmdlet module
.DESCRIPTION
   After loading, invoke Get-CmAdminConsolePath to return the full
   path and filename for ConfigurationManager.psd1
.EXAMPLE
   Import-Module $(Get-CmAdminConsolePath)
.NOTES
	Author: David Stein
	http://skatterbrainz.wordpress.com
#>

function Get-CmAdminConsolePath {
	$result = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Setup" | 
		Select-Object -ExpandProperty "UI Installation Directory"
	$cpath = "$result\bin\ConfigurationManager.psd1"
	if (Test-Path $cpath) { $cpath }
}