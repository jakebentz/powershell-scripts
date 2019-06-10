#set variable for password file
$passwordFile = ".\passfile.txt"
#create password file
Read-Host "Enter password" -AsSecureString | ConvertFrom-SecureString | Out-File $passwordFile
