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
            New-VMSwitch -Name Domain1 -SwitchType Private| Out-Null
            New-VMSwitch -Name Domain2 -SwitchType Private| Out-Null
            New-VMSwitch -Name External -NetAdapterName Ethernet| Out-Null

            # Setting up every VM
            foreach ($name in $vmNames) {
                # Creating directory
                New-Item -Path $InstallPath -ItemType Directory -Name $name -Force | Out-Null

                $tempVHDXPath = ($InstallPath + $name + "\" + $name + ".vhdx")
                $tempVMPath = $InstallPath + $name

                if ($vmServerNames.Contains($name)) { # If Server
                    New-VHD -Differencing -ParentPath ($vhdxSourcePath + 'Server2016GUITemp_Unattended.vhdx') -Path $tempVHDXPath | Out-Null
                }elseif ($vmClientNames.Contains($name)) { # If Client
                    New-VHD -Differencing -ParentPath ($vhdxSourcePath + 'Win10Temp_Unattended.vhdx') -Path ($installPath + $name + "\" + $name + ".vhdx") | Out-Null
                }
                
                New-VM -Name $name -MemoryStartupBytes 2048MB -VHDPath $tempVHDXPath -Path $tempVMPath -Generation 1 | Out-Null
            }

            # Assigning Network Adapters
                # Server 1
                Add-VMNetworkAdapter -VMName 'Server1' -SwitchName Domain1 -Name Privat | Out-Null
                Remove-VMNetworkAdapter -VMName 'Server1' -Name 'Network Adapter' | Out-Null

                # Server 2
                Add-VMNetworkAdapter -VMName 'Server2' -SwitchName Domain2 -Name Privat | Out-Null
                Remove-VMNetworkAdapter -VMName 'Server2' -Name 'Network Adapter' | Out-Null

                # Member
                Add-VMNetworkAdapter -VMName 'Member' -SwitchName Domain1 -Name Privat | Out-Null
                Remove-VMNetworkAdapter -VMName 'Member' -Name 'Network Adapter' | Out-Null

                # Router
                Add-VMNetworkAdapter -VMName 'Router' -SwitchName External -Name Extern | Out-Null
                Add-VMNetworkAdapter -VMName 'Router' -SwitchName Domain1 -Name Privat1 | Out-Null
                Add-VMNetworkAdapter -VMName 'Router' -SwitchName Domain2 -Name Privat2 | Out-Null
                Remove-VMNetworkAdapter -VMName 'Router' -Name 'Network Adapter' | Out-Null

                # Klient 1
                Add-VMNetworkAdapter -VMName 'Klient1' -SwitchName Domain1 -Name Privatnet | Out-Null
                Remove-VMNetworkAdapter -VMName 'Klient1' -Name 'Network Adapter' | Out-Null

                # Klient 2
                Add-VMNetworkAdapter -VMName 'Klient2' -SwitchName Domain2 -Name Privatnet | Out-Null
                Remove-VMNetworkAdapter -VMName 'Klient2' -Name 'Network Adapter' | Out-Null

            

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