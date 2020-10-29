Install-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools -Restart
Install-PswaWebApplication -UseTestCertificate
Add-PswaAuthorizationRule -ComputerName server1.domain1.local -RuleName test -UserName Domain1\ii -ConfigurationName microsoft.powershell