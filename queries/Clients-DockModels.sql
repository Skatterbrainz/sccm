SELECT DISTINCT
    dbo.v_GS_SYSTEM_DEVICES.Name0 As DockModel,
    COUNT(*) as DockDevices
FROM dbo.v_GS_SYSTEM_DEVICES
GROUP BY Name0
WHERE Name0 LIKE '%Dock%'
ORDER BY DockDevices DESC
