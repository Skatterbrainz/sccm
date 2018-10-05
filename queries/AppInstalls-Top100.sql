SELECT TOP 100
	ProductName0 AS ProductName,
	ProductVersion0 AS [Version],
	Publisher0 AS Publisher,
	COUNT(*) AS Clients
FROM 
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED
GROUP BY
	ProductName0,
	ProductVersion0,
	Publisher0
ORDER BY
	Clients DESC
