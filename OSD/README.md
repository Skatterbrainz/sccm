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
