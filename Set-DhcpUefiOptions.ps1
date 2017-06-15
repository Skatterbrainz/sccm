param (
    [parameter(Mandatory=$true)] [string] $DHCPSvr,
    [parameter(Mandatory=$true)] [string] $DHCPFqdn,
    [parameter(Mandatory=$true)] [string] $PXESvr,
    [parameter(Mandatory=$false)] [string] $Scope_ID = "",
    [parameter(Mandatory=$false)] [string] $PXE64Name = "PXEClient (UEFI x64)",
    [parameter(Mandatory=$false)] [string] $PXE86Name = "PXEClient (UEFI x86)",
    [parameter(Mandatory=$false)] [string] $PXEBName  = "PXEClient (BIOS x86 & x64)"
)

# Write-Host "DHCP Server: $DHCPSvr, FQDN: $DHCPFqdn, PXE: $PXESvr, SCOPE: $Scope_ID"

# set DHCP scope or server options for each CPU policy group

function Set-DhcpV4Option {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory=$True)] [string] $ComputerName,
        [parameter(Mandatory=$False)] [string] $ScopeID = ""
    )
    $x64set = @("60=PXEClient", "66=$PXESvr", "67=smsboot\x64\wdsmgfw.efi")
    $x86set = @("60=PXEClient", "66=$PXESvr", "67=smsboot\x86\wdsmgfw.efi")
    $cmbSet = @("66=$PXESvr", "67=smsboot\x64\wdsnbp.com")

    foreach ($bSet in $x64set) {
        $opt = $bSet.Split("=")
        if ($Scope_ID -eq "") {
            Write-Host "Set-DhcpServerv4OptionValue -ComputerName $ComputerName -PolicyName $PXE64Name -OptionId $($opt[0]) -Value $($opt[1])"
        }
        else {
            Write-Host "Set-DhcpServerv4OptionValue -ComputerName $ComputerName -PolicyName $PXE64Name -ScopeId $Scope_ID -OptionId $($opt[0]) -Value $($opt[1])"
        }
    }

    foreach ($bSet in $x86set) {
        $opt = $bSet.Split("=")
        if ($Scope_ID -eq "") {
            Write-Host "Set-DhcpServerv4OptionValue -ComputerName $ComputerName -PolicyName $PXE86Name -OptionId $($opt[0]) -Value $($opt[1])"
        }
        else {
            Write-Host "Set-DhcpServerv4OptionValue -ComputerName $ComputerName -PolicyName $PXE86Name -ScopeId $Scope_ID -OptionId $($opt[0]) -Value $($opt[1])"
        }
    }

    foreach ($bSet in $cmbSet) {
        $opt = $bSet.Split("=")
        if ($Scope_ID -eq "") {
            Write-Host "Set-DhcpServerv4OptionValue -ComputerName $ComputerName -PolicyName $PXEBName -OptionId $($opt[0]) -Value $($opt[1])"
        }
        else {
            Write-Host "Set-DhcpServerv4OptionValue -ComputerName $ComputerName -PolicyName $PXEBName -ScopeId $Scope_ID -OptionId $($opt[0]) -Value $($opt[1])"
        }
    }
}

function Set-DhcpV4Policy {
    param (
        [parameter(Mandatory=$True)] [string] $DHCPFQDN
    )
    foreach ($polSet in @("$PXE64Name","$PXE86Name","$PXEBName")) {
        Write-Host "Set-DhcpServerv4Policy -Name $polSet -Description "Set correct server and file name for $polSet" -Condition OR -VendorClass EQ -ComputerName $DHCPFQDN"
    }
}

function Set-DhcpV4Class {
    param (
        [parameter(Mandatory=$True)] [string] $DHCPHostName
    )
    foreach ($clSet in @("$PXE64Name=PXE:Arch:00007", "$PXE86Name=PXE:Arch:00006", "$PXEBName=PXE:Arch:00000")) {
        $Dclass = $clSet.Split("=")
        Write-Host "Add-DhcpServerv4Class -Name "$($Dclass[0])" -Description "$($Dclass[1])" -Type Vendor -Data "$($Dclass[1])" -Computer $DHCPHostName"
    }
}

#--------------------------------------------------------------------------------------------------------------------

# Set Vendor Classes:

Set-DhcpV4Class -DHCPHostName $DHCPSvr

# Create DHCP Policies (Leaving out the “ScopeId” option will make the policy a server level policy):

Set-DhcpV4Policy -DHCPFQDN $DhcpFqdn

Set-DhcpV4Option -ComputerName $DHCPSvr -ScopeID 192.168.29.0
