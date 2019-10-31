<#
.SYNOPSIS
	Export all Task Sequences for a given SCCM site
.PARAMETER TargetPath
	[string] path location for exporting the task sequence .ZIP files
	(default = user profile "Documents" folder)
.PARAMETER Dependencies
	[switch] Indicates to export dependencies as well (not required)
.PARAMETER Content
	[switch] Indicates to export content as well (not required)
.EXAMPLE
	Export-CmTaskSequences.ps1 -TargetPath "C:\CMTaskSequences"
.NOTES
	Author..... skatterbrainz.wordpress.com / GitHub / Twitter
	Created.... 10/26/2016
	Modified... TBD
#>


param (
	[parameter(Mandatory=$False)] [string] $TargetPath = "$($env:USERPROFILE)\Documents",
	[parameter(Mandatory=$False)] [switch] $Dependencies, 
	[parameter(Mandatory=$False)] [switch] $Content,
	[parameter(Mandatory=$False)] [switch] $ListOnly
)

if (!($Dependencies)) { $Deps = $False } else { $Deps = $True }
if (!($Content)) { $Cont = $False } else { $Cont = $True }
$old = $pwd

<#
.SYNOPSIS
	Get-CmSiteCode was created to persevere to endeavor
	on the path of journey to finding that elusive beast:
	the site code, for this mysterious thing called a SCCM site
.EXAMPLE
	$sitecode = Get-CmSiteCode
#>

function Get-CmSiteCode {
	$x = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS"
	$smsp = $x.ServerAccountProvider
	$smsp.Substring($smsp.Length-3,3)
}

<#
.SYNOPSIS
	Get-CmCmdletModule returns the [string] path location
	to the .PSD1 powershell module installed with SCCM
.EXAMPLE
	$mpath = Get-CmCmdletModule
#>

function Get-CmCmdletModule {
	$result = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Setup" | 
	Select-Object -ExpandProperty "UI Installation Directory"
	$cpath = "$result\bin\ConfigurationManager.psd1"
	if (Test-Path $cpath) { $cpath }
}

$cmsc = Get-CmSiteCode

if (!(Get-Module "ConfigurationManager")) {
	$cmm = Get-CmCmdletModule
	if ($cmm -ne $null) {
		Import-Module $cmm
		Set-Location "$cmsc`:"
	}
	else {
		Write-Host "uh oh! Yo shit imploded, G." -ForegroundColor Yellow
		break;
	}
}
else {
	Set-Location "$cmsc`:"
}

Write-Output "requesting task sequences from site: $cmsc..."

$tslist = Get-CMTaskSequence
if ($tslist -ne $null) {
	$tscount = $tslist.Length
	foreach ($ts in $tslist) {
		$TsName = $ts.Name
		$TsPath = "$TargetPath\$TsName.zip"
		if (!($ListOnly)) {
			Write-Output "Exporting: $TsName..."
			Export-CMTaskSequence -Name "$TsName" -ExportFilePath "$TsPath" -WithDependence $Deps -WithContent $Cont -ErrorAction Continue
		}
		else {
			Write-Output "name: $TsName`n`texport: $TsPath"
		}
	}
	Write-Output "$tscount items were exported."
}
else {
	Write-Output "No task sequences were found"
}
cd $old