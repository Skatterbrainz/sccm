function Get-CmObjectCollection {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="SMS Provider Name")]
            [ValidateNotNullOrEmpty()]
            [string] $Computer,
        [parameter(Mandatory=$True, HelpMessage="Site Code")]
            [ValidateLength(3,3)]
            [string] $SiteCode,
        [parameter(Mandatory=$True, HelpMessage="WMI Class Name")]
            [ValidateNotNullOrEmpty()]
            [string] $ClassName,
        [parameter(Mandatory=$False, HelpMessage="Credentials")]
            [System.Management.Automation.PSCredential] $Credential
    )
    $Namespace = "ROOT\SMS\site_$SiteCode"
    try {
        if ($Credential) {
            $result = @(Get-WmiObject -Class $ClassName -ComputerName $Computer -Namespace $Namespace -Credential $Credential -ErrorAction SilentlyContinue)
        }
        else {
            $result = @(Get-WmiObject -Class $ClassName -ComputerName $Computer -Namespace $Namespace -ErrorAction SilentlyContinue)
        }
        return $result | Select-Object * -ExcludeProperty PSComputerName, Scope, Path, Options, ClassPath, 
            Properties, SystemProperties, Qualifiers, Site, Container, __GENUS, __CLASS, __SUPERCLASS, 
            __DYNASTY, __RELPATH, __PROPERTY_COUNT, __DERIVATION, __SERVER, __NAMESPACE, __PATH

    }
    catch {
        Write-Error $Error[0].Exception.Message
    }
}

<#
if (!$cred) { $cred = (Get-Credential) }
Get-CmObjectCollection -Computer "CM01" -SiteCode "P01" -ClassName "SMS_R_System" -Credential $cred
Get-CmObjectCollection -Computer "CM01" -SiteCode "P01" -ClassName "SMS_G_System_WORKSTATION_STATUS" -Credential $cred
#>
