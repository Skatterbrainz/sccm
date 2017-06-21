[CmdletBinding(SupportsShouldProcess)]
Get-NetAdapterBinding | 
  Where-Object {($_.ElementName -eq 'ms_tcpip6') -and ($_.Enabled -eq $True)} | 
    Disable-NetAdapterBinding -ComponentID ms_tcpip6
