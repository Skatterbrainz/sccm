<#
# 
# This script:
#      Creates some collections for OSD and Windows 10 Servicing,
#      also creates membership queries.
#      Check the variables (and adjust if necessary) before running
# 
# Niall Brady 2016/1/24
# 
#> 
Clear

Function Create-Collection($CollectionName)

{           
if ($CollectionName -eq $Collection_1 -or $CollectionName -eq $Collection_2 -or $CollectionName -eq $Collection_3)
             {
             write-host " (Limited to 'All Systems'). " -NoNewline
             $LimitingCollectionName = "All Systems"
             } 
            elseif ($CollectionName -eq $Collection_6 -or $CollectionName -eq $Collection_7 -or $CollectionName -eq $Collection_8 -or $CollectionName -eq $Collection_9)
             {
             write-host " (Limited to '$Collection_1'). " -NoNewline
             $LimitingCollectionName = "$Collection_1"
             }            
             else
             {
             write-host " (Limited to $Collection_3'). " -NoNewline
             $LimitingCollectionName = "$Collection_3"
             }  

 New-CMDeviceCollection -Name "$CollectionName" -LimitingCollectionName "$LimitingCollectionName" -RefreshType Both           
}

Function Create-Collections
{
Write-Host "Checking if collections exist, if not, create them." -ForegroundColor Green
# create an array of Collection Names
    $strCollections = @("$Collection_1", "$Collection_2", "$Collection_3", "$Collection_4", "$Collection_5", "$Collection_6", "$Collection_7", "$Collection_8", "$Collection_9")
        foreach ($CollectionName in $strCollections) {
            if (Get-CMDeviceCollection -Name $CollectionName){
                write-host "The collection '$CollectionName' already exists, skipping."
                } 
             else 
                {
                write-host "Creating collection: '$CollectionName'. " -NoNewline
                Create-Collection($CollectionName) | Out-Null
		        Write-Host "Done!" -ForegroundColor Green
                }
 }
}

Function Add-Membership-Query($TargetCollection)
{
Write-Host "Adding membership query to '$TargetCollection'." -ForegroundColor Green
Write-host "...checking for existing query which matches '$RuleName'. " -NoNewline
$check_RuleName = Get-CMDeviceCollectionQueryMembershipRule -CollectionName "$TargetCollection" -RuleName $RuleName | select-string -pattern "RuleName"
Write-Host "Done!" -ForegroundColor Green 
If ($check_RuleName -eq $NULL)
    {  
# add the query if the result was null!
    Write-host "...adding the new query. " -NoNewline
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "$TargetCollection" -QueryExpression "$RuleNameQuery" -RuleName "$RuleName"
    Write-Host "Done!" -ForegroundColor Green 
}
ELSE
    {
     Write-output "...that query already exists, will not add it again."
    }
}
#
# define the variables used in this script
#
$CMDrive='D:'
$Collection_1 = "All Workstations"
$Collection_2 = "All Servers"
$Collection_3 = "OSD Limiting"
$Collection_4 = "OSD Build"
$Collection_5 = "OSD Deploy"
$Collection_6 = "SUM Windows 10 Other"
$Collection_7 = "SUM Windows 10 CB"
$Collection_8 = "SUM Windows 10 CBB"
$Collection_9 = "SUM Windows 10 LTSB"

write-host "Starting script..." -ForegroundColor Yellow
# connect to ConfigMgr
#

Import-Module $CMDrive'\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
$SiteCode=Get-PSDrive -PSProvider CMSite
write-host "Connecting to " -ForegroundColor White -NoNewline
write-host $SiteCode -ForegroundColor Green -NoNewLine
cd "$($SiteCode):"
write-host ", done." -ForegroundColor White
 
# Create collections based on the array
Create-Collections
# add some queries to our collections
$TargetCollection = $Collection_1
$RuleName = "All Workstations"
$RuleNameQuery = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation%'"
Add-Membership-Query($TargetCollection)
$TargetCollection = $Collection_2
$RuleName = "All Servers"
$RuleNameQuery = "select * from  SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Server%'"
Add-Membership-Query($TargetCollection)
$TargetCollection = $Collection_3
$RuleName = "All Workstations and Manual Imported Computers"
$RuleNameQuery = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation%' or SMS_R_System.AgentName = 'Manual Machine Entry'"
Add-Membership-Query($TargetCollection)
$IncludeCollectionName = "All Unknown Computers"
Write-Host "...checking for Include Collection query for '$IncludeCollectionName'. " -NoNewline 
$check_IncludeRule = Get-CMDeviceCollectionIncludeMembershipRule -CollectionName "$TargetCollection" -IncludeCollectionName "$IncludeCollectionName" | select-string -pattern "RuleName"
Write-Host "Done!" -ForegroundColor Green 
IF ($check_IncludeRule -eq $NULL)
    {  
# add the query if the result was null!
    Write-host "...adding the new query. " -NoNewline
    Add-CMDeviceCollectionIncludeMembershipRule -CollectionName $TargetCollection -IncludeCollectionName "$IncludeCollectionName"
    Write-Host "Done!" -ForegroundColor Green 
}
ELSE
    {
     Write-output "...that query already exists, will not add it again."
    }

$TargetCollection = $Collection_4
$RuleName = "Imported Computers"
$RuleNameQuery = "select *  from  SMS_R_System where SMS_R_System.AgentName = 'Manual Machine Entry'"
Add-Membership-Query($TargetCollection)
$TargetCollection = $Collection_5
$IncludeCollectionName = $Collection_3
Write-Host "Adding membership query to '$TargetCollection'." -ForegroundColor Green
Write-Host "...checking for Include Collection query for '$IncludeCollectionName'. " -NoNewline 
$check_IncludeRule = Get-CMDeviceCollectionIncludeMembershipRule -CollectionName "$TargetCollection" -IncludeCollectionName "$IncludeCollectionName" | select-string -pattern "RuleName"
Write-Host "Done!" -ForegroundColor Green 
IF ($check_IncludeRule -eq $NULL)
    {  
# add the query if the result was null!
    Write-host "...adding the new query. " -NoNewline
    Add-CMDeviceCollectionIncludeMembershipRule -CollectionName $TargetCollection -IncludeCollectionName "$IncludeCollectionName"
    Write-Host "Done!" -ForegroundColor Green 
}
ELSE
    {
     Write-output "...that query already exists, will not add it again."
    }
   
Write-Host "Operations completed, exiting." -ForegroundColor Green