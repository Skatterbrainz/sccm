SELECT DISTINCT 
	dbo.v_R_System.Name0 AS Computer, 
	dbo.v_GS_SoftwareFile.FileName, 
	dbo.v_GS_SoftwareFile.FileVersion, 
	CASE 
	WHEN (FileVersion = '18.151.0729.0012') THEN 'Current' 
	ELSE '' END AS Status, 
	dbo.v_GS_SoftwareFile.FileSize, 
	dbo.v_GS_SoftwareFile.FilePath
FROM 
	dbo.v_GS_SoftwareFile INNER JOIN
	dbo.v_R_System ON dbo.v_GS_SoftwareFile.ResourceID = dbo.v_R_System.ResourceID
WHERE 
	(dbo.v_GS_SoftwareFile.FileName = 'OneDrive.exe')
ORDER BY 
	Computer, 
	dbo.v_GS_SoftwareFile.FilePath
