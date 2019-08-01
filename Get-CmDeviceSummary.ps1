param (
  [string] $SiteServer,
  [string] $SiteCode
)
$smsns = "root\sms\site_$SiteCode"

$q1 = "select resourceid,name,adsitename,client,OperatingSystemNameandVersion,isvirtualmachine,lastlogontimestamp from sms_r_system"
$q2 = "select resourceid,name,manufacturer,model from sms_g_system_computer_system"
$q3 = "select ipsubnets,name from sms_r_system"
$q5 = "select resourceid,caption,buildnumber,lastbootuptime,installdate from sms_g_system_operating_system"

# get all devices
$x1 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q1 | 
  select resourceid,name,adsitename,client,isvirtualmachine,lastlogontimestamp

# get clients with inventory data
$x2 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q2 | 
  select resourceid,name,manufacturer,model

# get unique device IP subnets
$x3 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q3 | select ipsubnets,name
$x4 = $x3 | % {
    try {
      $ipsub = @($_.IPSubnets | ?{ !$_.StartsWith('169') })[0]
    }
    catch {
      $ipsub = $null
    }
    [pscustomobject]@{
        Name = $_.Name
        Subnet = $ipsub
    }
}
$unique_subnets = $x4 | select subnet -Unique

$x5 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q5 | 
    select resourceid,caption,buildnumber,lastbootuptime,installdate

$os = $x5 | Select Caption -Unique | %{
    $cap = $_.Caption
    [pscustomobject]@{
        Caption = $cap
        Count   = $($x5 | ?{$_.caption -eq $cap}).Count
    }
}
$clients = $x1 | ? {$_.Client -eq 1}
