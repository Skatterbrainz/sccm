<#
.SYNOPSIS
 Export-CmReports exports SCCM SQL RSP reports to RDL files in
 a specified location

.PARAMETER SiteCode
 3-character site code

.PARAMETER HostName
 NetBios hostname of SCCM RSP host

.PARAMETER ReportFolder
 Name of logical SSRS report folder, or "ALL" to export all folders
 Default is "/" which is not recursive

.PARAMETER OutputFolder
 Path location where RDL files will be exported
 Default is $USERPROFILE\Documents

.NOTES
 Written by: David Stein
 Date Create: 10/19/2016

.EXAMPLE
 Export-CmReports -SiteCode "ABC" -HostName "CM1"
 Export-CmReports -SiteCode "ABC" -HostName "CM1" -ReportFolder "My Custom Reports" -OutputFolder "C:\Temp"
 Export-CmReports -SiteCode "ABC" -HostName "CM1" -ReportFolder "ALL" -OutputFolder "C:\Temp"
#>


function Export-CmReports {
  param (
    [parameter(Mandatory=$True)] [string] $SiteCode,
    [parameter(Mandatory=$True)] [string] $HostName,
    [parameter(Mandatory=$False)] [string] $ReportFolder = "/",
    [parameter(Mandatory=$False)] [string] $OutputFolder = "$($env:USERPROFILE)\Documents"
  )
  $url = "http://$HostName/ReportServer/ReportService2010.asmx?WSDL"
  Write-Host "connecting to SSRS web service..." -ForegroundColor Cyan
  $ssrs = New-WebServiceProxy -Uri $url -UseDefaultCredential -Namespace "ReportingWebService"
  if ($ReportFolder -eq "ALL") {
    $folders = $ssrs.ListChildren("/ConfigMgr_$SiteCode", $False) | ?{$_.TypeName -eq 'Folder'}
  }
  else {
    $folders = $ssrs.ListChildren("/ConfigMgr_$SiteCode", $False) | ?{$_.Name -eq "$ReportFolder"}
  }

  if ($folders.Length -gt 0) {
    foreach ($folder in $folders) {
      $fname = $folder.Name
      $fpath = $folder.Path
      $reports = $ssrs.ListChildren("$fPath" , $False)
 
      if ($reports.Length -gt 0) {
 
        Write-Host "Folder: $fName : $($reports.Length) reports" -ForegroundColor Cyan
 
        $OutPath = "$OutputFolder\$fName"

        if (!(Test-Path $OutPath)) {
          md $OutPath -Force
        }
        foreach ($r in $reports) {
          $reportName = $r.Name 
          if ($r.Hidden -eq $True) {
            Write-Host "skipping hidden report: $reportName" -ForegroundColor Gray
          }
          else {
            Write-Host "reading: $reportName..." -ForegroundColor Green
            $def = $ssrs.GetItemDefinition($r.Path)
            $stream = [System.IO.File]::OpenWrite("$OutPath\$reportName.rdl")
            $stream.Write($def, 0, $def.Length)
            $stream.Close()
            Write-Host "exported: $reportName successfully!" -ForegroundColor Green
          }
        }
      }
      else {
        Write-Host "no reports were found" -ForegroundColor Cyan
      }
    } # foreach
  }
  Write-Host "done!"
}
