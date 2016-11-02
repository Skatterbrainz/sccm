#Import module necessary for connection to site server, must have CM console installed and script at location below
import-module "$env:ProgramFiles\Microsoft Configuration Manager\AdminConsole\Bin\ConfigurationManager.psd1"
Set-Location VB1:

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




#Agriculture
#Create new USER collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Agriculture - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Agriculture - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Agriculture - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Agriculture - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Agriculture" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Agriculture - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Agriculture - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Agriculture-U'" -RuleName "Devices - Agriculture - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Agriculture - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Agriculture" -InputObject $CMCollection


#Circuit Court
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Circuit Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Circuit Court - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Circuit Court-U'" -RuleName "Users - Circuit Court - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Circuit Court - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Circuit Court" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Circuit Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Circuit Court - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Circuit Court-U'" -RuleName "Devices - Circuit Court - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Circuit Court - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Circuit Court" -InputObject $CMCollection

#City Auditor
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - City Auditor - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - City Auditor - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Audit Services-U'" -RuleName "Users - City Auditor - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - City Auditor - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\City Auditor" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - City Auditor - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - City Auditor - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Audit Services-U'" -RuleName "Devices - City Auditor - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - City Auditor - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\City Auditor" -InputObject $CMCollection

#City Treasurer
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - City Treasurer - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - City Treasurer - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\FinanceTreasurer-G'" -RuleName "Users - City Treasurer - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - City Treasurer - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\City Treasurer" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - City Treasurer - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - City Treasurer - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - City Treasurer - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - City Treasurer - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\City Treasurer" -InputObject $CMCollection

#Clerk of Circuit Court
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Clerk of Circuit Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Clerk of Circuit Court - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\City Clerk-U'" -RuleName "Users - Clerk of Circuit Court - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Clerk of Circuit Court - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Clerk of Circuit Court" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Clerk of Circuit Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Clerk of Circuit Court - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer City Clerk-U'" -RuleName "Devices - Clerk of Circuit Court - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Clerk of Circuit Court - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Clerk of Circuit Court" -InputObject $CMCollection

#Commissioner of Revenue
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Commissioner of Revenue - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Commissioner of Revenue - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\FinanceCOR-G'" -RuleName "Users - Commissioner of Revenue - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Commissioner of Revenue - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Commissioner of Revenue" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Commissioner of Revenue - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Commissioner of Revenue - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Commissioner of the Revenue-U'" -RuleName "Devices - Commissioner of Revenue - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Commissioner of Revenue - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Commissioner of Revenue" -InputObject $CMCollection

#Commonwealth Attorney
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Commonwealth Attorney - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Commonwealth Attorney - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Commonwealth Attorney-U'" -RuleName "Users - Commonwealth Attorney - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Commonwealth Attorney - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Commonwealth Attorney" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Commonwealth Attorney - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Commonwealth Attorney - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Commonwealth Attorney-U'" -RuleName "Devices - Commonwealth Attorney - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Commonwealth Attorney - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Commonwealth Attorney" -InputObject $CMCollection

#Communication and Information Technology
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Communication & Information Technology - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Communication & Information Technology - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\ComIT-U'" -RuleName "Users - Communication & Information Technology - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Communication & Information Technology - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Communication & Information Technology" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Communication & Information Technology - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Communication & Information Technology - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer ComIT-U'" -RuleName "Devices - Communication & Information Technology - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Communication & Information Technology - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Communication & Information Technology" -InputObject $CMCollection

#Convention and Visitor Bureau
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Convention and Visitor Bureau - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Convention and Visitor Bureau - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Conventions and Visitors Bureau-U'" -RuleName "Users - Convention and Visitor Bureau - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Convention and Visitor Bureau - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Convention and Visitor Bureau" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Convention and Visitor Bureau - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Convention and Visitor Bureau - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Convention and Visitors Bureau-U'" -RuleName "Devices - Convention and Visitor Bureau - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Convention and Visitor Bureau - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Convention and Visitor Bureau" -InputObject $CMCollection

#Cultural Affairs
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Cultural Affairs - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Cultural Affairs - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Office of Cultural Affairs-U'" -RuleName "Users - Cultural Affairs - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Cultural Affairs - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Cultural Affairs" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Cultural Affairs - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Cultural Affairs - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Office of Cultural Affairs-U'" -RuleName "Devices - Cultural Affairs - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Cultural Affairs - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Cultural Affairs" -InputObject $CMCollection

#Economic Development
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Economic Development - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Economic Development - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\EconomicDevelopment-G'" -RuleName "Users - Economic Development - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Economic Development - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Economic Development" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Economic Development - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Economic Development - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Economic Development-U'" -RuleName "Devices - Economic Development - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Economic Development - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Economic Development" -InputObject $CMCollection

#Emergency Communication and Citizen Services
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Emergency Communication and Citizen Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Emergency Communication and Citizen Services - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\ECCS-U'" -RuleName "Users - Emergency Communication and Citizen Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Emergency Communication and Citizen Services - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Emergency Communication and Citizen Services" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Emergency Communication and Citizen Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Emergency Communication and Citizen Services - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer ECCS-U'" -RuleName "Devices - Emergency Communication and Citizen Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Emergency Communication and Citizen Services - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Emergency Communication and Citizen Services" -InputObject $CMCollection

