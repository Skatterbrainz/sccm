
# EnableUpdateRing enables fast ring to opt in 1606
# Get these as an input
$siteServer=$args[0]

if(!$siteServer)
{
    "Provide the CAS site server name."
    Return
}

$WmiObjectSiteClass = "SMS_SCI_SiteDefinition"
$WmiObjectClass = "SMS_SCI_Component"
$WmiComponentName = "SMS_DMP_DOWNLOADER"
$WmiComponentNameUpdateRing = "UpdateRing" 


# Get provider instance
$providerMachine = Get-WmiObject -namespace "root\sms" -class "SMS_ProviderLocation" -computername $siteServer

# Get the first provider if there are multiple
if($providerMachine -is [system.array])
{
    $providerMachine=$providerMachine[0]
}

$SiteCode = $providerMachine.SiteCode
$ProviderMachineName = $providerMachine.Machine
$WmiObjectNameSpace="root\SMS\site_$($SiteCode)"

# Get top level site sitecode
$SiteDefinition = Get-WmiObject -Namespace $WmiObjectNameSpace -ComputerName $ProviderMachineName -Class $WmiObjectSiteClass | Where-Object { $_.ParentSiteCode -eq "" } 
$SiteCode  = $SiteDefinition.SiteCode

#Get component
$WmiObject = Get-WmiObject -Namespace $WmiObjectNameSpace -ComputerName $ProviderMachineName -Class $WmiObjectClass | Where-Object { $_.SiteCode -eq $SiteCode -and $_.ComponentName -eq $WmiComponentName } 

#Get embedded property
$props = $WmiObject.Props
$props = $props | where {$_.PropertyName -eq $WmiComponentNameUpdateRing}


if (!$props) {

    #Create embedded property
    $EmbeddedProperty = ([WMICLASS]"\\$($ProviderMachineName)\root\SMS\site_$($SiteCode):SMS_EmbeddedProperty").CreateInstance()
    $EmbeddedProperty.PropertyName = $WmiComponentNameUpdateRing
    $EmbeddedProperty.Value = 2
    $EmbeddedProperty.Value1 = ""
    $EmbeddedProperty.Value2 = ""

    $WmiObject.Props += [System.Management.ManagementBaseObject] $EmbeddedProperty

    $WmiObject.put()
}
else
{
    $props = $WmiObject.Props
    $index = 0
    ForEach($oProp in $props)
    {
        if($oProp.PropertyName -eq $WmiComponentNameUpdateRing)
        {
            $oProp.Value=2
            $props[$index]=$oProp;
        }
        $index++
    }

    $WmiObject.Props = $props
    $WmiObject.put()
}

Write-Host "The command(s) completed successfully"