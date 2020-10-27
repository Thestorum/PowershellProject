#Oprettelse af profile scripts til forskellige brugere
New-Item -path $profile -type file -Force

#Profile script til Iben IT
$Shell = $Host.UI.RawUI
$Shell.WindowTitle="Powershell Iben IT"
