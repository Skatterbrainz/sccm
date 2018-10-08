SELECT DISTINCT
	Manufacturer0 AS Manufacturer,
	Model0 AS Model,
	COUNT(*) AS Clients
FROM
	dbo.v_GS_COMPUTER_SYSTEM
GROUP BY
	Manufacturer0,
	Model0
ORDER BY 
	Manufacturer0,
	Model0
