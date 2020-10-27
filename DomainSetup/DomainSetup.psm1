function Install-VirtualEnvironment {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        $InstallPath='D:\Hyper-V\',
        [ValidateNotNullOrEmpty()]
        $vhdxSourcePath='D:\Hyper-v skabeloner\',
        [bool]$StartVMs=$true
    )
    
    begin {

        #region Preparation
            $vmServerNames = "Server1","Server2","Router","Member"
            $vmClientNames = "Klient1","Klient2"
            $vmNames = $vmServerNames + $vmClientNames
            Write-Verbose "Preparing VM Setup"
                
        #endregion
    }
    process{

        try {
            #region Configure VM's
            
            # Creating Virtual Switches
            New-VMSwitch -Name Domain1 -SwitchType Private
            New-VMSwitch -Name Domain2 -SwitchType Private
            New-VMSwitch -Name External -NetAdapterName Ethernet

            # Setting up every VM
            foreach ($name in $vmNames) {
                # Creating directory
                New-Item -Path $InstallPath -ItemType Directory -Name $name -Force

                $tempVHDXPath = ($InstallPath + $name + "\" + $name + ".vhdx")
                $tempVMPath = $InstallPath + $name

                if ($vmServerNames.Contains($name)) { # If Server
                    New-VHD -Differencing -ParentPath ($vhdxSourcePath + 'Server2019Temp.vhdx') -Path $tempVHDXPath
                }elseif ($vmClientNames.Contains($name)) { # If Client
                    New-VHD -Differencing -ParentPath ($vhdxSourcePath + 'Win10Temp.vhdx') -Path ($installPath + $name + "\" + $name + ".vhdx")
                }
                
                New-VM -Name $name -MemoryStartupBytes 2048MB -VHDPath $tempVHDXPath -Path $tempVMPath -Generation 1
            }

            # Assigning Network Adapters
                # Server 1
                Add-VMNetworkAdapter -VMName 'Server1' -SwitchName Domain1 -Name Privat
                Remove-VMNetworkAdapter -VMName 'Server1' -Name 'Network Adapter'

                # Server 2
                Add-VMNetworkAdapter -VMName 'Server2' -SwitchName Domain2 -Name Privat
                Remove-VMNetworkAdapter -VMName 'Server2' -Name 'Network Adapter'

                # Member
                Add-VMNetworkAdapter -VMName 'Member' -SwitchName Domain1 -Name Privat
                Remove-VMNetworkAdapter -VMName 'Member' -Name 'Network Adapter'

                # Router
                Add-VMNetworkAdapter -VMName 'Router' -SwitchName External -Name Extern
                Add-VMNetworkAdapter -VMName 'Router' -SwitchName Domain1 -Name Privat1
                Add-VMNetworkAdapter -VMName 'Router' -SwitchName Domain2 -Name Privat2
                Remove-VMNetworkAdapter -VMName 'Router' -Name 'Network Adapter'

                # Klient 1
                Add-VMNetworkAdapter -VMName 'Klient1' -SwitchName Domain1 -Name Privatnet
                Remove-VMNetworkAdapter -VMName 'Klient1' -Name 'Network Adapter'

                # Klient 2
                Add-VMNetworkAdapter -VMName 'Klient2' -SwitchName Domain2 -Name Privatnet
                Remove-VMNetworkAdapter -VMName 'Klient2' -Name 'Network Adapter'

            

        #endregion
        
        }
        catch {
            Write-Error $_
        }
        
    }
    end{

        
        Write-Verbose "VM's Successfully Configured"
        # If parameter $startVMs is set to true
        if ($startVMs = $true) {
        Get-VM | Start-VM
        Write-Verbose "Starting VM's"
        }

    }
}