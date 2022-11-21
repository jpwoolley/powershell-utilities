function AssignTelephonyNumberToUserInTeams {
  
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $PhoneNumber,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to the Microsoft Teams service
  Try {
    Connect-MicrosoftTeams -Credential $Credential | Out-Null
  }
  Catch {
    Try {
      Connect-MicrosoftTeams -Credential $Credential | Out-Null
    }
    Catch {
      Write-Error "Unable to connect to the Microsoft Teams service"
      Return
    }
  }

  # Action
  Try {
    Set-CsPhoneNumberAssignment -Identity $UserPrincipalName -PhoneNumber $PhoneNumber -PhoneNumberType "DirectRouting"
  }
  Catch {
    Write-Error "Could not set telephone number for user in Teams"
  }

  # Disconnect from the Microsoft Teams service
  Disconnect-MicrosoftTeams | Out-Null

  # Wait
  Start-Sleep 60
}

function Test-AssignTelephonyNumberToUserInTeams {
  
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $PhoneNumber,
    [Parameter(Mandatory)]
    [Object]
    $Credential  
  )

  # Attempt to connect to the Microsoft Teams service
  Try {
    Connect-MicrosoftTeams -Credential $Credential | Out-Null
  }
  Catch {
    Try {
      Connect-MicrosoftTeams -Credential $Credential | Out-Null
    }
    Catch {
      Write-Error "Unable to connect to the Microsoft Teams service"
      Return
    }
  }

  # Verify
  If((Get-CsOnlineUser -Identity $UserPrincipalName).LineURI -Like "*$($PhoneNumber)*"){
    # Disconnect from the Microsoft Teams service
    Disconnect-MicrosoftTeams | Out-Null

    return $true
  }
  else {
    # Disconnect from the Microsoft Teams service
    Disconnect-MicrosoftTeams | Out-Null

    return $false
  }
    
}