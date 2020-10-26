

#region: Interne opsætninger

#############################################################################
################## SKAL KØRES PÅ DE VIRTUELLE MASKINER ######################
#############################################################################



#region: Server 2

<#
#############################################################################
######################## Opsætning for Server 2 #############################
#############################################################################

New-NetIPAddress -IPAddress 10.0.2.10 -InterfaceAlias Ethernet -DefaultGateway 10.0.2.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses 127.0.0.1
Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6
Rename-Computer -NewName "Server2" -Force -Restart

#############################################################################

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
Install-windowsfeature AD-domain-services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -SafeModeAdministratorPassword $Pass `
-DomainName Domain2.local `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode Default `
-DomainNetbiosName "DOMAIN2" `
-ForestMode Default `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true

#############################################################################

$pass = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
New-ADUser -Name Klient_User2 -DisplayName Klient_User2 -SamAccountName KLU2 -AccountPassword $pass -Enabled:$true -PasswordNeverExpires:$true

#>

#endregion

#region: Memberserver

#############################################################################
############################# Memberserver ##################################
#############################################################################

#

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential (“domain1\administrator”, $pass)

New-NetIPAddress -IPAddress 10.0.1.20 -InterfaceAlias Ethernet -DefaultGateway 10.0.1.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet” -ServerAddresses 10.0.1.10
Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6

Add-Computer -domainname Domain1.local -Credential $cred -NewName Member -Restart

Add-WindowsFeature adcs-cert-authority -IncludeManagementTools
Install-AdcsCertificationAuthority -AllowAdministratorInteraction:$true -CAType EnterpriseRootCa -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits 3



#

#endregion

#region: Router

<#

#############################################################################
######################### Opsætning for Router ##############################
#############################################################################

Install-WindowsFeature Routing -IncludeManagementTools

######################## Tålmodighed er en dyd ##############################

Install-RemoteAccess -VpnType Vpn

########### UDFYLD HVILKEN ADAPTER DER GÅR TIL HVAD NEDENFOR ################

$intdom1 = "Ethernet 3"
$intdom2 = "Ethernet"
$intext = "Ethernet 2"



New-NetIPAddress -IPAddress 10.0.1.1 -InterfaceAlias $intdom1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias $intdom1 -ServerAddresses 10.0.1.10
New-NetIPAddress -IPAddress 10.0.2.1 -InterfaceAlias $intdom2 -PrefixLength 24 
Set-DnsClientServerAddress -InterfaceAlias $intdom2 -ServerAddresses 10.0.2.10 

####################### KØR FØLGENDE I CMD ##################################

netsh routing ip nat install
netsh routing ip nat add interface "Ethernet 2"
netsh routing ip nat set interface "Ethernet 2" mode=full
netsh routing ip nat add interface "Ethernet 3"
netsh routing ip nat add interface "Ethernet"

#>

#endregion

#region: Klient 1

<#

#############################################################################
######################## Opsætning for Klient 1 #############################
#############################################################################

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential (“domain1\administrator”, $pass)

New-NetIPAddress -IPAddress 10.0.1.11 -InterfaceAlias "Ethernet 2" -DefaultGateway 10.0.1.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet 2” -ServerAddresses 10.0.1.10
Disable-NetAdapterBinding -InterfaceAlias "Ethernet 2" -ComponentID ms_tcpip6

Add-Computer -domainname Domain1.local -Credential $cred -NewName Klient1 -Restart

#>

#endregion

#region: Klient 2

<#

#############################################################################
######################## Opsætning for Klient 2 #############################
#############################################################################

$Pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential (“Domain2\administrator”, $pass)

New-NetIPAddress -IPAddress 10.0.2.11 -InterfaceAlias "Ethernet 2" -DefaultGateway 10.0.2.1 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias “Ethernet 2” -ServerAddresses 10.0.2.10
Disable-NetAdapterBinding -InterfaceAlias "Ethernet 2" -ComponentID ms_tcpip6

Add-Computer -domainname Domain2.local -Credential $cred -NewName Klient2 -Restart

#>

#endregion


#endregion