function AddUserToTeamsCallQueues {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [string] 
    $UserPrincipalName,
    [Parameter()]
    [Array] 
    $Queues,
    [Parameter(Mandatory)]
    [Object]
    $Credential

  )

  If(($null -eq $Queues) -or ($Queues.Length -eq 0)){
    Return
  }

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

  # Add user to queues
  $UserIdentity = (Get-CsOnlineUser -Identity $UserPrincipalName).Identity

  # Test that we got the correct identity
  $TestIdentity = Get-CsOnlineUser | Where-Object {$_.Identity -eq $UserIdentity}
  If(-not ($UserPrincipalName -eq $TestIdentity.UserPrincipalName)){
    Write-Error "Failed to retrieve the correct identity"
    Return
  }

  ForEach ($Queue in $Queues) {
    $QueueIdentity = (Get-CsCallQueue -NameFilter $Queue).Identity
    $QueueCurrentUsers = (Get-CsCallQueue -NameFilter $Queue).Users
    $QueueNewUsers = $QueueCurrentUsers += $UserIdentity
    Try {
      Set-CsCallQueue -Identity $QueueIdentity -Users $QueueNewUsers | Out-Null
    }
    Catch {
      Write-Error "Unable to add user to call queue $($Queue)"
    }          
  }

  # Disconnect from the Microsoft Teams service
  Disconnect-MicrosoftTeams | Out-Null

}

function Test-AddUserToTeamsCallQueues {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [string] 
    $UserPrincipalName,
    [Parameter()]
    [Array] 
    $Queues,
    [Parameter(Mandatory)]
    [Object]
    $Credential

  )

  If(($null -eq $Queues) -or ($Queues.Length -eq 0)){
    Return $true
  }

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
  $UserIdentity = (Get-CsOnlineUser -Identity $UserPrincipalName).Identity
  $Verify = @()
  ForEach ($Queue in $Queues) {
    $QueueUsers = (Get-CsCallQueue -NameFilter $Queue | Select-Object Users).Users
    $Verify += $QueueUsers -contains $UserIdentity
  }
  If (-Not ($Verify -contains $false)) {
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