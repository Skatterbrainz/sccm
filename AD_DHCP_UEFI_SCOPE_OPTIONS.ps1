$DhcpHost = 'DC1'
$DhcpFQDN = 'DC1.contoso.com'
# address of DHCP host
$ScopeID  = '192.168.29.10'
# address of PXE host
$Option66 = '192.168.29.30'

# Set Vendor Classes:

Add-DhcpServerv4Class -Name "PXEClient (UEFI x64)" `
-Description "PXE:Arch:00007" `
-Type Vendor -Data "PXE:Arch:00007" `
-Computer $DhcpHost 

Add-DhcpServerv4Class -Name "PXEClient (UEFI x86)" `
-Description "PXE:Arch:00006" `
-Type Vendor -Data "PXE:Arch:00006" `
-Computer $DhcpHost

Add-DhcpServerv4Class -Name "PXEClient (BIOS x86 & x64)" `
-Description "PXE:Arch:00000" `
-Type Vendor -Data "PXE:Arch:00000" `
-Computer $DhcpHost
  
# Create DHCP Policies (Leaving out the "ScopeId" option will make the policy a server level policy):

Add-DhcpServerv4Policy -Name "PXEClient (UEFI x64)" `
-Description "Set correct server and file name for UEFI x64 PXE" `
-Condition OR `
-VendorClass EQ, "PXEClient (UEFI x64)*" `
-ComputerName $DhcpFQDN `
-ScopeId $ScopeID

Add-DhcpServerv4Policy -Name "PXEClient (UEFI x86)" `
-Description "Set correct server and file name for UEFI x86 PXE" `
-Condition OR `
-VendorClass EQ, "PXEClient (UEFI x86)*" `
-ComputerName $DhcpFQDN `
-ScopeId $ScopeID

Add-DhcpServerv4Policy -Name "PXEClient (BIOS x86 & x64)" `
-Description "Set correct server and file name for BIOS x86 & x64 PXE" `
-Condition OR `
-VendorClass EQ, "PXEClient (BIOS x86 & x64)*" `
-ComputerName $DhcpFQDN `
-ScopeId $ScopeID
  
# Set Policy Options (If server level policy, do not specify the "ScopeId" option): 

# ....For UEFI x64

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (UEFI x64)" `
-OptionId 60 `
-Value PXEClient 

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (UEFI x64)" `
-OptionId 66 `
-Value $Option66 

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (UEFI x64)" `
-OptionId 67 `
-Value "smsboot\x64\wdsmgfw.efi" 
  
# ....For UEFI x86

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (UEFI x86)" `
-OptionId 60 -Value PXEClient 

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (UEFI x86)" `
-OptionId 66 -Value $Option66 

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (UEFI x86)" `
-OptionId 67 `
-Value "smsboot\x86\wdsmgfw.efi" 
  
# ....For BIOS x86 & x64

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (BIOS x86 & x64)" `
-OptionId 66 `
-Value $Option66 

Set-DhcpServerv4OptionValue -ComputerName $DhcpHost `
-ScopeId $ScopeID `
-PolicyName "PXEClient (BIOS x86 & x64)" `
-OptionId 67 `
-Value "smsboot\x64\wdsnbp.com" 
