<#
Set-CmLab-WsusDBFilePaths.ps1
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="New Database Files Path")]
    [string] $NewFolderPath = "G:\Database"
)
$DatabaseName = "SUSDB"
$ServiceName = "WsusService"
$AppPool = "WsusPool"

Import-Module WebAdministration
Write-Verbose "stopping WSUS application pool"
Stop-WebAppPool -Name $AppPool
Write-Verbose "stopping WSUS service"
Get-Service -Name $ServiceName | Stop-Service

Import-Module SQLPS -DisableNameChecking
$UpdateStatistics = $False
$RemoveFullTextIndexFile = $False

$ServerName = $env:COMPUTERNAME
$ServerSource = New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName

Write-Verbose "detaching WSUS SUSDB database"
$Db = $ServerSource.Databases | Where-Object {$_.Name -eq $DatabaseName}
$CurrentPath = $Db.PrimaryFilePath
$ServerSource.DetachDatabase($DatabaseName, $True, $True)
$files = Get-ChildItem -Path $CurrentPath -Filter "$DatabaseName*.??f"
Write-Verbose "moving database files to $NewFolderPath"
$files | Move-Item -Destination $NewFolderPath
$files = (Get-ChildItem -Path $NewFolderPath -Filter "$DatabaseName*.??f") | Select-Object -ExpandProperty FullName
Write-Verbose "attaching database files"
$ServerSource.AttachDatabase("SUSDB", $files, 'sa')

Write-Verbose "starting WSUS service"
Get-Service -Name $ServiceName | Start-Service

Write-Verbose "starting WSUS app pool"
Start-WebAppPool -Name $AppPool

Write-Host "WSUS database files have been moved to $NewFolderPath"
