SELECT DISTINCT 
    SYS.Name0 AS ComputerName, 
    ARP.DisplayName0 AS ProductName, 
    ARP.Version0 AS Version, 
    dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OperatingSystem, 
    dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 AS Build, 
    SYS.User_Name0 AS LastUser, 
    dbo.v_R_User.User_Name0 AS MainUser, 
    SYS.AD_Site_Name0 AS ADSite
FROM 
    dbo.v_R_User INNER JOIN
    dbo.v_UsersPrimaryMachines ON 
    dbo.v_R_User.ResourceID = dbo.v_UsersPrimaryMachines.UserResourceID 
    RIGHT OUTER JOIN
    dbo.v_R_System AS SYS INNER JOIN
    dbo.v_FullCollectionMembership AS FCM ON FCM.ResourceID = SYS.ResourceID INNER JOIN
    dbo.v_Add_Remove_Programs AS ARP ON 
    SYS.ResourceID = ARP.ResourceID ON 
    dbo.v_UsersPrimaryMachines.MachineID = SYS.ResourceID LEFT OUTER JOIN
    dbo.v_GS_OPERATING_SYSTEM ON SYS.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID
WHERE 
    (ARP.DisplayName0 LIKE '%Microsoft % Standard%') OR
    (ARP.DisplayName0 LIKE 'Microsoft % Professional%') OR
    (ARP.DisplayName0 LIKE 'Microsoft % Enterprise %') OR
    (ARP.DisplayName0 = 'Microsoft Office 365 ProPlus - en-us')
ORDER BY
    ComputerName
