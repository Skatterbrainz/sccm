SELECT DISTINCT
      CASE	
		WHEN (IsActivated_InitialValue0 = 1) THEN 'YES'
		ELSE 'NO' END AS [Activated],
      CASE
		WHEN (IsEnabled_InitialValue0 = 1) THEN 'YES'
		ELSE 'NO' END AS [Enabled],
      CASE
		WHEN (IsOwned_InitialValue0 = 1) THEN 'YES'
		ELSE 'NO' END AS [Owned],
	  COUNT(*) AS Clients
FROM 
	dbo.v_GS_TPM
GROUP BY
	IsActivated_InitialValue0,
	IsEnabled_InitialValue0,
	IsOwned_InitialValue0
