#region: Klient 2

#############################################################################
######################## Opsætning for Klient 2 #############################
#############################################################################

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential (“Domain2\administrator”, $pass)

New-NetIPAddress -IPAddress 10.0.2.11 -InterfaceAlias "Ethernet 2" -DefaultGateway 10.0.2.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet 2” -ServerAddresses 10.0.2.10
Disable-NetAdapterBinding -InterfaceAlias "Ethernet 2" -ComponentID ms_tcpip6

Add-Computer -domainname Domain2.local -Credential $cred -NewName Klient2 -Restart

#endregion