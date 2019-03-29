<#
 .SYNOPSIS
Show Task Sequence Variable Assignments

.DESCRIPTION
This will write out the current SCCM OSD Task Sequence variable assignments
during OSD execution.  Insert into Task sequence where desired.  Enable or disable
each reference - or - set a TS variable to toggle this script on or off in the Task Sequence

.NOTES
Original author: Michael Niehaus
Lazy hack: David Stein

.LINK
https://blogs.technet.microsoft.com/mniehaus/2010/04/26/dumping-task-sequence-variables/

.EXAMPLE
.\Show-TsVars.ps1

#>
try {
	$TSenv   = New-Object -COMObject Microsoft.SMS.TSEnvironment 
	$logPath = $TSenv.Value("_SMSTSLogPath") 
	$logFile = Join-Path -Path $logPath" -ChildPath "$($myInvocation.MyCommand).log"
	Start-Transcript $logFile
	$TSenv.GetVariables() | Foreach-Object { Write-Host "$_ = $($tsenv.Value($_))" }
	Stop-Transcript 
}
catch {
	Write-Output $Error[0].Exception.Message
}
