SELECT DISTINCT
	AD_Site_Name0 AS ADSite,
	COUNT(*) AS Computers
FROM 
	dbo.v_R_System 
GROUP BY
	AD_Site_Name0
