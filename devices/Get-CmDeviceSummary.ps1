[CmdletBinding()]
param (
  [string] $($env:COMPUTERNAME),
  [string] $SiteCode
)

Write-Host "gathering data from site server: $SiteServer ($SiteCode)" -ForegroundColor Cyan

try {
    $smsns = "root\sms\site_$SiteCode"

    $q1 = "select resourceid,name,adsitename,client,OperatingSystemNameandVersion,isvirtualmachine,lastlogontimestamp from sms_r_system"
    $q2 = "select resourceid,name,manufacturer,model from sms_g_system_computer_system"
    $q3 = "select ipsubnets,name from sms_r_system"
    $q5 = "select resourceid,caption,buildnumber,lastbootuptime,installdate from sms_g_system_operating_system"

    # get all devices
    $x1 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q1 | 
      Select-Object resourceid,name,adsitename,client,isvirtualmachine,lastlogontimestamp

    # get clients with inventory data
    $x2 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q2 | 
      Select-Object resourceid,name,manufacturer,model

    $models = $x2 | Select-Object Model -Unique | ForEach-Object {
        $model = $_.Model
        [pscustomobject]@{
            Model = $model
            Count = @($x2 | ?{$_.Model -eq $model}).Count
        }
    }

    # get unique device IP subnets
    $x3 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q3 | 
        Select-Object ipsubnets,name

    # get active client subnets
    $x4 = $x3 | ForEach-Object {
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
    
    # get unique subnets in sorted order
    $unique_subnets = $x4 | Select-Object subnet -Unique | 
        Sort-Object Subnet | 
            Select-Object -ExpandProperty Subnet

    $subnetcounts = $unique_subnets | ForEach-Object {
        $subnet = $_
        [pscustomobject]@{
            Subnet  = $subnet
            Devices = @($x4 | ?{$_.Subnet -eq $subnet}).Count
        }
    }

    $x5 = Get-CimInstance -Namespace $smsns -ComputerName $SiteServer -Query $q5 | 
        Select-Object resourceid,caption,buildnumber,lastbootuptime,installdate

    $oscounts = $x5 | Select-Object Caption -Unique | ForEach-Object {
        $cap = $_.Caption
        [pscustomobject]@{
            Caption = $cap
            Count   = @($x5 | ?{$_.caption -eq $cap}).Count
        }
    }
    $clients = $x1 | ? {$_.Client -eq 1}
    $clientcounts = [pscustomobject]@{
        Clients = $($clients.Count)
        NoClient = $($x1.Count - $clients.Count)
    }

}
catch {
    Write-Error $Error[0].Exception.Message
}
