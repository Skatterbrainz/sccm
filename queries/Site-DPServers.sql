SELECT 
    [ServerName],
    [SMSSiteCode] AS SiteCode,
    [IsPeerDP],
    [IsPullDP],
    [IsFileStreaming],
    [IsBITS],
    [IsMulticast],
    [IsProtected],
    [IsPXE],
    [IsActive],
    [AnonymousEnabled] AS [Anon],
    [SslState] AS [SSL],
    [PreStagingAllowed] AS [PreStage],
    [MinFreeSpace],
    [RemoveWDS],
    [ResponseDelay],
    [SupportUnknownMachines] AS [AllowUnknowns],
    [TransferRate],
    [Description]
FROM 
	dbo.vDistributionPoints
ORDER BY 
	ServerName
