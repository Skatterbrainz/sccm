SELECT DISTINCT 
    SYS.Name0 AS ComputerName, 
	ARP.DisplayName0 AS ProductName, 
	ARP.Version0 AS Version, 
	ARP.InstallDate0 AS InstallDate, 
	SYS.AD_Site_Name0 AS ADSite, 
    dbo.v_GS_COMPUTER_SYSTEM.Model0 AS Model, 
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OSName, 
	dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 AS OSBuild, 
    dbo.v_GS_PHYSICAL_MEMORY.Capacity0 AS Memory
FROM 
	dbo.v_R_System AS SYS INNER JOIN
    dbo.v_FullCollectionMembership AS FCM ON FCM.ResourceID = SYS.ResourceID INNER JOIN
    dbo.v_Add_Remove_Programs AS ARP ON SYS.ResourceID = ARP.ResourceID INNER JOIN
    dbo.v_GS_COMPUTER_SYSTEM ON SYS.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID INNER JOIN
    dbo.v_GS_OPERATING_SYSTEM ON SYS.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
    dbo.v_GS_PHYSICAL_MEMORY ON SYS.ResourceID = dbo.v_GS_PHYSICAL_MEMORY.ResourceID
WHERE 
	(ARP.DisplayName0 LIKE '%Microsoft % Standard%' OR
    ARP.DisplayName0 LIKE 'Microsoft % Professional%' OR
    ARP.DisplayName0 LIKE 'Microsoft % Enterprise %') 
	AND 
	(ARP.InstallDate0 IS NOT NULL)
ORDER BY 
	ProductName, Version
