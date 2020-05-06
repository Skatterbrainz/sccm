SELECT DISTINCT
	Caption0 AS OSName,
	BuildNumber0 AS OSBuild,
	CSDVersion0 AS SvcPack,
	OSArchitecture0 AS Arch,
	OSLanguage0 AS Lang,
	COUNT(*) AS Clients
FROM 
	dbo.v_GS_OPERATING_SYSTEM
GROUP BY
	Caption0,
	BuildNumber0,
	CSDVersion0,
	OSArchitecture0,
	OSLanguage0
ORDER BY 
	Caption0, BuildNumber0
