#Copy af script til $profile for IT
New-Item -ItemType File -Path $Profile -Force
Copy-Item -Path \\server1\netlogon\Profile_Script_IT.ps1 -Destination $Profile -Recurse

#Copy af script til $profile for resten i company
New-Item -ItemType File -Path $Profile -Force
Copy-Item -Path \\server1\netlogon\Profile_Script.ps1 -Destination $Profile -Recurse