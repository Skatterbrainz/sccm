SELECT DISTINCT 
	dbo.v_R_System.Name0 AS Computer, 
	dbo.v_GS_INSTALLED_EXECUTABLE.ResourceID, 
	dbo.v_GS_INSTALLED_EXECUTABLE.ExecutableName0 AS ExeName, 
	dbo.v_GS_INSTALLED_EXECUTABLE.FileSize0 AS FileSize, 
	dbo.v_GS_INSTALLED_EXECUTABLE.FileVersion0 AS FileVersion, 
	dbo.v_GS_INSTALLED_EXECUTABLE.InstalledFilePath0 AS InstallPath, 
	dbo.v_GS_INSTALLED_EXECUTABLE.ProductCode0 AS ProductCode, 
	dbo.v_GS_INSTALLED_EXECUTABLE.ProductVersion0 AS ProductVersion, 
	dbo.v_GS_INSTALLED_EXECUTABLE.Publisher0 AS Publisher
FROM 
	dbo.v_GS_INSTALLED_EXECUTABLE INNER JOIN
	dbo.v_R_System ON dbo.v_GS_INSTALLED_EXECUTABLE.ResourceID = dbo.v_R_System.ResourceID
WHERE 
	(dbo.v_GS_INSTALLED_EXECUTABLE.ExecutableName0 IN ('OneDrive.exe', 'Groove.exe'))
ORDER BY 
	Computer
