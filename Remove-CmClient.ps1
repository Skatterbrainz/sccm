#requires -RunAsAdministrator
#requires -Version 3.0
<#
1. SMS Agent Host Service
2. CCMSetup service (if present)
3. \windows\ccm directory
4. \windows\ccmsetup directory
5. \windows\ccmcache directory
6. \windows\smscfg.ini
7. \windows\sms*.mif (if present)
8. HKLM\software\Microsoft\ccm registry keys
9. HKLM\software\Microsoft\CCMSETUP registry keys
10. HKLM\software\Microsoft\SMS registry keys
11. root\cimv2\sms WMI namespace
12. root\ccm WMI namespace
13.  In Task Scheduler library, under "Microsoft" delete the "Configuration Manager" folder and any tasks within it.
14. In the Machine Certificate store delete any certs under the SMS\certificates folder
#>

function Remove-CmClient {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param ()
    try {
        Write-Verbose "stopping ccmexec.exe process"
        Get-Process -Name "ccmexec.exe" | Stop-Process -Force -ErrorAction SilentlyContinue
        ('ccm','ccmsetup','ccmcache') | ForEach-Object {
            Write-Verbose "searching for folder: windows\$_"
            $fullpath = Join-Path -Path $env:SystemRoot -ChildPath $_
            if (Test-Path $fullpath) {
                Write-Verbose "found. removing folder: $fullpath"
                Remove-Item -Path $fullpath -Filter "*.*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            else {
                Write-Verbose "not found: $fullpath"
            }
        }
        Write-Verbose "searching for: windows\smscfg.ini"
        $smscfg = Join-Path -Path $env:SystemRoot -ChildPath "smscfg.ini"
        if (Test-Path $smscfg) {
            Write-Verbose "found. removing: windows\smscfg.ini"
            Remove-Item -Path $smscfg -Force -ErrorAction SilentlyContinue
        }
        else {
            Write-Verbose "smscfg.ini file not found"
        }
        Write-Verbose "searching for sms*.mif files in $env:SystemRoot"
        Get-ChildItem -Path $env:SystemRoot -Filter "sms*.mif" | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Verbose "searching for registry keys"
        ('HKLM:Software\Microsoft\ccm','HKLM:Software\Microsoft\ccmsetup','HKLM:Software\Microsoft\sms') | ForEach-Object {
            if (Test-Path -Path $_) {
                Write-Verbose "removing: $_"
                Remove-Item -Path $_ -Force -Recurse -ErrorAction SilentlyContinue
            }
            else {
                Write-Verbose "not found: $_"
            }
        }
    }
    catch {
        Write-Error $Error[0].Exception.Message
    }
}