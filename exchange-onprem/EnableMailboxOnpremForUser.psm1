function EnableRemoteRoutingMailboxOnpremForUser {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $Username,
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $ExchangeOnpremServer,
    [Parameter(Mandatory)]
    [String]
    $DomainName,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to Exchange Onprem
  Try {
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeOnpremServer -Authentication Kerberos -Credential $Credential
  }
  Catch {
    Try {
      $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeOnpremServer -Authentication Kerberos -Credential $Credential
    }
    Catch {
      Write-Error "Unable to connect to Exchange Onprem"
      Return
    }
  }

  # Enable mailbox
  Invoke-Command -Session $Session {
      Enable-RemoteMailbox -Identity $using:UserPrincipalName -RemoteRoutingAddress "$($using:Username)@$($DomainName)"
  } | Out-Null

  # Disconnect from Exchange Onprem
  Remove-PSSession $Session

}

function Test-EnableRemoteRoutingMailboxOnpremForUser {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $Username,
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $ExchangeOnpremServer,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to Exchange Onprem
  Try {
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeOnpremServer -Authentication Kerberos -Credential $Credential
  }
  Catch {
    Try {
      $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeOnpremServer -Authentication Kerberos -Credential $Credential
    }
    Catch {
      Write-Error "Unable to connect to Exchange Onprem"
      Return $false
    }
  }

  # Verify
  $OnpremMailbox = Invoke-Command -Session $Session { Get-User -Identity $using:UserPrincipalName }

  # Disconnect from Exchange Onprem
  Remove-PSSession $Session

  # Return result
  If($OnpremMailbox.RecipientTypeDetails -eq "RemoteUserMailbox"){
      return $true
  } else {
      return $false
  }

}