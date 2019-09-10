Azure Active Directory Bulk Import Script  
Version 0.1

Place this script and the CSV file you want to import in the same directory. When you run the script it will ask for the name of the file. Please format the CSV with the correct attribute names for an Azure AD user, there is no attribute mapping in this script.

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
Very early version of the script for use with specific client. Can be used as a framework to include whatever Azure AD attributes you need. Does not support extension attributes by default. You can add additional attributes below in the specified section. If you don't know powershell well, wouldn't recommend editing anything else.

