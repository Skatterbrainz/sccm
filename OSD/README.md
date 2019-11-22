# Examples

## Set-ComputerNameX.ps1

* Sets OSDComputerName using standard naming glue-sniffing formats
* No GUI forms, silent ninja style execution

```powershell
Set-ComputerNameX.ps1 -Format Form-Serial -Delimiter Hyphen
```

(laptop w/SN "1234567890") returns "LT-67890"

```powershell
Set-ComputerNameX.ps1 -Format Form-Serial -Delimiter Hyphen -NameLength 5
```

(laptop w/SN "1234567890") returns "LT-90"

```powershell
Set-ComputerNameX.ps1 -Format Form-Serial -Delimiter Hyphen -TrimSerialFrom Right
```

(desktop w/SN "1234567890") returns "WS-12345"

```powershell
Set-ComputerNameX.ps1 -Format Form-Serial -WorkstationPrefix "D" -NameLength 6
```

(desktop w/SN "1234567890") returns "D67890"

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

* Query AD for next available sequential device name, updates TS var OSDComputerName
* Requires ConfigMgr Web Service (https://www.scconfigmgr.com)

```powershell
Set-ComputerNameIncrementAD.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -Prefix "WS" -NameLength 5
```

If WS001 and WS002 exist in AD, but not WS003, then this will return WS003

## Set-ComputerNameIncrementCM.ps1

* Query CM database for next available sequential device name, updates TS var OSDComputerName
* Requires ConfigMgr Web Service (https://www.scconfigmgr.com)

```powershell
Set-ComputerNameIncrementCM.ps1 -URI "http://cm01.contoso.local/ConfigMgrWebService/ConfigMgr.asmx" -SecretKey "019230912309" -Prefix "WS" -NameLength 5
```

If WS001 and WS002 exist in the CM database, but not WS003, then this would return WS003

## Set-ComputerOUPath.ps1

* Set AD OU Path in CM OSD Task Sequence using IP Gateway
* Requires file: oulocations.txt

```powershell
Set-ComputerOUPath.ps1
```

Look for matching row in oulocations.txt using actual IPv4 gateway

```powershell
Set-ComputerOUPath.ps1 -Gateway "192.168.3.1"
```

Look for matching row in oulocations.txt using forced IPv4 gateway value

```powershell
Set-ComputerOUPath.ps1 -DataFile "oulocations2.txt"
```

Look for matching row in custom data file using actual IPv4 gateway. Default file is oulocations.txt

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
