# Examples

## Test-CMDeviceNameADConflict.ps1

```powershell
Test-CMDeviceNameADConflict.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "12352342" -TSVariable "ACCTEXISTS"
```

Sets TS variable "ACCTEXISTS" to "TRUE" if %OSDComputerName% value exists in Active Directory domain

```powershell
Test-CMDeviceNameADConflict.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "12352342" -TSVariable "ACCTEXISTS" -Delete
```

Sets TS variable "ACCTEXISTS" to "FALSE" if %OSDComputerName% value is found and deleted in Active Directory domain

```powershell
Test-CMDeviceNameADConflict.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "12352342" -TSVariable "ACCTEXISTS" -ComputerName "WS004"
```

Sets TS variable "ACCTEXISTS" to "TRUE" if computer "WS004"" exists in Active Directory domain. This is mainly for testing outside of a task sequence environment

## Set-ComputerNameIncrementAD.ps1

```powershell
Set-ComputerNameIncrementAD.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -Prefix "WS" -NameLength 5
```

If WS001 and WS002 exist in AD, but not WS003, then this will return WS003

## Move-ComputerOU.ps1

```powershell
Move-ComputerOU.ps1 -OU "OU=Workstations,OU=Chicago,OU=CORP,DC=contoso,DC=local"
```

Move local computer account into OU path
```powershell
Move-ComputerOU.ps1 -OU "OU=Workstations,OU=Chicago,OU=CORP,DC=contoso,DC=local" -ComputerName "WS001"
```

Move computer WS001 to OU path

```powershell
Move-ComputerOU.ps1 -OU %MachinObjectOU%
```

Move local computer account to OU specified by OSD task sequence variable
