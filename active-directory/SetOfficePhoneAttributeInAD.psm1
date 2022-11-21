function SetOfficePhoneAttributeInAD {
  
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $User,
    [Parameter(Mandatory)]
    [String]
    $PhoneNumber,
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

  # Action
  Invoke-Command -Session $SessionToActiveDirectory {

    # Having this value set will cause this action to fail
    If ( (Get-Aduser -Identity $Using:User -Properties msRTCSIP-DeploymentLocator).'msRTCSIP-DeploymentLocator' -eq "SRV:" ) {
      Try {
        Set-ADUser -Identity $Using:User -Clear msRTCSIP-DeploymentLocator
      }
      Catch {
        Write-Error "Could not clear msRTCSIP-DeploymentLocator attribute in AD"
        Return
      }
    }

    # Set OfficePhone attribute
    Try {
      Set-ADUser -Identity $Using:User -OfficePhone $Using:PhoneNumber
    }
    Catch {
      Write-Error "Could not set OfficePhone attribute in AD"
    }

  }

  # Disconnect from Active Directory
  Remove-PSSession $SessionToActiveDirectory

}

function Test-SetOfficePhoneAttributeInAD {
  
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $User,
    [Parameter(Mandatory)]
    [String]
    $PhoneNumber,
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
  
  # Verify
  $Result = Invoke-Command -Session $SessionToActiveDirectory {
    # Get OfficePhone attribute
    If ((Get-ADUser -Identity $using:User -Properties OfficePhone).OfficePhone -Like "*$($PhoneNumber)*") {
      Return $true
    }
    else {
      Return $false
    }
  }

  # Disconnect from Active Directory
  Remove-PSSession $SessionToActiveDirectory

  # Return result
  Return $Result

}