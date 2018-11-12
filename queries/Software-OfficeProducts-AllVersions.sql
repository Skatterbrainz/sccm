SELECT DISTINCT  
  SYS.Name0 AS ComputerName,
  ARP.DisplayName0 As [ProductName],
  ARP.Version0 As [Version],
  ARP.InstallDate0 As [InstallDate]
FROM 
  dbo.v_R_System As SYS
    INNER JOIN dbo.v_FullCollectionMembership FCM On FCM.ResourceID = SYS.ResourceID 
    INNER JOIN dbo.v_Add_REMOVE_PROGRAMS As ARP On SYS.ResourceID = ARP.ResourceID 
WHERE 
  (ARP.DisplayName0 LIKE '%Microsoft % Standard%'
    OR ARP.DisplayName0 LIKE 'Microsoft % Professional%'
    OR ARP.DisplayName0 LIKE 'Microsoft % Enterprise %')
ORDER BY 
  Name0 ASC
-- https://prajwaldesai.com/sccm-sql-query-for-microsoft-office-32-bit-and-64-bit/
