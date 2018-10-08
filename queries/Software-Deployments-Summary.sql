SELECT 
	SoftwareName AS Software, 
	CollectionName AS Collection, 
	DeploymentTime, 
	NumberTotal AS NumTotal, 
	NumberSuccess AS NumSuccess, 
	NumberErrors AS NumFailed, 
	NumberInProgress AS NumPending, 
	NumberUnknown AS NumUnknown, 
	NumberOther AS NumOther, 
	ProgramName, 
	PackageID
FROM 
	dbo.v_DeploymentSummary
WHERE 
	(PackageID IS NOT NULL) AND (PackageID <> '')
ORDER BY 
	Software