#Emergency Medical Services
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Emergency Medical Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Emergency Medical Services - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\EMS-U'" -RuleName "Users - Emergency Medical Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Emergency Medical Services - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Emergency Medical Services" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Emergency Medical Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Emergency Medical Services - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Emergency Medical Services-U'" -RuleName "Devices - Emergency Medical Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Emergency Medical Services - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Emergency Medical Services" -InputObject $CMCollection

#Executive - BLANK OU IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Executive - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Executive - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Executive - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Executive - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Executive" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Executive - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Executive - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - Executive - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - Executive - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Executive" -InputObject $CMCollection

#Finance
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Finance - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Finance - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Finance-U'" -RuleName "Users - Finance - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Finance - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Finance" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Finance - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Finance - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance-U'" -RuleName "Devices - Finance - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Finance - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Finance" -InputObject $CMCollection

#Fire
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Fire - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Fire - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Fire-U'" -RuleName "Users - Fire - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Fire - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Fire" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Fire - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Fire - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Fire-U'" -RuleName "Devices - Fire - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Fire - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Fire" -InputObject $CMCollection

#General District Court - BLANK OU IN AD
#Create new collection
3new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - General District Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - General District Court - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - General District Court - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - General District Court - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\General District Court" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - General District Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - General District Court - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - General District Court - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - General District Court - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\General District Court" -InputObject $CMCollection

#General Registrar
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - General Registrar - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - General Registrar - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\General Registrar-U'" -RuleName "Users - General Registrar - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - General Registrar - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\General Registrar" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - General Registrar - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - General Registrar - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer General Registrar-U'" -RuleName "Devices - General Registrar - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - General Registrar - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\General Registrar" -InputObject $CMCollection

#Housing and Neighborhood Preservation
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Housing and Neighborhood Preservation - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Housing and Neighborhood Preservation - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Housing-U'" -RuleName "Users - Housing and Neighborhood Preservation - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Housing and Neighborhood Preservation - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Housing and Neighborhood Preservation" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Housing and Neighborhood Preservation - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Housing and Neighborhood Preservation - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Housing-U'" -RuleName "Devices - Housing and Neighborhood Preservation - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Housing and Neighborhood Preservation - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Housing and Neighborhood Preservation" -InputObject $CMCollection

#Human Resources
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Human Resources - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Human Resources - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Human Resources-U'" -RuleName "Users - Human Resources - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Human Resources - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Human Resources" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Human Resources - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Human Resources - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Human Resources-U'" -RuleName "Devices - Human Resources - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Human Resources - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Human Resources" -InputObject $CMCollection

#Human Services
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Human Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Human Services - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\DHS-U'" -RuleName "Users - Human Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Human Services - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Human Services" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Human Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Human Services - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer DHS-U'" -RuleName "Devices - Human Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Human Services - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Human Services" -InputObject $CMCollection

#Juvenile and Domestic Relations District Court - BLANK OU IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Juvenile and Domestic Relations District Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Juvenile and Domestic Relations District Court - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Juvenile and Domestic Relations District Court - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Juvenile and Domestic Relations District Court - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Juvenile and Domestic Relations District Court" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Juvenile and Domestic Relations District Court - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Juvenile and Domestic Relations District Court - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - Juvenile and Domestic Relations District Court - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - Juvenile and Domestic Relations District Court - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Juvenile and Domestic Relations District Court" -InputObject $CMCollection

#Juvenile Probation - BLANK OU IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Agriculture - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Agriculture - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Agriculture - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Agriculture - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Agriculture" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - City Treasurer - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - City Treasurer - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - City Treasurer - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - City Treasurer - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\City Treasurer" -InputObject $CMCollection

#Law - BLANK OU IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Agriculture - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Agriculture - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Agriculture - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Agriculture - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Agriculture" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - City Treasurer - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - City Treasurer - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - City Treasurer - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - City Treasurer - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\City Treasurer" -InputObject $CMCollection

#Legislative - BLANK OU IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Agriculture - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Agriculture - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Agriculture - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Agriculture - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Agriculture" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - City Treasurer - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - City Treasurer - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - City Treasurer - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - City Treasurer - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\City Treasurer" -InputObject $CMCollection

#Library
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Library - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Library - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Libraries-U'" -RuleName "Users - Library - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Library - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Library" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Library - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Library - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Libraries-U'" -RuleName "Devices - Library - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Library - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Library" -InputObject $CMCollection

#Magistrates - BLANK OU IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Agriculture - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Agriculture - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Agriculture - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Agriculture - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Agriculture" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - City Treasurer - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - City Treasurer - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - City Treasurer - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - City Treasurer - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\City Treasurer" -InputObject $CMCollection

#Management Services
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Management Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Management Services - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Management Services-U'" -RuleName "Users - Management Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Management Services - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Management Services" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Management Services - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Management Services - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'Computer Management Services-U'" -RuleName "Devices - Management Services - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Management Services - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Management Services" -InputObject $CMCollection

