SELECT DISTINCT 
	dbo.v_DistributionPoints.ServerName, 
	dbo.v_DistributionPoints.SMSSiteCode AS SiteCode, 
	CASE 
		WHEN (dbo.v_DistributionPoints.SslState = 1) THEN 'Y' 
		ELSE 'N' END AS IsSSL, 
	CASE 
		WHEN (dbo.v_DistributionPoints.PreStagingAllowed = 1) THEN 'Y' 
		ELSE 'N' END AS IsPreStage, 
	CASE 
		WHEN (dbo.v_DistributionPoints.IsPXE = 1) THEN 'Y' 
		ELSE 'N' END AS IsPXE, 
	dbo.v_ContentDistributionReport_DP.PkgCount AS Packages, 
	dbo.v_ContentDistributionReport_DP.NumberInstalled AS Success, 
	dbo.v_ContentDistributionReport_DP.NumberInProgress AS Pending, 
	dbo.v_ContentDistributionReport_DP.NumberErrors AS Failed
FROM 
	dbo.v_DistributionPoints INNER JOIN 
	dbo.v_ContentDistributionReport_DP ON 
		dbo.v_DistributionPoints.NALPath = dbo.v_ContentDistributionReport_DP.DPNALPath
GROUP BY 
	dbo.v_DistributionPoints.ServerName, 
	dbo.v_DistributionPoints.SMSSiteCode, 
	dbo.v_DistributionPoints.SslState, 
	dbo.v_DistributionPoints.PreStagingAllowed, 
    dbo.v_DistributionPoints.IsPXE, 
	dbo.v_ContentDistributionReport_DP.PkgCount, 
	dbo.v_ContentDistributionReport_DP.NumberInstalled, 
    dbo.v_ContentDistributionReport_DP.NumberInProgress, 
	dbo.v_ContentDistributionReport_DP.NumberErrors
ORDER BY 
	dbo.v_DistributionPoints.ServerName
