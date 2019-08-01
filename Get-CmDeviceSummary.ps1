param (
  [string] $SiteServer,
  [string] $SiteCode
)
$q1 = "select resourceid,name,adsitename,client,isvirtualmachine,lastlogontimestamp from sms_r_system"
$q2 = "select resourceid,name,manufacturer,model from sms_g_system_computer_system"

$x1 = Get-CimInstance -Namespace "root\sms\site_$SiteCode" -ComputerName $SiteServer -Query $q1 | 
    select resourceid,name,adsitename,client,isvirtualmachine,lastlogontimestamp
$x2 = Get-CimInstance -Namespace "root\sms\site_$SiteCode" -ComputerName $SiteServer -Query $q2 | 
    select resourceid,name,manufacturer,model
