function Get-CmAdminConsolePath {
	$result = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Setup" | 
		Select-Object -ExpandProperty "UI Installation Directory"
	$cpath = "$result\bin\ConfigurationManager.psd1"
	if (Test-Path $cpath) { $cpath }
}

Function Copy-BootImageDrivers {
    PARAM (
        $from, $to
    )
 
    $boot = Get-CMBootImage -ID $to
 
    (Get-CMBootImage -Id $from).ReferencedDrivers | ForEach-Object {
        Write-Verbose "Copying $($_.Id) to $($to)"
        Set-CMDriver -Id $_.Id -AddBootImagePackage $boot -UpdateDistributionPointsforBootImagePackage $false
    }
 
}

Import-Module $(Get-CmAdminConsolePath)
CD PS1: 
#Example use
Copy-BootImageDrivers -from "ABC00123" -to "ABC00456"