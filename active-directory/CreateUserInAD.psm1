function CreateUserInAD {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [Object]
    $UserDetails,
    [Parameter(Mandatory)]
    [String]
    $ActiveDirectoryServer,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to Active Directory
  Try {
    $SessionToActiveDirectory = New-PSSession -ComputerName $ActiveDirectoryServer -Credential $Credential
  }
  Catch {
    Try {
      $SessionToActiveDirectory = New-PSSession -ComputerName $ActiveDirectoryServer -Credential $Credential
    }
    Catch {
      Write-Error "Unable to establish connection to Active Directory"
      Return
    }
  }

  # Create the user
  Invoke-Command -Session $SessionToActiveDirectory {
    Try {
      $parameters = $using:UserDetails
      New-ADUser @parameters
    }
    Catch {
      Write-Error "Failed to create user in Active Directory"
    }
  }

  # Disconnect from Active Directory
  Remove-PSSession $SessionToActiveDirectory

}

function Test-CreateUserInAD {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $Username,
    [Parameter(Mandatory)]
    [String]
    $ActiveDirectoryServer,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to Active Directory
  Try {
    $SessionToActiveDirectory = New-PSSession -ComputerName $ActiveDirectoryServer -Credential $Credential
  }
  Catch {
    Try {
      $SessionToActiveDirectory = New-PSSession -ComputerName $ActiveDirectoryServer -Credential $Credential
    }
    Catch {
      Write-Error "Unable to establish connection to Active Directory"
      Return
    }
  }
  
  #Verify
  $Result = Invoke-Command -Session $SessionToActiveDirectory {
    Try {
      $User = Get-ADUser -Identity $using:Username | Out-Null

      return $true
    }
    Catch {
      Return $false
    }
  }

  # Disconnect from Active Directory
  Remove-PSSession $SessionToActiveDirectory

  # Return result
  Return $result
  
}