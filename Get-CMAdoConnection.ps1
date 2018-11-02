#requires -version 3.0
<#
.DESCRIPTION
    Returns an ADO connection object to an open connection to a ConfigMgr SQL database server
.PARAMETER SQLServerName
    Name of ConfigMgr SQL Server hostname
.PARAMETER DatabaseName
    Name of the SQL instance Database to connect to
.PARAMETER ConnectionTimeOut
    Optional SQL connection timeout value.  Default is 30.
.PARAMETER QueryTimeout
    Optional SQL query timeout value.  Default is 120.
.EXAMPLE
  $conn = .\Get-CMAdoConnection.ps1 -SQLServerName "cm01.contoso.local" -DatabaseName "CM_P01"
#>

[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr SQL Server hostname")]
      [ValidateNotNullOrEmpty()]
      [string] $SQLServerName,
    [parameter(Mandatory=$True, HelpMessage="SQL Server database name")]
      [ValidateNotNullOrEmpty()]
      [string] $DatabaseName,
    [parameter(Mandatory=$False, HelpMessage="SQL connection timeout value")]
      [int] $ConnectionTimeout = 30,
    [parameter(Mandatory=$False, HelpMessage="SQL query timeout value")]
      [int]$QueryTimeout = 120
)
Write-Verbose "opening new connection to $SQLServerName"
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $SQLServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
try {
    $conn.Open()
    Write-Output $conn
}
catch {
    Write-Error $Error[0].Exception.Message
    break
}
