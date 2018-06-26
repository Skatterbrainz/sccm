<#
.SYNOPSIS
    Deletes computer from SCCM and AD
.DESCRIPTION
    Queries AD & SCCM, deletes the computer account from AD, and removes the computer object from SCCM 
.NOTES
    Author: Jonathan - jon@elderec.org 
	Modified by David Stein, 5/1/2018
.LINK 
    http://elderec.org
.PARAMETER ComputerName
	Name of computer to delete from AD/SCCM
.PARAMETER sccmServer
	Name of the SCCM server to use
.PARAMETER sccmSite
	Name of the SCCM site to use
.EXAMPLE
	.\Remove-AdCmComputer.ps1 -ComputerName LAPTOP123
	.\Remove-AdCmComputer.ps1 -ComputerName LAPTOP123 -SccmServer sccm.contoso.com
	.\Remove-AdCmComputer.ps1 -ComputerName LAPTOP123 -SccmServer sccm.contoso.comm -SccmSite NPL
#> 

param (
	[parameter(Mandatory=$true, HelpMessage="Enter a computer name")][string] $ComputerName,
	[parameter(Mandatory=$false, HelpMessage="Enter SCCM server")][string] $SccmServer='contoso.local',
	[parameter(Mandatory=$false, HelpMessage="Enter SCCM server")][string] $SccmSite='P01'
)

# find and delete the computer from AD
$dom  = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $dom.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root
$search.Filter = "(&(objectClass=computer)(name=$ComputerName))"
$results = $search.FindAll()
if ($results.Count -gt 0) {
    try {
        $results | ForEach-Object {$_.GetDirectoryEntry() } | ForEach-Object {$_.DeleteObject(0)}
        Write-Host "$ComputerName deleted from Active Directory domain"
    }
    catch {
        Write-Host "$ComputerName could not be deleted from Active Directory domain"
    }
}
else {
    Write-Host "$ComputerName not found in Active Directory domain"
}

# find and delete from SCCM
try {
	$comp = Get-WmiObject -query "select * from SMS_R_SYSTEM WHERE Name='$computerName'" -computername $sccmServer -namespace "ROOT\SMS\site_$sccmSite"
	$comp.psbase.Delete()
	# spit out results
	Write-Host "Deleted $computerName from AD. Removed $computerName from SCCM server $sccmServer, site $sccmSite"
}
catch {
	Write-Host "$ComputerName not found in SCCM database"
}
