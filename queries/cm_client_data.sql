SELECT DISTINCT 
	dbo.v_R_System.Name0 AS ComputerName, 
	dbo.v_R_System.AD_Site_Name0 AS ADSiteName, 
	dbo.v_R_System.Client_Version0 AS ClientVersion, 
	dbo.v_GS_LOGICAL_DISK.DeviceID0 AS DiskID, 
	(dbo.v_GS_LOGICAL_DISK.Size0 / 1024.0) AS DiskSize, 
	(dbo.v_GS_LOGICAL_DISK.FreeSpace0 / 1024.0) AS DiskFree, 
	ROUND( (dbo.v_GS_LOGICAL_DISK.FreeSpace0 * 1.0 / dbo.v_GS_LOGICAL_DISK.Size0), 2) AS DiskUsed, 
	dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.IPEnabled0 AS IPEnabled, 
	dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.IPAddress0 AS IPAddress, 
	dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.MACAddress0 AS MACAddress, 
	dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.DefaultIPGateway0 AS IPGateway, 
	dbo.v_GS_PROCESSOR.Name0 AS Processor,
	 dbo.vWorkstationStatus.OperatingSystem, 
	dbo.vWorkstationStatus.LastHardwareScan
FROM 
	dbo.v_R_System INNER JOIN
	dbo.vWorkstationStatus ON dbo.v_R_System.ResourceID = dbo.vWorkstationStatus.ResourceID LEFT OUTER JOIN
	dbo.v_GS_PROCESSOR ON dbo.v_R_System.ResourceID = dbo.v_GS_PROCESSOR.ResourceID LEFT OUTER JOIN
	dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION ON dbo.v_R_System.ResourceID = dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.ResourceID LEFT OUTER JOIN
	dbo.v_GS_LOGICAL_DISK ON dbo.v_R_System.ResourceID = dbo.v_GS_LOGICAL_DISK.ResourceID
WHERE 
	(dbo.v_GS_LOGICAL_DISK.DeviceID0 = N'C:') 
	AND 
	(dbo.v_GS_NETWORK_ADAPTER_CONFIGURATION.IPEnabled0 = 1)
ORDER BY 
	ComputerName 
