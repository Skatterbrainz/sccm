[CmdletBinding()]
param (
	[parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string] $SiteCode
)

function Get-CmPsModulePath {
	param()
	$result = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Setup" | Select-Object -ExpandProperty "UI Installation Directory"
	$cpath = "$result\bin\ConfigurationManager.psd1"
	if (Test-Path $cpath) { $cpath }
}

function Copy-BootImageDrivers {
    param (
        [parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string] $SourcePath, 
		[parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string] $TargetPath
    )
    $boot = Get-CMBootImage -Id $TargetPath
    (Get-CMBootImage -Id $SourcePath).ReferencedDrivers | ForEach-Object {
        Write-Verbose "Copying $($_.Id) to $($TargetPath)"
        Set-CMDriver -Id $_.Id -AddBootImagePackage $boot -UpdateDistributionPointsforBootImagePackage $false
    }
}

try {
	Import-Module $(Get-CmPsModulePath)
	$oldloc = Get-Location
	Set-Location "$SiteCode`:"
	#Example use
	Copy-BootImageDrivers -from "ABC00123" -to "ABC00456"
}
catch {
	Write-Error $Error[0].Exception.Message
}
finally {
	Set-Location $oldloc
}
