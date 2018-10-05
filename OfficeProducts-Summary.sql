SELECT DISTINCT 
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0, 
	COUNT(*) AS Installs
FROM 
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED 
WHERE 
	(dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 IN 
		('Microsoft Office 365 ProPlus - en-us',
		'Microsoft Project Standard 2016 - en-us',
		'Microsoft Project Professional 2016 - en-us',
		'Microsoft Visio Standard 2016 - en-us',
		'Microsoft Visio Professional 2016 - en-us')
)
GROUP BY ProductName0
ORDER BY ProductName0
