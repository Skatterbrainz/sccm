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
.\OSD-ShowVars.ps1

#>

# Determine where to do the logging 
$TSenv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
$logPath = $TSenv.Value("_SMSTSLogPath") 
$logFile = "$logPath\$($myInvocation.MyCommand).log"

# Start the logging 
Start-Transcript $logFile

# Write all the variables and their values 
$TSenv.GetVariables() | % { Write-Host "$_ = $($tsenv.Value($_))" }

# Stop logging 
Stop-Transcript 