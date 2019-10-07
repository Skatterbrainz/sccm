# Task Sequence Goodies

## Disable Edge Desktop Shortcut

*Run Command*

```
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer /v "DisableEdgeDesktopShortcutCreation" /t REG_DWORD /d "1" /f
```

## Enable OneDrive Sync

*Run Command*

```
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive /v DisableFileSyncNGSC /t REG_DWORD /d 0 /f
```

## Capture Start Time as OSD Variable

*Run Command*

```
powershell (New-Object -COMObject Microsoft.SMS.TSEnvironment).Value("OSDStartInfo") = (Get-Date -f 'dd-MMM-yyyy hh:mm:ss')
```

## Move Computer OU

```powershell
param (
	[parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $OuPath
)
try {
	$compDN  = $([adsisearcher]"samaccountname=$($env:COMPUTERNAME)").FindOne().Path
	$compObj = [adsi]$compDN
	$compObj.psbase.MoveTo([adsi]"LDAP://$($OuPath)")
}
catch {
	$_.Exception.Message ; Exit 1
}
```

## Send Notification Email

* Name: Send TS Deployment Notification
* Type: Run PowerShell Script
* Config: Pkg/script: Send-TSCompleteNotification.ps1
* Args: -To "address" -Image "%_SMSTSPackageName%" -Type "DeploymentFailure"
