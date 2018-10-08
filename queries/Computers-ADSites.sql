SELECT DISTINCT
	COALESCE(AD_Site_Name0, 'Default') AS ADSite,
	COUNT(*) AS Computers
FROM
	dbo.v_R_System
GROUP BY
	AD_SITE_Name0
ORDER BY
	ADSite
