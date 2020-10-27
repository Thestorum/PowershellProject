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

#endregion

#region DNS
#Tilføj conditional forwarder fra domain1 til domain2
Add-DnsServerConditionalForwarderZone -Name Domain2.local -MasterServers 10.0.2.10
#endregion