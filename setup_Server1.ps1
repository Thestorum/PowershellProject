#region: Server 1

#
#############################################################################
######################## Opsætning for Server 1 #############################
#############################################################################

New-NetIPAddress -IPAddress 10.0.1.10 -InterfaceAlias Ethernet -DefaultGateway 10.0.1.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses 127.0.0.1
Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6
Rename-Computer -NewName "Server1" -Force -Restart

#############################################################################

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
Install-windowsfeature AD-domain-services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -SafeModeAdministratorPassword $Pass `
-DomainName Domain1.local `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode Default `
-DomainNetbiosName "DOMAIN1" `
-ForestMode Default `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true

#############################################################################

$pass = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
New-ADUser -Name Klient_User1 -DisplayName Klient_User1 -SamAccountName KLU1 -AccountPassword $pass -Enabled:$true -PasswordNeverExpires:$true
#

#endregion