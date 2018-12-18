SELECT DISTINCT T1.ProductName, T1.Version, COUNT(*) AS QTY
FROM (
SELECT DISTINCT 
	SYS.Name0 AS ComputerName, 
	ARP.DisplayName0 AS ProductName, 
	ARP.Version0 AS [Version], 
	ARP.InstallDate0 AS InstallDate
FROM  
	dbo.v_R_System AS SYS INNER JOIN
    dbo.v_FullCollectionMembership AS FCM ON FCM.ResourceID = SYS.ResourceID INNER JOIN
    dbo.v_Add_Remove_Programs AS ARP ON SYS.ResourceID = ARP.ResourceID
WHERE 
	(
    (ARP.DisplayName0 LIKE '%Microsoft % Standard%') OR
    (ARP.DisplayName0 LIKE 'Microsoft % Professional%') OR
    (ARP.DisplayName0 LIKE 'Microsoft % Enterprise %') OR
    (ARP.DisplayName0 = 'Microsoft Office 365 ProPlus - en-us')
	)
) AS T1
GROUP BY
  ProductName, Version
ORDER BY 
  ProductName, Version
