SELECT DISTINCT 
	dbo.v_GS_SoftwareFile.FileName, 
	dbo.v_GS_SoftwareFile.FileVersion, 
	COUNT(*) AS Installs
FROM 
	dbo.v_GS_SoftwareFile
WHERE 
	(dbo.v_GS_SoftwareFile.FileName = 'OneDrive.exe')
GROUP BY
	dbo.v_GS_SoftwareFile.FileName, 
	dbo.v_GS_SoftwareFile.FileVersion 	
ORDER BY 
	dbo.v_GS_SoftwareFile.FileVersion
