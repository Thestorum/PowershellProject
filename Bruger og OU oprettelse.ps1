#Opret OU til firmaet
New-ADOrganizationalUnit -Name "Company" -Path "DC=Domain1,DC=local"

#Oprettelse af 4 forskellige OU'er på Domain1
New-ADOrganizationalUnit -Name "Kundeservice" -Path "DC=Domain1,DC=local,OU=Company"

New-ADOrganizationalUnit -Name "Administration" -Path "DC=Domain1,DC=local,OU=Company"

New-ADOrganizationalUnit -Name "IT" -Path "DC=Domain1,DC=local,OU=Company"

New-ADOrganizationalUnit -Name "Produktion" -Path "DC=Domain1,DC=local,OU=Company"

#Oprettelse af brugere samt simpel info
New-ADUser -Name "Peter Produktion" -DisplayName "PP" -EmailAddress "PP@Domain1.local" -ChangePasswordAtLogon $true
-Initials "PP" -Path "DC=domain1,DC=local,OU=Company,OU=Produktion" -AccountPassword "Start2020"

New-ADUser -Name "Iben IT" -DisplayName "II" -EmailAddress "II@Domain1.local" -ChangePasswordAtLogon $true
-Initials "II" -Path "DC=domain1,DC=local,OU=Company,OU=IT" -AccountPassword "Start2020"

New-ADUser -Name "Anne Administration" -DisplayName "AA" -EmailAddress "AA@Domain1.local" -ChangePasswordAtLogon $true
-Initials "AA" -Path "DC=domain1,DC=local,OU=Company,OU=Administration" -AccountPassword "Start2020"

New-ADUser -Name "Kasper Kundeservice" -DisplayName "KK" -EmailAddress "KK@Domain1.local" -ChangePasswordAtLogon $true
-Initials "KK" -Path "DC=domain1,DC=local,OU=Company,OU=Kundeservice" -AccountPassword "Start2020"