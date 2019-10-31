# for "Run Script" feature in ConfigMgr
# david stein - 12/13/2017
$LogPath = 'c:\windows\ccm\logs'
$Upload  = '\\cm01.contoso.com\ClientLogs$\'+$env:COMPUTERNAME
if (!(Test-Path $Upload)) {
	mkdir $Upload
}
if (Test-Path $Upload) {
	robocopy $LogPath $Upload *.log /R:1 /W:3
	Write-Output 0
}
else {
	Write-Output -1
}
