SELECT DISTINCT
	TotalPhysicalMemory0 AS TotalMemory,
	COUNT(*) AS Clients
FROM 
	dbo.v_GS_X86_PC_MEMORY
GROUP BY
	TotalPhysicalMemory0
ORDER BY
	TotalPhysicalMemory0
