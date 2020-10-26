#region: Router

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

#endregion