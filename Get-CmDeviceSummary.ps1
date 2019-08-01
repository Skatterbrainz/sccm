param (
  [string] $SiteServer,
  [string] $SiteCode
)
$smsns = "root\sms\site_$SiteCode"

$q1 = "select resourceid,name,adsitename,client,isvirtualmachine,lastlogontimestamp from sms_r_system"
$q2 = "select resourceid,name,manufacturer,model from sms_g_system_computer_system"
$q3 = "select ipsubnets,name from sms_r_system"

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
