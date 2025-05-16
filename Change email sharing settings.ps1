Import-Module ExchangeOnlineManagement
$adminUPN = Read-Host "Enter your admin UPN (e.g firstname.lastname@yourdomain.com)"
Connect-ExchangeOnline -UserPrincipalName $adminUPN
$targetUser = Read-Host "Enter the email address of the user whose calendar sharing you want to change"
$calendarFolder = "$($targetUser):\Calendar"
$existingPermission = Get-MailboxFolderPermission -Identity $calendarFolder -User Default -ErrorAction SilentlyContinue
if ($existingPermission) {
    Write-Host "Updating 'Default' calendar permissions to LimitedDetails for $targetUser..."
    Set-MailboxFolderPermission -Identity $calendarFolder -User Default -AccessRights LimitedDetails
} else {
    Write-Host "'Default' permission not found. Adding it as LimitedDetails for $targetUser..."
    Add-MailboxFolderPermission -Identity $calendarFolder -User Default -AccessRights LimitedDetails
}
Write-Host "Calendar sharing set to 'LimitedDetails' (shows titles and locations) for $targetUser."
Disconnect-ExchangeOnline -Confirm:$false