#Museum and Cultural Arts
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Museum and Cultural Arts - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Museum and Cultural Arts - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Museums-U'" -RuleName "Users - Museum and Cultural Arts - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Museum and Cultural Arts - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Museum and Cultural Arts" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Museum and Cultural Arts - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Museum and Cultural Arts - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Museums-U'" -RuleName "Devices - Museum and Cultural Arts - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Museum and Cultural Arts - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Museum and Cultural Arts" -InputObject $CMCollection

#Parks and Recreation
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Parks and Recreation - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Parks and Recreation - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Parks and Recreation-U'" -RuleName "Users - Parks and Recreation - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Parks and Recreation - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Parks and Recreation" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Parks and Recreation - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Parks and Recreation - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Parks and Recreation-U'" -RuleName "Devices - Parks and Recreation - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Parks and Recreation - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Parks and Recreation" -InputObject $CMCollection

#Planning and Community Development
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Planning and Community Development - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Planning and Community Development - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Planning-U'" -RuleName "Users - Planning and Community Development - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Planning and Community Development - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Planning and Community Development" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Planning and Community Development - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Planning and Community Development - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Planning-U'" -RuleName "Devices - Planning and Community Development - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Planning and Community Development - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Planning and Community Development" -InputObject $CMCollection

#Police
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Police - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Police - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Police-U'" -RuleName "Users - Police - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Police - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Police" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Police - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Police - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Police-U'" -RuleName "Devices - Police - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Police - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Police" -InputObject $CMCollection

#Public Health - BLANK OU IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Agriculture - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Agriculture - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Agriculture - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Agriculture - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Agriculture" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - City Treasurer - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - City Treasurer - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - City Treasurer - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - City Treasurer - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\City Treasurer" -InputObject $CMCollection

#Public Utilities
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Public Utilities - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Public Utilities - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Public Utilities-U'" -RuleName "Users - Public Utilities - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Public Utilities - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Public Utilities" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Public Utilities - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Public Utilities - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Public Utilities-U'" -RuleName "Devices - Public Utilities - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Public Utilities - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Public Utilities" -InputObject $CMCollection

#Public Works
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Public Works - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Public Works - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\PublicWorks-G'" -RuleName "Users - Public Works - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Public Works - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Public Works" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Public Works - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Public Works - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Public Works-U'" -RuleName "Devices - Public Works - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Public Works - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Public Works" -InputObject $CMCollection

#Real Estate Assessor
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Real Estate Assessor - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Real Estate Assessor - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\FinanceREAssessor-G'" -RuleName "Users - Real Estate Assessor - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Real Estate Assessor - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Real Estate Assessor" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Real Estate Assessor - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Real Estate Assessor - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Real Estate Assessor-U'" -RuleName "Devices - Real Estate Assessor - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Real Estate Assessor - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Real Estate Assessor" -InputObject $CMCollection

#Sheriff's Office - NO GROUPS IN AD
#Create new collection
#new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Sheriff's Office - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmusercollectionquerymembershiprule -CollectionName "Users - Sheriff's Office - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\Agriculture-U'" -RuleName "Users - Sheriff's Office - All"
#Move collection to appropriate folder
#$CMCollection = get-cmusercollection -Name "Users - Sheriff's Office - All"
#move-cmobject -FolderPath "VB1:\UserCollection\Departments\Sheriff's Office" -InputObject $CMCollection

#Create new DEVICE collection
#new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Sheriff's Office - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
#add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Sheriff's Office - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Finance Treasurer-U'" -RuleName "Devices - Sheriff's Office - All"
#Move collection to appropriate folder
#$CMCollection = get-cmdevicecollection -Name "Devices - Sheriff's Office - All"
#move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Sheriff's Office" -InputObject $CMCollection

#Strategic Growth Area
#Create new collection
new-cmusercollection -LimitingCollectionName "All Users" -Name "Users - Strategic Growth Area - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmusercollectionquerymembershiprule -CollectionName "Users - Strategic Growth Area - All" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.UserGroupName = 'VBGOV\\SGA Office-U'" -RuleName "Users - Strategic Growth Area - All"
#Move collection to appropriate folder
$CMCollection = get-cmusercollection -Name "Users - Strategic Growth Area - All"
move-cmobject -FolderPath "VB1:\UserCollection\Departments\Strategic Growth Area" -InputObject $CMCollection

#Create new DEVICE collection
new-cmdevicecollection -LimitingCollectionName "All Workstations" -Name "Devices - Strategic Growth Area - All" -refreshschedule $Schedule1 -Refreshtype Periodic
#Create query for previously created collection
add-cmdevicecollectionquerymembershiprule -CollectionName "Devices - Strategic Growth Area - All" -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = 'VBGOV\\Computer Strategic Growth Area Office-U'" -RuleName "Devices - Strategic Growth Area - All"
#Move collection to appropriate folder
$CMCollection = get-cmdevicecollection -Name "Devices - Strategic Growth Area - All"
move-cmobject -FolderPath "VB1:\DeviceCollection\Departments\Strategic Growth Area" -InputObject $CMCollection

