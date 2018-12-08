SELECT DISTINCT 
  dbo.v_R_User.Full_User_Name0 AS FullName, 
  dbo.v_R_User.Unique_User_Name0 AS UserName, 
  dbo.v_R_User.Windows_NT_Domain0 AS UserDomain, 
  dbo.v_R_User.ResourceID, dbo.v_R_User.department, 
  dbo.v_R_User.title, 
  dbo.v_R_User.User_Principal_Name0 AS UPN, 
  dbo.v_R_User.Distinguished_Name0 AS UserDN, 
  dbo.v_R_User.SID0 AS SID, 
  u2.Unique_User_Name0 AS Mgr
FROM 
  dbo.v_R_User LEFT OUTER JOIN
  dbo.v_R_User AS u2 ON dbo.v_R_User.manager = u2.Distinguished_Name0
