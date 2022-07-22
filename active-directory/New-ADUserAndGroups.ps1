function New-ADUserAndGroups {
  <#
.SYNOPSIS
  A function for creating a user account in Active Directory and then adding to security groups.
.DESCRIPTION
  A function for creating a user account in Active Directory and then adding to security groups. -userDetails requires an object containg the properties for the user (Name at a minimum). Optionally, you can add the user to security groups by providing an array to -securityGroups.
.EXAMPLE
  $userObject = @{ 
    "Name" = "jsmith"
    "GivenName" = "John"
    "Surname" = "Smith"
    "Office" = "London"
    "Title" = "Sales"
    "Department" = "Finance"
  }
  $groups = @("Finance", "Printers")
  New-ADUserAndGroups -userDetails $userObject -userGroups $groups
#>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [System.Object]
    $userDetails,

    [Parameter()]
    [array]
    $securityGroups
  )

  # Create user
  New-ADUser @$userDetails
  # Verify
  Try {
    Get-ADUser -Identity $userDetails.Name | Out-Null
  }
  Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    Throw "Failed to create user in Active Directory"
  }

  # Add user to security groups
  If ($securityGroups) {
    ForEach ($group in $securityGroups) {
      Add-ADGroupMember -Identity $group -Members "$($userDetails.Name)"
    }
  }
  # Verify
  $verify = @()
  $userGroupMembership = (Get-ADPrincipalGroupMembership $userDetails.Name).Name
  ForEach ($group in $securityGroups) {
    $verify = $verify + ($userGroupMembership -contains $group)
  }
  If ($verify -contains $false) {
    Throw "Failed to add user to security groups"

  }

}