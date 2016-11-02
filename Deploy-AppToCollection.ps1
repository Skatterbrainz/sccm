param (
    [parameter(Mandatory=$True)] [string] $DeviceName = "Win10A",
    [parameter(Mandatory=$True)] [string] $AppName = "7-zip",
    [parameter(Mandatory=$True)] [string] $CollectionName = "Test Workstations"
)


New-CmDeviceCollection -Name $CollectionName -LimitingCOllectionName "All Systems" -RefreshType ConstantUpdate

$Resource = Get-CmDevice -Name $DeviceName

Add-CmDeviceCollectionDirectMembershipRule -CollectionName $CollectionName -ResourceID $Resource.ResourceID

Start-CmApplicationDeploymentSimulation -CollectionName $CollectionName -Name $AppName -DeployAction Install

