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

    }
    
    process {
        try {

            #region: Server1
            $vmName = "Server1"
            while ((Invoke-Command -VMName $vmName -Credential $credServer -ScriptBlock{"Test"} -ErrorAction SilentlyContinue) -ne "Test") {
                Start-Sleep -Seconds 2
                Write-Output "$vmName is currently booting"
            }
            Invoke-Command -VMName $vmName -Credential $credServer -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.1.10 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.1.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename PC
                Rename-Computer -NewName $vmName -Force -Restart
            }

            while ((Invoke-Command -VMName $vmName -Credential $credServer -ScriptBlock{"Test"} -ErrorAction SilentlyContinue) -ne "Test") {
                Start-Sleep -Seconds 2
                Write-Output "$vmName is currently rebooting"
            }

            Invoke-Command -VMName $vmName -Credential $credServer -ScriptBlock {
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

            Invoke-Command -VMName $vmName -Credential $credDomain1 -ScriptBlock {
                # Adds Conditional Forwarder for domain2
                Add-DnsServerConditionalForwarderZone -Name Domain2.local -MasterServers 10.0.2.10
            }
            $vmName = $null

            #endregion
            #region: Klient1

            $vmName = "Klient1"
            while ((Invoke-Command -VMName $vmName -Credential $credClient -ScriptBlock{"Test"} -ErrorAction SilentlyContinue) -ne "Test") {
                Start-Sleep -Seconds 2
                Write-Output "$vmName is rebooting"
            }
            Invoke-Command -VMName $vmName -Credential $credClient -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.1.11 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.1.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.1.10 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename and Join PC to Domain
                Add-Computer -domainname Domain1.local -Credential $credDomain1 -NewName Klient1 -Restart
            }
            
            #endregion

        }
        catch {
            
        }
    }
    end {
        
    }
}