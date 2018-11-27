SELECT DISTINCT
	BIOSVersion0 AS BIOSVersion,
	InstallDate0 AS InstallDate,
	Version0 AS [Version],
	COUNT(*) AS Clients
FROM 
	dbo.v_GS_PC_BIOS
GROUP BY
	BIOSVersion0,
	InstallDate0,
	Version0
