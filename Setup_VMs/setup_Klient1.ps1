#region: Klient 1

#############################################################################
######################## Opsætning for Klient 1 #############################
#############################################################################

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential (“domain1\administrator”, $pass)

New-NetIPAddress -IPAddress 10.0.1.11 -InterfaceAlias "Ethernet 2" -DefaultGateway 10.0.1.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet 2” -ServerAddresses 10.0.1.10
Disable-NetAdapterBinding -InterfaceAlias "Ethernet 2" -ComponentID ms_tcpip6

Add-Computer -domainname Domain1.local -Credential $cred -NewName Klient1 -Restart

#endregion

#region PS REMOTE
Enable-PSRemoting -Force
#endregion