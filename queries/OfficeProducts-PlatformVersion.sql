SELECT DISTINCT
	VersionToReport0 AS [Version],
	Platform0 AS [Platform],
	COUNT(*) AS Installs
FROM 
	dbo.v_GS_OFFICE365PROPLUSCONFIGURATIONS
GROUP BY
	VersionToReport0,
	Platform0
ORDER BY
	VersionToReport0
