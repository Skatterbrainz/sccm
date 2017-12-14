# for use with ConfigMgr run script feature
# David Stein - 12/11/2017
$LogName = ($env:COMPUTERNAME)+'-system-errors.csv'
$LogPath = '\\cm1.contoso.com\clientlogs$'
$LogFile = $LogPath+'\'+$LogName
Get-EventLog -LogName System -Newest 25 -EntryType Error | ConvertTo-Csv -NoTypeInformation | Out-File $LogFile
Write-Output 0
