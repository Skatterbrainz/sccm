SELECT DISTINCT 
	MachineID,
	Name,
	DeviceOS,
	DeviceOSBuild,
	PrimaryUser,
	ClientVersion
FROM v_CombinedDeviceResources
WHERE
	Name NOT IN ('x86 Unknown Computer (x86 Unknown Computer)','x64 Unknown Computer (x64 Unknown Computer)','Provisioning Device (Provisioning Device)') 
	AND 
	MachineID NOT IN (
		select distinct ResourceID
		from v_GS_INSTALLED_SOFTWARE_CATEGORIZED
		where ProductName0 = 'Symantec Encryption Desktop'
	)
ORDER BY Name 
