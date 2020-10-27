#Opret OU til firmaet
New-ADOrganizationalUnit -Name "Company" -Path "DC=Domain1,DC=local"

#Oprettelse af 4 forskellige OU'er på Domain1
New-ADOrganizationalUnit -Name "Kundeservice" -Path "OU=Company,DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "Administration" -Path "OU=Company,DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "IT" -Path "OU=Company,DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "Produktion" -Path "OU=Company,DC=Domain1,DC=local"

#Oprettelse af brugere samt simpel info
New-ADUser -Name "Peter Produktion" -UserPrincipalName "pp@domain1.local" -DisplayName "PP" -EmailAddress "PP@Domain1.local" -ChangePasswordAtLogon 1 `
-Initials "PP" -Path "OU=Produktion,OU=Company,DC=domain1,DC=local" -AccountPassword (ConvertTo-SecureString "Start2020" -AsPlainText -Force) -enabled 1

New-ADUser -Name "Iben IT" -DisplayName "II" -EmailAddress "II@Domain1.local" -ChangePasswordAtLogon $true
-Initials "II" -Path "OU=IT,OU=Company,DC=domain1,DC=local" -AccountPassword "Start2020"

New-ADUser -Name "Anne Administration" -DisplayName "AA" -EmailAddress "AA@Domain1.local" -ChangePasswordAtLogon $true
-Initials "AA" -Path "OU=Administration,OU=Company,DC=domain1,DC=local" -AccountPassword "Start2020"

New-ADUser -Name "Kasper Kundeservice" -DisplayName "KK" -EmailAddress "KK@Domain1.local" -ChangePasswordAtLogon $true
-Initials "KK" -Path "OU=Kundeservice,OU=Company,DC=domain1,DC=local" -AccountPassword "Start2020"