#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
    Collect SQL Server Information using DBATools

.DESCRIPTION
    Collect SQL Server Information using DBATools

.PARAMETER SqlServer
    SQL Server hostname (FQDN)

.PARAMETER SiteCode
    Configuration Manager Site Code

.PARAMETER Level
    Verbosity level of output: Basic, or Advanced (default = Basic)

.PARAMETER OutputFile
    Output file path. (default = -SqlServer value with .txt extension)

.EXAMPLE
    .\Get-CmSqlInfo.ps1 -SqlServer "cm01.contoso.local" -SiteCode "P01"

.EXAMPLE
    .\Get-CmSqlInfo.ps1 -SqlServer "cm01.contoso.local" -SiteCode "P01" -Level Advanced

.EXAMPLE
    .\Get-CmSqlInfo.ps1 -SqlServer "cm01.contoso.local" -SiteCode "P01" -Level Advanced -OutputFile "foo.txt"

.NOTES
    1809.01 - DS - Initial release

#>

[CmdletBinding()]
param (
	[parameter(Mandatory=$True, HelpMessage="ConfigMgr SQL Server FQDN")]
	    [ValidateNotNullOrEmpty()]
	    [string] $SqlServer,
	[parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
	    [ValidateLength(3,3)]
	    [string] $SiteCode,
	[parameter(Mandatory=$False, HelpMessage="Detail Level")]
	    [ValidateSet('Basic','Advanced')]
	    [string] $Level = 'Basic',
	[parameter(Mandatory=$False, HelpMessage="Output Filename")]
	    [ValidateNotNullOrEmpty()]
	    [string] $OutputFile = "$SqlServer.txt"
)
$ScriptVersion = "1809.01"
$dbname = "CM_$SiteCode"
$t1 = Get-Date
$PbCaption = "ConfigMgr SQL Assessment - $ScriptVersion"

if (!(Get-Module -Name dbatools -ListAvailable)) {
	Write-Warning "Install powershell module 'dbatools' first, then try again"
	exit
}
Import-Module dbatools -DisableNameChecking

function Write-Custom {
    param (
        [parameter(Mandatory=$True, HelpMessage="Caption for progress bar")]
            [ValidateNotNullOrEmpty()]
            [string] $Caption,
        [parameter(Mandatory=$True, HelpMessage="Task for progress bar and output file")]
            [ValidateNotNullOrEmpty()]
            [string] $TaskName,
        [parameter(Mandatory=$True, HelpMessage="Percent complete (0 to 100)")]
            [ValidateRange(0,100)]
            [int] $Percent,
        [parameter(Mandatory=$False, HelpMessage="Output file path")]
            [string] $LogFile = ""
    )
    Write-Progress -Activity $Caption -Status $TaskName -PercentComplete $Percent
    if ($LogFile -ne "") {
        "*** $($TaskName.ToUpper()) ***" | Out-File $LogFile -Append
    }
}

if ($Level -eq 'Advanced') { $Pmx = 2 } else { $Pmx = 10 }

Write-Output "Context: $($env:USERNAME).$($env:USERDNSDOMAIN)" | Out-File $OutputFile
Write-Output "HostName: $($env:COMPUTERNAME)" | Out-File $OutputFile -Append

Write-Custom -Caption $PbCaption -TaskName "Computer System" -Percent (1*$Pmx) -LogFile $OutputFile
Get-DbaComputerSystem -ComputerName $SqlServer | Out-File $OutputFile -Append

Write-Custom -Caption $PbCaption -TaskName "Build Reference" -Percent (2*$Pmx) -LogFile $OutputFile
Get-DbaSqlBuildReference -SqlInstance $SqlServer | Out-File $OutputFile -Append

Write-Custom -Caption $PbCaption -TaskName "Memory Allocation" -Percent (3*$Pmx) -LogFile $OutputFile
Get-DbaMaxMemory -SqlInstance $SqlServer | Out-File $OutputFile -Append

Write-Custom -Caption $PbCaption -TaskName "Services" -Percent (4*$Pmx) -LogFile $OutputFile
Get-DbaSqlService -ComputerName $SqlServer | Out-File $OutputFile -Append

Write-Custom -Caption $PbCaption -TaskName "Databases" -Percent (5*$Pmx) -LogFile $OutputFile
Get-DbaDatabase -SqlInstance $SqlServer | Select Name,Status,IsAccessible,RecoveryModel,SizeMB,Owner,LastFullBackup,LastLogBackup | Out-File $OutputFile -Append

Write-Custom -Caption $PbCaption -TaskName "Database Files" -Percent (6*$Pmx) -LogFile $OutputFile
Get-DbaDatabaseFile -SqlInstance $SqlServer -Database $dbname | Out-File $OutputFile -Append

Write-Custom -Caption $PbCaption -TaskName "Storage Space" -Percent (7*$Pmx) -LogFile $OutputFile
Get-DbaDatabaseSpace -SqlInstance $SqlServer | Out-File $OutputFile -Append

if ($Level -eq 'Advanced') {
    
    Write-Custom -Caption $PbCaption -TaskName "Network Ports" -Percent 50 -LogFile $OutputFile
    Get-DbaTcpPort -SqlInstance $SqlServer -Detailed | Select InstanceName,IPAddress,Port,Static,Type | Out-File $OutputFile -Append

    Write-Custom -Caption $PbCaption -TaskName "Features" -Percent 55 -LogFile $OutputFile
	Get-DbaSqlFeature -ComputerName $SqlServer | Out-File $OutputFile -Append

	Write-Custom -Caption $PbCaption -TaskName "Instance Properties" -Percent 60 -LogFile $OutputFile
	Get-DbaSqlInstanceProperty -SqlInstance $SqlServer | Select InstanceName,Name,Value | Format-Table | Out-File $OutputFile -Append
	
    Write-Custom -Caption $PbCaption -TaskName "Configuration Settings" -Percent 65 -LogFile $OutputFile
	Get-DbaConfig | Select Module,FullName,Value | Out-File $OutputFile -Append
	
    Write-Custom -Caption $PbCaption -TaskName "Processor Usage" -Percent 70 -LogFile $OutputFile
    $fmt = "Name",@{Label="PctPrivTime";Expression={$_.PercentPrivilegedTime}},@{Label="PctProcTime";Expression={$_.PercentProcessorTime}},@{Label="PctUserTime";Expression={$_.PercentUserTime}},@{Label="PriBase";Expression={$_.PriorityBase}},@{Label="PriCurr";Expression={$_.PriorityCurrent}},@{Label="ThdWaitReason";Expression={$_.ThreadWaitReasonVal}}
	Get-DbaCpuUsage -SqlInstance $SqlServer | Select Name,PercentPrivilegedTime,PercentProcessorTime,PercentUserTime,PriorityBase,PriorityCurrent,ThreadWaitReasonValue | Format-Table $fmt | Out-File $OutputFile -Append
	
    Write-Custom -Caption $PbCaption -TaskName "Agent Jobs" -Percent 75 -LogFile $OutputFile
	$fmt = @{Label="Job Name";Expression={$_.Name}},@{Label="Category";Expression={$_.Category}},@{Label="State";Expression={$_.CurrentRunStatus}},@{Label="Owner";Expression={$_.OwnerLoginName}},@{Label="LastRun";Expression={$_.LastRunDate}},@{Label="Result";Expression={$_.LastRunOutcome}}
	Get-DbaAgentJob -SqlInstance "cm01.contoso.local" | Select Name,Category,OwnerLoginName,CurrentRunStatus,LastRunDate,LastRunOutcome | Format-Table $fmt | Out-File $OutputFile -Append
	
    Write-Custom -Caption $PbCaption -TaskName "Service Principal Names" -Percent 80 -LogFile $OutputFile
	Get-DbaSpn -ComputerName $SqlServer | Out-File $OutputFile -Append
	
    Write-Custom -Caption $PbCaption -TaskName "Instance User Options" -Percent 85 -LogFile $OutputFile
	Get-DbaSqlInstanceUserOption -SqlInstance $SqlServer | Select InstanceName,Name,Value | Format-Table | Out-File $OutputFile -Append
	
    Write-Custom -Caption $PbCaption -TaskName "SP Configuration" -Percent 90 -LogFile $OutputFile
    Get-DbaSpConfigure -SqlInstance $SqlServer | Out-File $OutputFile -Append
    
    Write-Custom -Caption $PbCaption -TaskName "Log Status" -Percent 95 -LogFile $OutputFile
	Get-DbaSqlLog -SqlInstance $SqlServer | Select InstanceName,Source,LogDate,HasErrors | Out-File $OutputFile -Append
}

Write-Custom -Caption $PbCaption -TaskName "Completed!" -Percent 100

$t2 = Get-Date
$tdiff = New-TimeSpan -Start $t1 -End $t2
Write-Host "`nCompleted. runtime: $($tdiff.TotalSeconds) seconds"
