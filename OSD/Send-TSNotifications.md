# Send Task Sequence Success/Fail Notifications

## Notes

* Inspired by 
* TS Group "Failure Group"
  * Condition: (TSVar) _SMSTSLastActionSucceeded equals "false"
  * Task Sequence Step "Capture Failure Conditions"
    * SET TSVar FailedStepName = "%_SMSTSLastActionName%"
    * SET TSVar FailedStepReturnCode = "%_SMSTSLastActionRetCode%"
    * SET TSVar AllStepsSucceeded = "False"
  * Set TS Variable "(OSDResults) - Failure"
    * SET TSVar "OSDResults" = "Failure"
  * Connect to Network Folder
    * Map drive to Z:
  * Create Log Folder 
    * cmd.exe /c md Z:\%OSDComputerName%\
  * Run PSScript: Send Deployment Failed Notification (Email) -- below
  * Run PSScript: Send Deployment Failed Notification (Teams)
* TS Group "Success Group"
  * Set TSVar "OSDResults" = "Success"
* TS Group "Cleanup and Logging"
  * Run PSScript: OSDResultsTally.ps1 by Mike Marable (2018)
    * Params: -Record "%OSDResults%"
    
## Script

```powershell
[CmdletBinding()]
param (
	[parameter(Mandatory)][string] $Type,
	[parameter()][string] $To = "",
	[parameter()][string] $Image,
	[parameter()][string] $SiteServer = "cm01.contoso.com",
	[parameter()][string] $smtpServer = "mail.contoso.com"
	[parameter()][string] $smtpFrom = "sender@contoso.com" 
)

$dateTime = Get-Date -f 'MM/dd/yyyy HH:mm:ss tt'

$computerName = (New-Object -COMObject Microsoft.SMS.TSEnvironment).Value("OSDComputerName")
$lastAction   = (New-Object -COMObject Microsoft.SMS.TSEnvironment).Value("FailedStepName")
$TaskSequence = (New-Object -COMObject Microsoft.SMS.TSEnvironment).Value("_SMSTSPackageName")
$ipconfig = ipconfig /all
$dns = ping $siteserver

function Send-Mail {
	param (
		[parameter(Mandatory)][string] $Body,
		[parameter(Mandatory)][string] $Subject
	)
	$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
	$message = New-Object Net.Mail.MailMessage
	$message.To.Add($to)
	$message.From = $smtpFrom
	$message.Subject = $subject
	$message.Body = $body
	$smtp.Send($message)
}

switch ($type) {
	'DeploymentFailure' {
		$pbody = @"
Task Sequence $TaskSequence failed to complete.

Computer: $computerName
Failed Step: $LastAction

Please review the logs located in \\$siteServer\OSDErrorLogs\$computerName
for further information.
"@
		$psubject = "SCCM TS ALERT: Task Sequence Failure"
	}
	'DeploymentComplete' {
		$pbody = @"
The image deployment process for $computerName completed at $dateTime
This computer was imaged with TS version: $image
"@
		$psubject = "SCCM TS Notice: Task Sequence Completed Successfully"
	}
} # switch
Send-Mail -body $pbody -subject $psubject
```
