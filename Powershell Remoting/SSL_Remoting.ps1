#Certifikat laves og exporteres fra klient2 til klient1
$cert = New-SelfSignedCertificate -DnsName Klient2.domain2.local -CertStoreLocation Cert:\LocalMachine\My
Export-Certificate -Cert $cert -FilePath C:/Test.cer

#Certifikat laves og exporteres fra klient1 til klient2
$cert = New-SelfSignedCertificate -DnsName Klient1.domain1.local -CertStoreLocation Cert:\LocalMachine\My
Export-Certificate -Cert $cert -FilePath C:/Test.cer

winrm create winrm/config/listener?Address=*+Transport=HTTPS @{Hostname="<Hostname>";CertificateThumbprint="<Thumbprint>"}