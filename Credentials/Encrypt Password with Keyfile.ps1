$KeyFile = Read-Host "KeyFile"
$EncryptedPassword = Read-Host "Password" -AsSecureString | ConvertFrom-SecureString -key (get-content $KeyFile)
Write-Host $EncryptedPassword
