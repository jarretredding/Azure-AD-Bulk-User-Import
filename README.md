Azure Active Directory Bulk Import Script  
Version 0.2

Run Script in same folder as CSV. You will be able to specify the name of the CSV.  

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

Version 0.2  
-Script can now update users currently in Azure AD  
-Does not update passwords of current users.  
-You can specify how many rows to process.  
-Password not longer required field for validation, but required for new users.  
-You can now specify which row to start  
-Can decline to update current users

Version 0.1  
Very early version of the script for use with specific client. Can be used as a framework to include whatever Azure AD attributes you need. Does not support extension attributes by default. You can add additional attributes below in the specified section. If you don't know powershell well, wouldn't recommend editing anything else.

