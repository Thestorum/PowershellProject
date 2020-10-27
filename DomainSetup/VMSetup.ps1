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

    }
    
    process {
        

        #region: Klient 1

        

        New-NetIPAddress -IPAddress 10.0.1.11 -InterfaceAlias "Ethernet 2" -DefaultGateway 10.0.1.1 -PrefixLength 24
        Set-DnsClientServerAddress -InterfaceAlias “Ethernet 2” -ServerAddresses 10.0.1.10
        Disable-NetAdapterBinding -InterfaceAlias "Ethernet 2" -ComponentID ms_tcpip6

        Add-Computer -domainname Domain1.local -Credential $cred -NewName Klient1 -Restart

        #endregion

        #region PS REMOTE
        Enable-PSRemoting -Force
        #endregion




    }
    
    end {
        
    }
}