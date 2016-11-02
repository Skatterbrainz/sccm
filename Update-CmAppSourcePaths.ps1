<#
 .SYNOPSIS
Replace Deployment Type source folder assignments using explicit mapping

.DESCRIPTION
I hope the synopsis is enough, otherwise I've failed miserably.

.NOTES
Lazy hack: David Stein

.LINK
http://skatterbrainz.wordpress.com 

.EXAMPLE
.\Update-CmAppSourcePaths.ps1

#>

function Get-CmAdminConsolePath {
    $result = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Setup" | 
        Select-Object -ExpandProperty "UI Installation Directory"
    $cpath = "$result\bin\ConfigurationManager.psd1"
    if (Test-Path $cpath) { $cpath }
}

function Swap-Paths {
    param (
        [parameter(Mandatory=$False)] 
        [string] $SourcePath = ""
    )
    $newPath = ""
    if ($SourcePath -ne "") {
        $newPath = $SourcePath.ToLower().replace("\\server1.contoso.com\apps$", "\\FS1.fabrikam.com\DSL$\Apps")
        $newPath = $newPath.ToLower().replace("\\Apps1.fubar.com\software$\apps", "\\FS2.fabrikam.com\DSL$\Apps")
    }
    return $newPath
}

Import-Module $(Get-CmAdminConsolePath)

$SiteCode = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\SMS\Identification" -Name "Site Code" | Select-Object -ExpandProperty "Site Code"
cd "$SiteCode`:"

Write-Host "Querying Applications..." -ForegroundColor Cyan

$Apps = Get-CMApplication
$AppNames = $Apps.LocalizedDisplayName
$AppCount = $AppNames.Count
$RowCount = 1

Write-Host "Returned $AppCount objects"

foreach ($AppName in $AppNames) {
    Write-Host "Application: $AppName ($RowCount of $AppCount)" -ForegroundColor White
    $DtNames = Get-CMDeploymentType -ApplicationName $AppName
    Write-Host "Querying Deployment types..." -ForegroundColor Cyan
    foreach ($dt in $DtNames) {
        $DtSDMPackageXML = $dt.SDMPackageXML
        $DtSDMPackageXML = [xml]$DtSDMPackageXML
		$DtLocalName = $dt.LocalizedDisplayName
        $DtCleanPath = ""
        $DtCleanPath = $DtSDMPackageXML.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location[0]

        # check if array returned only a "\" value, indicating a singular value
		if ($DtPath.Length -lt 2) {
            $DtPath = $DtSDMPackageXML.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location
        }
        Write-Host "Current source: $DtPath" -ForegroundColor Cyan
        $NewDtPath = Swap-Paths -SourcePath $DtPath
        Write-Host "New directory source: $NewDtPath" -ForegroundColor Green
        if ($NewDtPath -ne "") {
            if ($NewDtPath.ToLower() -ne $DtPath.ToLower()) {
                Set-CMDeploymentType -ApplicationName "$AppName" -DeploymentTypeName $DtLocalName -MsiOrScriptInstaller -ContentLocation "$NewDtPath"
                Write-Host "Updating: $DtLocalName" -ForegroundColor Cyan
            }
            else {
                Write-Host "No changes made" -ForegroundColor Cyan
            }
        }
    }
    Write-Host "--------------"
	$RowCount++
}