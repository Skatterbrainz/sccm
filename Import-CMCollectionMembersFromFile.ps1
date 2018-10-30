[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $InputFile,
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $CollectionID,
    [parameter(Mandatory=$False)]
        [string] $ServerName = "cm01.contoso.local",
    [parameter(Mandatory=$False)]
        [string] $SiteCode = "P01",
    [parameter(Mandatory=$False)]
        [string] $CommentChar = ';'
)
.\tools\Import-CMModule.ps1

if (!(Test-Path $InputFile)) {
    Write-Warning "$InputFile not found!!"
    break
}
$computers = Get-Content -Path $InputFile | ? {!$_.ToString().StartsWith($CommentChar)}
if ($computers.Count -lt 1) {
    Write-Warning "$InputFile contains no device names"
    break
}
Write-Host "$($computers.count) computers imported from file" -ForegroundColor Cyan

$members = .\tools\Get-CmCollectionMember.ps1 -CollectionID $CollectionID -ServerName $ServerName -SiteCode $SiteCode
$count1 = 0
$count2 = 0
if ($members.Count -gt 0) {
    Write-Host "$($members.Count) collection members found" -ForegroundColor Cyan
    $memberNames = ($members).ComputerName | Sort-Object ComputerName
    foreach ($comp in $computers) {
        Write-Host "$comp"
        if ($memberNames -contains $comp) {
            $data = [ordered]@{
                ComputerName = $comp 
                CollectionID = $CollectionID
                Action       = 'Already Member'
                DateStamp    = (Get-Date).DateTime
            }
            $count1++
            #Write-Host "$comp is already a member"
        }
        else {
            .\tools\Add-CMDeviceToCollection.ps1 -ComputerName $comp -CollectionID $CollectionID -ServerName $ServerName -SiteCode $SiteCode
            $data = [ordered]@{
                ComputerName = $comp 
                CollectionID = $CollectionID
                Action       = 'Added'
                DateStamp    = (Get-Date).DateTime
            }
            $count2++
        }
        New-Object -TypeName PSObject -Property $data
        Start-Sleep -Seconds 2
    } # foreach
    Write-Verbose "$count1 already members"
    Write-Verbose "$count2 added to collection"
}
