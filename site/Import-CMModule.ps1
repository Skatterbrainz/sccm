function Import-CmModule {
    if (!(Get-Module -Name "ConfigurationManager")) {
        if ([string]::IsNullOrEmpty($env:SMS_ADMIN_UI_PATH)) {
            Write-Warning "ConfigMgr Console needs to be installed on the computer where this script is used"
            break
        }
        $mpath = $(Get-Item $($env:SMS_ADMIN_UI_PATH)).Parent.FullName
        try {
            Import-Module $(Join-Path -Path $mpath -ChildPath "ConfigurationManager.psd1") -ErrorAction Stop
            Write-Verbose "configuration manager powershell module loaded successfully"
        }
        catch {
            Write-Error $Error[0].Exception.Message
            break
        }
    }
    (!(!(Get-Module -Name "ConfigurationManager")))
}
