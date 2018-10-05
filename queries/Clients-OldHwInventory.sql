SELECT DISTINCT 
	dbo.v_R_System.Name0 AS Computer, 
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OSVersion, 
	dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 AS Build, 
	dbo.v_GS_OPERATING_SYSTEM.OSArchitecture0 AS [Platform], 
	dbo.vWorkstationStatus.LastHardwareScan AS LastHWScan, 
	dbo.vWorkstationStatus.ClientVersion,
	dbo.vWorkstationStatus.LastMPServerName AS LastMP, 
	dbo.vWorkstationStatus.LastDDR, 
	dbo.vWorkstationStatus.LastHealthEvaluationResult
FROM 
	dbo.v_R_System INNER JOIN
	dbo.v_GS_OPERATING_SYSTEM ON dbo.v_GS_OPERATING_SYSTEM.ResourceID = dbo.v_R_System.ResourceID LEFT OUTER JOIN
	dbo.vWorkstationStatus ON dbo.v_R_System.ResourceID = dbo.vWorkstationStatus.ResourceID
WHERE 
	(dbo.v_GS_OPERATING_SYSTEM.OSArchitecture0 IS NULL) 
	OR 
	(DATEDIFF(dd,GETDATE(),dbo.vWorkstationStatus.LastHardwareScan) >= 14)
ORDER BY
	dbo.v_R_System.Name0
