<#
Azure Active Directory Bulk Import Script
Version 0.3

--Features--
Automatically formats PasswordProfile and OtherMails attributes
Automatically nullifies fields cells with blank entires for specific attributes (see below)
Can specify how many rows of your csv to process
Can specify which row to start at.
Errors completely stop script and deliver Powershell Error, UPN, and row number for troubleshooting

--Required Attributes--:
DisplayName
AccountEnabled
MailNickName
UserPrincipalName

--OtherMails--
This currently script only supports OtherMails separated by comma.
e.g 'user1@contoso.com, user2@contoso.com, etc'

Version 0.3
-Now accepts the following parameters in command line:
    -getCredentials (bool)
    -startingRow (integer)
    -$rowsToProcess $false || integer
    -$updateRows (bool)
    -file (string)

Version 0.2
-Script can now update users currently in Azure AD
-Does not update passwords of current users.
-You can specify how many rows to process.
-Password not longer required field for validation, but required for new users.
-You can now specify which row to start
-Can decline to update current users

Version 0.1
Very early version of the script for use with specific case. Can be used as a framework to include whatever fields you need. You can add additional attributes below in the specified section. If you don't know powershell well, wouldn't recommend editing anything else.
#>

param(
    [bool]$getCredentials = $false,
    [int]$startingRow = 2,
    [int]$rowsToProcess = $false,
    [bool]$updateRows = $false,
    [string]$file = $(Read-Host 'Input CSV file')
)

if($getCredentials -eq $true){

    $Credential = Get-Credential
    Connect-AzureAD -Credential $Credential

}

#Requests name of CSV file and imports
$users = Import-Csv -Path .\$file

#$rowStart = if(($rowinput = Read-Host "Enter starting row (Default: 2)") -eq '') {2} else {[int]$rowinput}
$rowStart = $startingRow

$processrows = $users | Measure-Object
$processrows = $processrows.Count
$processrows = if($rowsToProcess -eq $false) {$processrows} else {$rowsToProcess}

$updateCurrent = $updateRows

#Sets required fields
$required = "DisplayName","AccountEnabled","MailNickName","UserPrincipalName"

#Checks CSV to make sure it has all required fields.
$row = 2
$processed = 0
Write-Host "Validating CSV. Please wait." -ForegroundColor Yellow

foreach($user in $users){

    if($row -lt $rowStart) { 
        
        $row++
        continue 
    
    }

    if($processed -eq $processrows) { break }
    
    foreach($field in $required){

        if($user.$field -eq ''){

            Write-Host "Required field '$field' is missing at row" $row". Ending execution." -ForegroundColor Red
            exit

        }

    }

    $row++
    $processed++

}

#Executes import if required fields are met on each entry.
$row = 2
$processed = 0
Write-Host "CSV Valid. Proceeding with Import..." -ForegroundColor Yellow
foreach($user in $users){

    if($row -lt $rowStart) { 
        
        $row++
        continue 
    
    }

    if($processed -eq $processrows) { break }

    $OtherMails = New-Object 'System.Collections.Generic.List[string]'

    foreach($mail in ($user.OtherMails -split ",")){

        $OtherMails.add($mail)

    }

    [boolean]$enabled = [System.Convert]::ToBoolean($user.AccountEnabled);

    $employeeId = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.String]"
    $employeeId.Add('employeeId',$user.employeeId)

    $Department = if($user.Department  -eq '') {$null} else {$user.Department }
    $DisplayName = if($user.DisplayName  -eq '') {$null} else {$user.DisplayName}
    $givenName = if($user.givenName  -eq '') {$null} else {$user.givenName } 
    $JobTitle = if($user.JobTitle  -eq '') {$null} else {$user.JobTitle } 
    $mobile = if($user.Mobile -eq '') {$null} else {$user.Mobile}
    $otherMails =  if($otherMails[0] -eq '') { $null } else {$otherMails}
    $telephoneNumber = if($user.TelephoneNumber -eq '') {$null} else {$user.TelephoneNumber}
    $Surname = if($user.Surname -eq '') {$null} else {$user.Surname}
    $PhysicalDeliveryOfficeName = if($user.PhysicalDeliveryOfficeName  -eq '') {$null} else {$user.PhysicalDeliveryOfficeName } 

    try{
        
        Get-AzureADUser -ObjectId $user.UserPrincipalName | Out-Null

        if(!$updateCurrent) { 
            
            $row++
            $processed++
            continue 
        
        }

        ##Begin Attribute Edit##
        Set-AzureADUser `
            -AccountEnabled $enabled `
            -Department $Department `
            -DisplayName $DisplayName `
            -givenName $givenName `
            -ExtensionProperty $employeeId `
            -JobTitle $JobTitle `
            -MailNickname $user.MailNickName `
            -Mobile $mobile `
            -ObjectId $user.UserPrincipalName `
            -OtherMails $OtherMails `
            -PhysicalDeliveryOfficeName $PhysicalDeliveryOfficeName `
            -Surname $Surname `
            -TelephoneNumber $telephoneNumber   
        ##End Attribute Edit##

        $success = $true

        $foreground = 'Green'
        $background = 'DarkBlue'
        $message = "Successfully updated " + $user.displayName + "(" +$user.UserPrincipalName + ") at row $row"

    } catch {
        
        try{

            $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
            $PasswordProfile.Password = $user.Password

            ##Begin Attribute Edit##
            New-AzureADUser `
                -AccountEnabled $enabled `
                -Department $Department `
                -DisplayName $DisplayName `
                -givenName $givenName `
                -ExtensionProperty $employeeId `
                -JobTitle $JobTitle `
                -MailNickname $user.MailNickName `
                -Mobile $mobile `
                -OtherMails $OtherMails `
                -PasswordProfile $Passwordprofile `
                -PhysicalDeliveryOfficeName $PhysicalDeliveryOfficeName `
                -Surname $Surname `
                -TelephoneNumber $telephoneNumber `
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

    }
     
    Write-Host $message -ForegroundColor $foreground -BackgroundColor $background

    if(!$success) { exit }

    $row++
    $processed++

}

Write-Host $processed "rows processed."