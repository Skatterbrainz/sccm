<#
 .SYNOPSIS
Replace PkgSourcePath assignments using explicit mapping

.DESCRIPTION
I hope the synopsis is enough, otherwise I've failed miserably.

.NOTES
Lazy hack: David Stein

.LINK
http://skatterbrainz.wordpress.com 

.EXAMPLE
.\Update-CmPackageSourcePaths.ps1

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

$pkgs = Get-CMPackage

foreach ($pkg in $pkgs) {
    Write-Host "PackageID: $($pkg.PackageID)"
    Write-Host "Name: $($pkg.Name)"
    $z = $pkg.PkgSourcePath
    Write-Host "Old Source: $z"
    $x = Swap-Paths -SourcePath $pkg.PkgSourcePath
    Write-Host "New Source: $x"
    if ($x -ne "") {
        if ($x.ToLower() -ne $z.ToLower()) {
            Write-Host "updating pacakge source path..."
            Set-CMPackage -Id $pkg.PackageID -Path $x
        }
    }
    write-host "----"
}

Write-Host "all done. go drink!"