SELECT DISTINCT 
  dbo.v_R_System.Name0 AS ComputerName,
  dbo.v_GS_USER_PROFILE.LocalPath0 AS ProfilePath, 
  dbo.v_GS_USER_PROFILE.ResourceID, 
  dbo.v_GS_USER_PROFILE.TimeStamp, 
  dbo.v_GS_USER_PROFILE.SID0 AS UserSID, 
  dbo.v_R_System.AD_Site_Name0 AS ADSite
FROM 
  dbo.v_GS_USER_PROFILE INNER JOIN
  dbo.v_R_User ON dbo.v_GS_USER_PROFILE.SID0 = dbo.v_R_User.SID0 INNER JOIN
  dbo.v_R_System ON dbo.v_GS_USER_PROFILE.ResourceID = dbo.v_R_System.ResourceID
WHERE 
  (dbo.v_R_User.Unique_User_Name0 = N'CONTOSO\sccmadmin')
ORDER BY ComputerName
