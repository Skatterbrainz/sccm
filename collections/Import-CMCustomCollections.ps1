[CmdletBinding()]
param (
    [parameter(Mandatory)][ValidateLength(3,3)][string] $SiteCode
)

if ($null -eq $env:SMS_ADMIN_UI_PATH) {
    Write-Warning "configmgr console is not installed on this instance"
    break
}
if (!(Get-Module ConfigurationManager)) {
    Import-Module $(Join-Path (Split-Path $env:SMS_ADMIN_UI_PATH) "ConfigurationManager.psd1")
}

try {
    $oldloc = Get-Location
    Set-Location "$SiteCode`:"

    #Configures variable for refresh schedules to use on collections to ensure variation 
    $Schedule1 = New-CMSchedule -Start "01/01/2014 10:00 PM" -DayOfWeek Monday -RecurCount 1
    $Schedule2 = New-CMSchedule -Start "01/01/2014 11:00 PM" -DayOfWeek Monday -RecurCount 1
    $Schedule4 = New-CMSchedule -Start "01/01/2014 1:00 AM" -DayOfWeek Thursday -RecurCount 1
    $Schedule5 = New-CMSchedule -Start "01/01/2014 2:00 AM" -DayOfWeek Friday -RecurCount 1
    $Schedule6 = New-CMSchedule -Start "01/01/2014 3:00 AM" -DayOfWeek Saturday -RecurCount 1
    $Schedule7 = New-CMSchedule -Start "01/01/2014 4:00 AM" -DayOfWeek Sunday -RecurCount 1
    $Schedule8 = New-CMSchedule -Start "01/01/2014 10:00 PM" -DayOfWeek Monday -RecurCount 1
    $Schedule2 = New-CMSchedule -Start "01/01/2014 11:00 PM" -DayOfWeek Tuesday -RecurCount 1
    $Schedule3 = New-CMSchedule -Start "01/01/2014 12:00 AM" -DayOfWeek Wednesday -RecurCount 1
    $Schedule4 = New-CMSchedule -Start "01/01/2014 1:00 AM" -DayOfWeek Thursday -RecurCount 1
    $Schedule5 = New-CMSchedule -Start "01/01/2014 2:00 AM" -DayOfWeek Friday -RecurCount 1
    $Schedule6 = New-CMSchedule -Start "01/01/2014 3:00 AM" -DayOfWeek Saturday -RecurCount 1
    $Schedule7 = New-CMSchedule -Start "01/01/2014 4:00 AM" -DayOfWeek Sunday -RecurCount 1
    $Schedule1 = New-CMSchedule -Start "01/01/2014 10:00 PM" -DayOfWeek Monday -RecurCount 1
    $Schedule2 = New-CMSchedule -Start "01/01/2014 11:00 PM" -DayOfWeek Tuesday -RecurCount 1
    $Schedule3 = New-CMSchedule -Start "01/01/2014 12:00 AM" -DayOfWeek Wednesday -RecurCount 1
    $Schedule4 = New-CMSchedule -Start "01/01/2014 1:00 AM" -DayOfWeek Thursday -RecurCount 1
    $Schedule5 = New-CMSchedule -Start "01/01/2014 2:00 AM" -DayOfWeek Friday -RecurCount 1
    $Schedule6 = New-CMSchedule -Start "01/01/2014 3:00 AM" -DayOfWeek Saturday -RecurCount 1
    $Schedule7 = New-CMSchedule -Start "01/01/2014 4:00 AM" -DayOfWeek Sunday -RecurCount 1
    $Schedule1 = New-CMSchedule -Start "01/01/2014 10:00 PM" -DayOfWeek Monday -RecurCount 1
    $Schedule2 = New-CMSchedule -Start "01/01/2014 11:00 PM" -DayOfWeek Tuesday -RecurCount 1
    $Schedule3 = New-CMSchedule -Start "01/01/2014 12:00 AM" -DayOfWeek Wednesday -RecurCount 1
    $Schedule4 = New-CMSchedule -Start "01/01/2014 1:00 AM" -DayOfWeek Thursday -RecurCount 1
    $Schedule5 = New-CMSchedule -Start "01/01/2014 2:00 AM" -DayOfWeek Friday -RecurCount 1
    $Schedule6 = New-CMSchedule -Start "01/01/2014 3:00 AM" -DayOfWeek Saturday -RecurCount 1
    $Schedule7 = New-CMSchedule -Start "01/01/2014 4:00 AM" -DayOfWeek Sunday -RecurCount 1
    $Schedule1 = New-CMSchedule -Start "01/01/2014 10:00 PM" -DayOfWeek Monday -RecurCount 1
    $Schedule2 = New-CMSchedule -Start "01/01/2014 11:00 PM" -DayOfWeek Tuesday -RecurCount 1
    $Schedule3 = New-CMSchedule -Start "01/01/2014 12:00 AM" -DayOfWeek Wednesday -RecurCount 1
    $Schedule4 = New-CMSchedule -Start "01/01/2014 1:00 AM" -DayOfWeek Thursday -RecurCount 1
    $Schedule5 = New-CMSchedule -Start "01/01/2014 2:00 AM" -DayOfWeek Friday -RecurCount 1
    $Schedule6 = New-CMSchedule -Start "01/01/2014 3:00 AM" -DayOfWeek Saturday -RecurCount 1
    $Schedule7 = New-CMSchedule -Start "01/01/2014 4:00 AM" -DayOfWeek Sunday -RecurCount 1

    #Accounting
    #Create new USER collection
    New-CMUserCollection -LimitingCollectionName "All Users" -Name "Users - Accounting - All" -refreshschedule $Schedule1 -Refreshtype Periodic
    #Create query for previously created collection
    Add-CMUserCollectionQueryMembershipRule -CollectionName "Users - Accounting - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'CONTOSO\\Users-Accounting'" -RuleName "Users - Accounting - All"
    #Move collection to appropriate folder
    $CMCollection = Get-CMUserCollection -Name "Users - Accounting - All"
    Move-CMObject -FolderPath "$SiteCode`:\UserCollection\Departments\Accounting" -InputObject $CMCollection

    #Create new DEVICE collection
    New-CMDeviceCollection -LimitingCollectionName "All Workstations" -Name "Devices - Accounting - All" -refreshschedule $Schedule1 -Refreshtype Periodic
    #Create query for previously created collection
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "Devices - Accounting - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'CONTOSO\\Computers - Accounting'" -RuleName "Devices - Accounting - All"
    #Move collection to appropriate folder
    $CMCollection = get-cmdevicecollection -Name "Devices - Accounting - All"
    Move-CMObject -FolderPath "$SiteCode`:\DeviceCollection\Departments\Accounting" -InputObject $CMCollection

    Set-Location $oldloc
}
catch {
    Write-Error $_.Exception.Message
}