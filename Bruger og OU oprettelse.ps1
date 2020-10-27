#Oprettelse af 4 forskellige OU'er på Domain1
New-ADOrganizationalUnit -Name "Kundeservice" -Path "DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "Administration" -Path "DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "IT" -Path "DC=Domain1,DC=local"

New-ADOrganizationalUnit -Name "Produktion" -Path "DC=Domain1,DC=local"