function Get-CmMaintenanceTasksInfo {
  param (
    [parameter(Mandatory=$False)]
      [string] $ServerName = "",
    [parameter(Mandatory=$True)]
      [ValidateLength(3,3)]
      [string] $SiteCode
  )
  try {
    if (![string]::IsNullOrEmpty($ServerName)) {
      $Tasks = Get-WmiObject -Namespace "root/sms/site_$SiteCode" -ComputerName $ServerName -Query 'Select * from SMS_SCI_SQLTask' -ErrorAction SilentlyContinue | Sort-Object TaskName
    }
    else {
      $Tasks = Get-WmiObject -Namespace "root/sms/site_$SiteCode" -Query 'Select * from SMS_SCI_SQLTask' -ErrorAction SilentlyContinue | Sort-Object TaskName
    }
    $vlist = @{1 = 'Su'; 2 = 'M'; 4 = 'Tu'; 8 = 'W'; 16 = 'Th'; 32 = 'F'; 64 = 'Sa'}

    Foreach ($Task in $Tasks){
        $tk = $Task | Select TaskName,Enabled,DeleteOlderThan,BeginTime,LatestBeginTime,DaysOfWeek
        $tname = $tk.TaskName
        $time1 = $($tk.BeginTime).Substring(8,4)
        $time2 = $($tk.LatestBeginTime).Substring(8,4)
        $t1 = $time1.Substring(0,2)+':'+$time1.Substring(2,2)
        $t2 = $time2.Substring(0,2)+':'+$time2.Substring(2,2)
        $days  = ($vlist.Keys | Where-Object {$_ -band $tk.DaysOfWeek} | Sort-Object | Foreach-Object {$vlist.Item($_)}) -join ', '
        $props = [ordered]@{
            TaskName   = $tname
            BeginTime  = $t1
            EndTime    = $t2
            DaysOfWeek = $days
        }
        New-Object PSObject -Property $props
    }
  }
  catch {
    Write-Error $Error[0].Exception.Message
  }
}
