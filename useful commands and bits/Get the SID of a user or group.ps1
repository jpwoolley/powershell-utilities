# Get a SID of user or group

# Get a user's SID
Get-ADUser -Identity $username | Select-Object SID

# Get a group's SID
Get-ADGroup -Filter {Name -like "fr-sales-*"} | Select SID

# Get a user by their SID
Get-ADUser -Filter * | Select-Object SamAccountName,@{name="Name";expression={"$($_.GivenName) $($_.Surname)"}},SID | Where-Object {$_.SID -eq $sid}

# Get a group by its SID
Get-ADGroup -Filter * | Select-Object SamAccountName,SID | Where-Object {$_.SID -eq $sid}
