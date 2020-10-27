function Install-VMRoles {
    [CmdletBinding()]
    param (
        
    )
    
    begin {

        # Client VM Session Initialization
        $pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
        $credClient = New-Object System.Management.Automation.PSCredential (“Egon”, $pass)
        $s_Klient1,$s_Klient2 = New-PSSession -VMName Klient1,Klient2 -Credential $credClient
        
        # Server VM Session Initialization
        $credServer = New-Object System.Management.Automation.PSCredential (“Administrator”, $pass)
        $s_Member, $s_Router, $s_Server1, $s_Server2 = New-PSSession -VMName Member,Router,Server1,Server2 -Credential $credServer

        # Domain Credentials
        $credDomain1 = New-Object System.Management.Automation.PSCredential (“Domain1\Administrator”, $pass)
        $credDomain2 = New-Object System.Management.Automation.PSCredential (“Domain2\Administrator”, $pass)

    }
    
    process {
        try {

            #region: Server1
            while ((Invoke-Command -Session $s_Server1 -ScriptBlock{"Test"}) -ne Test) {
                Start-Sleep -Seconds 2
            }
            Invoke-Command -Session $s_Server1 -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.1.10 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.1.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename PC
                Rename-Computer -NewName "Server1" -Force -Restart
            }

            while ((Invoke-Command -Session $s_Server1 -ScriptBlock{"Test"}) -ne Test) {
                Start-Sleep -Seconds 2
            }

            Invoke-Command -Session $s_Server1 -ScriptBlock {
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

            #endregion
            #region: Klient1
            while ((Invoke-Command -Session $s_Klient1 -ScriptBlock{"Test"}) -ne "Test") {
                Start-Sleep -Seconds 2
                Write-Output "Still Rebooting"
            }
            Invoke-Command -Session $s_Klient1 -ScriptBlock {
                # IP Configuration
                New-NetIPAddress -IPAddress 10.0.1.11 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.1.1 -PrefixLength 24 | Out-Null
                Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.1.10 | Out-Null
                Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 | Out-Null
                
                # Rename and Join PC to Domain
                Add-Computer -domainname Domain1.local -Credential $credServer -NewName Klient1 -Restart
            }
            
            #endregion

        }
        catch {
            
        }
    }
    end {
        
    }
}