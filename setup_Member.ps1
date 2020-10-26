#region: Memberserver

#############################################################################
############################# Memberserver ##################################
#############################################################################

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential (“domain1\administrator”, $pass)

New-NetIPAddress -IPAddress 10.0.1.20 -InterfaceAlias Ethernet -DefaultGateway 10.0.1.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses 10.0.1.10
Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6

Add-Computer -domainname Domain1.local -Credential $cred -NewName Member -Restart

Add-WindowsFeature adcs-cert-authority -IncludeManagementTools
Install-AdcsCertificationAuthority -AllowAdministratorInteraction:$true -CAType EnterpriseRootCa -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits 3


#endregion