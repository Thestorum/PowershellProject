function Invoke-CommandWithPSDirect{
    Param(
        [Parameter(Mandatory=$true)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]
        $VirtualMachine,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        $Credential,
        
        [Parameter(Mandatory=$true)]
        [ScriptBlock]
        $ScriptBlock,

        [Object[]]
        $ArgumentList
    )
    # Verifies that the machine is running, and start it if it's not already
    If ($VirtualMachine.State -eq "Off"){
        Start-VM $VirtualMachine -ErrorAction Stop | Out-Null
    }
    
    # Checks for Hyper-V Heartbeats
    $heartbeat = (Get-VMIntegrationService -VM $VirtualMachine | Where-Object Id -match "84EAAE65-2F2E-45F5-9BB5-0E857DC8EB47")
    If ($heartbeat -and ($heartbeat.Enabled -eq $true)) 
    {
        $startTime = Get-Date
        do 
        {
            $timeElapsed = $(Get-Date) - $startTime
            if ($($timeElapsed).TotalMinutes -ge 10){
                Write-Error "Did not receive any heatbeats from $($VirtualMachine.VMName) for 10 minutes"  
                throw
            } 
            Start-Sleep -sec 1
        } 
        until ($heartbeat.PrimaryStatusDescription -eq "OK")
    }

    # Checks PS Direct availability
    $startTime = Get-Date
    do 
    {
        $timeElapsed = $(Get-Date) - $startTime
        if ($($timeElapsed).TotalMinutes -ge 10)
        {
            Write-Error -Message "Could not connect to PS Direct after 10 minutes"
            throw
        } 
        Start-Sleep -sec 1
        $psReady = Invoke-Command -VMId $VirtualMachine.VMId -Credential $Credential -ScriptBlock { $True } -ErrorAction SilentlyContinue
    } 
    until ($psReady)
    
    # Runs the actual ScriptBlock (With or without arguments)
    Write-Verbose "Running Script Block"
    If ($ArgumentList)
    {
        Invoke-Command -VMId $VirtualMachine.VMId -Credential $Credential -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList -ErrorAction SilentlyContinue    
    }
    else 
    {
        Invoke-Command -VMId $VirtualMachine.VMId -Credential $Credential -ScriptBlock $ScriptBlock -ErrorAction SilentlyContinue    
    }
}

function Wait-ActiveDirectory {
    Param(
        [Parameter(Mandatory=$true)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]
        $VirtualMachine,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        $Credential
    )
    Write-Verbose "Waiting for AD to be up and running"
    Invoke-CommandWithPSDirect -VirtualMachine $VirtualMachine -Credential $Credential -ScriptBlock {
        do {
            Write-Host "." -NoNewline -ForegroundColor Gray
            Start-Sleep -Seconds 5
            Get-ADComputer $env:COMPUTERNAME | Out-Null
        } until ($?)
        Write-Host "done."
    }
}


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


function Install-VMRoles {
    [CmdletBinding()]
    param (
        
    )
    
    begin {

        $pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force

        # Client VM Credentials
        $credClient = New-Object System.Management.Automation.PSCredential (“Egon”, $pass)
        
        # Server VM Credentials
        $credServer = New-Object System.Management.Automation.PSCredential (“Administrator”, $pass)

        # Domain Credentials
        $credDomain1 = New-Object System.Management.Automation.PSCredential (“Domain1\Administrator”, $pass)
        $credDomain2 = New-Object System.Management.Automation.PSCredential (“Domain2\Administrator”, $pass)

        Write-Verbose "Credentials Defined"
    }
    
    process {
        try {

            #region: Server1
            $vmName = "Server1"
            $VM = (Get-VM -Name $vmName)
            Write-Verbose "Starting configuration of $vmName"

            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credServer -ArgumentList $vmName -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.1.10 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.1.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename PC
                Rename-Computer -NewName $args[0] -Force -Restart
            }

            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credServer -ScriptBlock {
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
            }
            # Resumes when domain is reachable again
            Start-Sleep -Seconds 30
            Wait-ActiveDirectory

            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credDomain1 -ScriptBlock {
                # Adds Conditional Forwarder for domain2
                Add-DnsServerConditionalForwarderZone -Name Domain2.local -MasterServers 10.0.2.10
            }
            $vmName = $null
            $VM = $null
            #endregion

            #region: Server2
            $vmName = "Server2"
            $VM = (Get-VM -Name $vmName)
            Write-Verbose "Starting configuration of $vmName"

            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credServer -ArgumentList $vmName -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.2.10 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.2.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename PC
                Rename-Computer -NewName $args[0] -Force -Restart
            }

            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credServer -ScriptBlock {
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
            }
            # Resumes when domain is reachable again
            Start-Sleep -Seconds 30
            Wait-ActiveDirectory

            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credDomain2 -ScriptBlock {
                # Adds Conditional Forwarder for domain2
                Add-DnsServerConditionalForwarderZone -Name Domain2.local -MasterServers 10.0.1.10
            }
            $vmName = $null
            $VM = $null
            #endregion

            #region: Klient1

            $vmName = "Klient1"
            $VM = (Get-VM -Name $vmName)
            Write-Verbose "Starting configuration of $vmName"
            
            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credClient -ArgumentList $credDomain1,$vmName -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.1.11 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.1.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.1.10 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename and Join PC to Domain
                Add-Computer -domainname Domain1.local -Credential $args[0] -NewName $args[1] -Restart
            }
            
            #endregion

            #region: Klient2

            $vmName = "Klient2"
            $VM = (Get-VM -Name $vmName)
            Write-Verbose "Starting configuration of $vmName"
            
            Invoke-CommandWithPSDirect -VirtualMachine $VM -Credential $credClient -ArgumentList $credDomain1,$vmName -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.2.11 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.2.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.2.10 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename and Join PC to Domain
                Add-Computer -domainname domain2.local -Credential $args[0] -NewName $args[1] -Restart
            }
            
            #endregion

        }
        catch {
            
        }
    }
    end {
        
    }
}