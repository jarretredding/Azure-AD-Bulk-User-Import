Azure Active Directory Bulk Import Script  
Version 0.3

To use this script please place this and the CSV with your user data in the same folder. You can name the CSV whatever you want because it will either ask you for the name or you can specify it as a parameter. Here are the parameters you can use, their accepted input, their definitions.  

-file (string)(required)  
Tell the script the name of the CSV file that has the data you want processed.  

-getCredentials (boolean)(default: $false)  
This parameter will request login information for your Azure tenant if set to true.  

-startingRow (integer)(default: 2)  
Determines the starting row of data you want to process. Most data starts at row 2, but you can specify it to start later down the file.  

-rowsToProcess (bool|integer)(default: $false)  
You can specify how many entries to process. The count starts from $startingRow. Setting to $false processes all rows from $startingRow.  

-updateRows (bool)(default: $false)  
This script allows you to update data of users already in your Azure AD tenant. Set to $false by default.  

Example:  
.\import-users-azuread -getCredentials $true -file "importusers.csv" -startingRow 1000 -rowsToProcess 30 -updateRows $true  

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
Very early version of the script for use with specific case. Can be used as a framework to include whatever Azure AD attributes you need. Does not support extension attributes by default. You can add additional attributes below in the specified section. If you don't know powershell well, wouldn't recommend editing anything else.

