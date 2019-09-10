<#
Azure Active Directory Bulk Import Script
Version 0.1

--Required Attributes--:
DisplayName
Password
AccountEnabled
MailNickName
UserPrincipalName

--OtherMails--
This currently script only supports OtherMails separated by comma.
e.g 'user1@contoso.com, user2@contoso.com, etc'

09.10.19
Very early version of the script for use with specific client. Can be used as a framework to include whatever fields you need. You can add additional attributes below in the specified section. If you don't know powershell well, wouldn't recommend editing anything else.
#>

$Credential = Get-Credential
Connect-AzureAD -Credential $Credential

#Requests name of CSV file and imports
$file = Read-Host 'Input CSV file'
$users = Import-Csv -Path .\$file

#Sets required fields
$required = "DisplayName", "Password", "AccountEnabled","MailNickName","UserPrincipalName"

#Checks CSV to make sure it has all required fields.
$row = 2
Write-Host "Validating CSV. Please wait." -ForegroundColor Yellow

foreach($user in $users){

    foreach($field in $required){

        if($user.$field -eq ''){

            Write-Host "Required field '$field' is missing at row" $row". Ending execution." -ForegroundColor Red
            exit

        }

    }

    $row++

}

#Executes import if required fields are met on each entry.
$row = 2
Write-Host "CSV Valid. Proceeding with Import..." -ForegroundColor Yellow
foreach($user in $users){

    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $user.Password

    $OtherMails = $user.OtherMails -split ","
    [boolean]$enabled = [System.Convert]::ToBoolean($user.AccountEnabled);

    try{

        ##Begin Attribute Edit##
        New-AzureADUser `
            -AccountEnabled $enabled `
            -Department $user.Department `
            -DisplayName $user.DisplayName `
            -givenName $user.GivenName `
            -JobTitle $user.JobTitle `
            -MailNickname $user.MailNickName `
            -Mobile $user.Mobile `
            -OtherMails $OtherMails `
            -PasswordProfile $Passwordprofile `
            -PhysicalDeliveryOfficeName $user.PhysicalDeliveryOfficeName `
            -Surname $user.Surname `
            -TelephoneNumber $user.TelephoneNumber `
            -userPrincipalName $user.UserPrincipalName
        ##End Attribute Edit##

        $success = $true

        $foreground = 'Green'
        $background = 'DarkBlue'
        $message = "Successfully imported " + $user.displayName + "(" +$user.UserPrincipalName + ") at row $row"

    } catch {

        $success = $false

        Write-Host $_.Exception.Message -ForegroundColor Red -BackgroundColor Black

        $foreground = 'Black'
        $background = 'Red'
        $message = "Failure for " + $user.UserPrincipalName + " at row $row"
        
    } 

    Write-Host $message -ForegroundColor $foreground -BackgroundColor $background

    if(!$success) { exit }

    $row++

}
