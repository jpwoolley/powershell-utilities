function SetTeamsPolicyOnlineVoiceRouting {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $Policy,
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
    Grant-CsOnlineVoiceRoutingPolicy -Identity $UserPrincipalName -PolicyName $Policy
  }
  Catch {
    Write-Error "Could not set CsOnlineVoiceRoutingPolicy policy"
  }

  # Disconnect from the Microsoft Teams service
  Disconnect-MicrosoftTeams | Out-Null

}

function Test-SetTeamsPolicyOnlineVoiceRouting {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $Policy,
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
  $checkCount = 0
  $verified = $false
  Do {
    $checkCount = $checkCount + 1
    Start-Sleep 30
    If ( (Get-CsOnlineUser -Identity $UserPrincipalName).OnlineVoiceRoutingPolicy.Name -eq $Policy) {
      $verified = $true
    }
  } While (($verified -eq $false) -and ($checkCount -le 60))

  # Disconnect from the Microsoft Teams service
  Disconnect-MicrosoftTeams | Out-Null

  # Return result
  If (-not $verified) {
    return $false
  }
  else {
    return $true
  }

}