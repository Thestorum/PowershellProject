#Opret OU til firmaet
New-ADOrganizationalUnit -Name "Company" -Path "DC=Domain1,DC=local"

#Oprettelse af 4 forskellige OU'er på Domain1
New-ADOrganizationalUnit -Name "Kundeservice" -Path "OU=Company,DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "Administration" -Path "OU=Company,DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "IT" -Path "OU=Company,DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "Produktion" -Path "OU=Company,DC=Domain1,DC=local"

#Oprettelse af brugere samt simpel info
New-ADUser -Name "Peter Produktion" -SamAccountName "PP" -UserPrincipalName "pp@domain1.local" -DisplayName "Peter Produktion" -EmailAddress "PP@Domain1.local" -ChangePasswordAtLogon 1 `
-Initials "PP" -Path "OU=Produktion,OU=Company,DC=domain1,DC=local" -AccountPassword (ConvertTo-SecureString "Start2020" -AsPlainText -Force) -enabled 1

New-ADUser -Name "Iben IT" -SamAccountName "II" -UserPrincipalName "II@domain1.local" -DisplayName "Iben IT" -EmailAddress "II@Domain1.local" -ChangePasswordAtLogon 1 `
-Initials "II" -Path "OU=IT,OU=Company,DC=domain1,DC=local" -AccountPassword (ConvertTo-SecureString "Start2020" -AsPlainText -Force) -enabled 1

New-ADUser -Name "Anne Administration" -SamAccountName "AA" -UserPrincipalName "AA@domain1.local" -DisplayName "Anne Administration" -EmailAddress "AA@Domain1.local" -ChangePasswordAtLogon 1 `
-Initials "AA" -Path "OU=Administration,OU=Company,DC=domain1,DC=local" -AccountPassword (ConvertTo-SecureString "Start2020" -AsPlainText -Force) -enabled 1

New-ADUser -Name "Kasper Kundeservice" -SamAccountName "KK" -UserPrincipalName "KK@domain1.local" -DisplayName "Kasper Kundeservice" -EmailAddress "KK@Domain1.local" -ChangePasswordAtLogon 1 `
-Initials "KK" -Path "OU=Kundeservice,OU=Company,DC=domain1,DC=local" -AccountPassword (ConvertTo-SecureString "Start2020" -AsPlainText -Force) -enabled 1