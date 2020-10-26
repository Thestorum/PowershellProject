#region: Opsætningsoverblik

<#
#############################################################################
###########################  NETVÆRKSOVERBLIK  ##############################
#############################################################################
#                                    |
#            10.0.1.0 /24            |           10.0.2.0 /24
#                                    |
#                                    |
#                                    |
#     SERVER1 (DC)      MEMBER       |    SERVER2 (DC)
#     Domain1.local  Domain1.local   |    Domain2.local
#       ╔╦═══╗          ╔╦═══╗       |       ╔╦═══╗          
#       ║╠═══╣          ║╠═══╣       |       ║╠═══╣          
#       ╚╩╦══╝          ╚╩╦══╝       |       ╚╩══╦╝          
#         ║ 0.1      0.2  ║          |    1.1    ║              
#         ║   ╔═══════╗   ║        ROUTER        ║ ╔═══════╗    
#         ║   ║ VM_SW ╠═══╝       No domain      ╚═╣ VM_SW ║   
#         ╚═══╣DOMAIN1╠═════╗      ╔╦═══╗      ╔═══╣DOMAIN2║
#             ╚═══╦═══╝     ╚══════╣║   ╠══════╝   ╚═══╦═══╝
#                 ║            0.3 ╚╩╦══╝ 1.3          ║
#                ╔╩╗ 0.11            ║                ╔╩╗ 1.11
#           ╔═══╗║ ║                 ║           ╔═══╗║ ║
#           ╚═╦═╝║ ║                 ║           ╚═╦═╝║ ║
#            ═╩═ ╚═╝                 ║            ═╩═ ╚═╝
#           KLIENT 1                 ║           KLIENT 2
#         Domain1.local              ║         Domain2.local
#------------------------------------║--------------------------------------
#                             ╔══════╩═════╗
#                             ║Eksternt NET║
#                             ╚════════════╝
#                                    
#############################################################################
##################SÆTTER DE VIRTUELLE MASKINERS STIER OP#####################
#############################################################################
#>

#endregion

#region: opsætning af VM'er
New-Item -Path 'D:\hyper-v\' -ItemType Directory -Name Klient1 -Force
New-Item -Path 'D:\hyper-v\' -ItemType Directory -Name Klient2 -Force
New-Item -Path 'D:\hyper-v\' -ItemType Directory -Name Server1 -Force
New-Item -Path 'D:\hyper-v\' -ItemType Directory -Name Server2 -Force
New-Item -Path 'D:\hyper-v\' -ItemType Directory -Name Router -Force
New-Item -Path 'D:\hyper-v\' -ItemType Directory -Name Member -Force

#############################################################################
######################SÆTTER DE VIRTUELLE SWITCHE OP#########################
#############################################################################

New-VMSwitch -Name Domain1 -SwitchType Private
New-VMSwitch -Name Domain2 -SwitchType Private
New-VMSwitch -Name External -NetAdapterName Ethernet

#############################################################################
###############SÆTTER DE VIRTUELLE MASKINERS PARENTPATHS OP##################
#############################################################################

New-VHd -Differencing -ParentPath 'D:\Hyper-v skabeloner\Server2019Temp.vhdx' -Path D:\Hyper-v\Server1\Server1.vhdx
New-VHd -Differencing -ParentPath 'D:\Hyper-v skabeloner\Server2019Temp.vhdx' -Path D:\Hyper-v\Server2\Server2.vhdx
New-VHd -Differencing -ParentPath 'D:\Hyper-v skabeloner\Server2019Temp.vhdx' -Path D:\Hyper-v\Member\Member.vhdx
New-VHd -Differencing -ParentPath 'D:\Hyper-v skabeloner\Server2019Temp.vhdx' -Path D:\Hyper-v\Router\Router.vhdx
New-VHd -Differencing -ParentPath 'D:\Hyper-v skabeloner\Win10Temp.vhdx' -Path D:\Hyper-v\Klient1\Klient1.vhdx
New-VHd -Differencing -ParentPath 'D:\Hyper-v skabeloner\Win10Temp.vhdx' -Path D:\Hyper-v\Klient2\Klient2.vhdx

#############################################################################
######################OPRETTER DE VIRTUELLE MASKINER#########################
#############################################################################

New-VM -Name 'Server 1' -MemoryStartupBytes 2048MB -VHDPath 'D:\Hyper-v\Server1\Server1.vhdx' -Path 'D:\Hyper-v\Server1' -Generation 1
New-VM -Name 'Server 2' -MemoryStartupBytes 2048MB -VHDPath 'D:\Hyper-v\Server2\Server2.vhdx' -Path 'D:\Hyper-v\Server2' -Generation 1
New-VM -Name 'Member' -MemoryStartupBytes 2048MB -VHDPath 'D:\Hyper-v\Member\Member.vhdx' -Path 'D:\Hyper-v\Member' -Generation 1
New-VM -Name 'Router' -MemoryStartupBytes 2048MB -VHDPath 'D:\Hyper-v\Router\Router.vhdx' -Path 'D:\Hyper-v\Router' -Generation 1
New-VM -Name 'Klient 1' -MemoryStartupBytes 2048MB -VHDPath 'D:\Hyper-v\Klient1\Klient1.vhdx' -Path 'D:\Hyper-v\Klient1' -Generation 1
New-VM -Name 'Klient 2' -MemoryStartupBytes 2048MB -VHDPath 'D:\Hyper-v\Klient2\Klient2.vhdx' -Path 'D:\Hyper-v\Klient2' -Generation 1

#############################################################################
################RETTER DE VIRTUELLE MASKINERS NETVÆRKSKORT###################
#############################################################################


#############################################################################
##############################  SERVER 1  ###################################
#############################################################################

Add-VMNetworkAdapter -VMName 'Server 1' -SwitchName Domain1 -Name Privat
Remove-VMNetworkAdapter -VMName 'Server 1' -Name 'Network Adapter'

#############################################################################
##############################  SERVER 2  ###################################
#############################################################################

Add-VMNetworkAdapter -VMName 'Server 2' -SwitchName Domain2 -Name Privat
Remove-VMNetworkAdapter -VMName 'Server 2' -Name 'Network Adapter'

#############################################################################
############################  MEMBER SERVER  ################################
#############################################################################

Add-VMNetworkAdapter -VMName 'Member' -SwitchName Domain1 -Name Privat
Remove-VMNetworkAdapter -VMName 'Member' -Name 'Network Adapter'

#############################################################################
################################  ROUTER  ###################################
#############################################################################

Add-VMNetworkAdapter -VMName 'Router' -SwitchName External -Name Extern
Add-VMNetworkAdapter -VMName 'Router' -SwitchName Domain1 -Name Privat1
Add-VMNetworkAdapter -VMName 'Router' -SwitchName Domain2 -Name Privat2
Remove-VMNetworkAdapter -VMName 'Router' -Name 'Network Adapter'

#############################################################################
###############################  KLIENT 1  ##################################
#############################################################################

Add-VMNetworkAdapter -VMName 'Klient 1' -SwitchName Domain1 -Name Privatnet
Remove-VMNetworkAdapter -VMName 'Klient 1' -Name 'Network Adapter'

#############################################################################
###############################  KLIENT 2  ##################################
#############################################################################

Add-VMNetworkAdapter -VMName 'Klient 2' -SwitchName Domain2 -Name Privatnet
Remove-VMNetworkAdapter -VMName 'Klient 2' -Name 'Network Adapter'

#############################################################################
###############################  Start vm  ##################################
#############################################################################

Get-VM | Start-VM

#endregion