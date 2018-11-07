[CmdletBindint()
param (
    [parameter(Mandatory=$False, HelpMessage="File containing computer names")]
    [string] $ListFile = "",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr CollectionID")]
    [string] $CollectionID = "",
    [parameter(Mandatory=$False, HelpMessage="Path to computer list files")]
    [ValidateNotNullOrEmpty()]
    [string] $InputFilesPath = ".\lists",
    [parameter(Mandatory=$False, HelpMessge="ConfigMgr SQL Server host name")]
    [ValidateNotNullOrEmpty()]
    [string] $ServerName = "cm01.contoso.local",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr site code")]
    [ValidateNotNullOrEmpty()]
    [string] $SiteCode = "P01",
    [parameter(Mandatory=$False, HelpMessage="Show total relative counts only")]
    [switch] $Summary,
    [parameter(Mandatory=$False, HelpMessage="Show extended AD and ConfigMgr data for each device")]
    [switch] $Detailed
)
if ([string]::IsNullOrEmpty($ListFile)) {
    $ListFile = Get-ChildItem -Path $InputFilesPath -Filter "*.txt" | Out-GridView -Title "Select File to Process" -OutputMode Single
    Write-Host "$ListFile" -ForegroundColor Cyan
    $filepath = $ListFile.FullName
    $filename = $ListFile.BaseName
}
else {
    Write-Host "reading list file: $ListFile" -ForegroundColor Cyan
    $x = Get-Item -Path $ListFile
    $filepath = $x.FullName
    $filename = $x.BaseName
}
$fileMembers = Get-Content -Path $filepath

if ([string]::IsNullOrEmpty($CollectionID)) {
    $collData = .\tools\Get-CmCollectionMember.ps1 -ServerName $ServerName -SiteCode $SiteCode -Choose
}
else {
    $collData = .\tools\Get-CmCollectionMember.ps1 -CollectionID $CollectionID -ServerName $ServerName -SiteCode $SiteCode
}

$collmembers = $collData | Select -ExpandProperty ComputerName
if ($Summary) {
    Write-Host "collection members: $($collmembers.Count)"
    Write-Host "file list members: $($fileMembers.Count)"
}
else {
    $result = @()
    $rownum = 1
    foreach ($fm in $fileMembers) {
        if ($collmembers -contains $fm) {
            $ismember = $True
        }
        else {
            $ismember = $False
        }
        if ($Detailed) {
            $adlogin = .\tools\Get-ADsComputers.ps1 -ComputerName $fm | Select -ExpandProperty LastLogon
            $cmdata  = .\tools\Get-CMDeviceInfo.ps1 -ServerName $ServerName -SiteCode $SiteCode -ComputerNames $fm
            $props1 = [ordered]@{
                ComputerName = $fm 
                RowID        = $rownum
                FileMember   = $True
                CollMember   = $ismember
                ADLastLogin  = $adlogin
                CMClient     = $cmdata.ClientVersion
                CMHwScan     = $cmdata.LastHwScan
            }
        }
        else {
            $props1 = [ordered]@{
                ComputerName = $fm 
                RowID        = $rownum
                FileMember   = $True
                CollMember   = $ismember
            }
        }
        $result += $(New-Object PSObject -Property $props1)
        $rownum++
    }
    foreach ($cm in $collmembers) {
        if ($Detailed) {
            $adlogin = .\tools\Get-ADsComputers.ps1 -ComputerName $cm | Select -ExpandProperty LastLogon
            $cmdata  = .\tools\Get-CMDeviceInfo.ps1 -ServerName $ServerName -SiteCode $SiteCode -ComputerNames $cm
            if ($fileMembers -notcontains $cm) {
                $props2 = [ordered]@{
                    ComputerName = $cm 
                    RowID        = $rownum
                    FileMember   = $False
                    CollMember   = $True
                    ADLastLogin  = $adlogin
                    CMClient     = $cmdata.ClientVersion
                    CMHwScan     = $cmdata.LastHwScan
                }
                $result += $(New-Object PSObject -Property $props2)
            }
        }
        else {
            if ($fileMembers -notcontains $cm) {
                $props2 = [ordered]@{
                    ComputerName = $cm 
                    RowID        = $rownum
                    FileMember   = $False
                    CollMember   = $True
                }
                $result += $(New-Object PSObject -Property $props2)
            }
        }
        $rownum++
    }
    $result
}
