function UpdateCalendarPermission {
  
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $Recipient,
    [Parameter(Mandatory)]
    [String]
    $Permission,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to the Exchange Online service
  Try {
    Connect-ExchangeOnline -Credential $Credential -ShowBanner:$false
  }
  Catch {
    Try {
        Connect-ExchangeOnline -Credential $Credential -ShowBanner:$false
    }
    Catch {
      Write-Error "Unable to connect to the Exchange Online service"
      Return
    }
  }

  # Set calendar permission
  Set-MailboxFolderPermission -Identity "$($UserPrincipalName):\calendar" -User $Recipient -AccessRights $Permission
  Start-Sleep 10

  # Disconnect from the Exchange Online service
  Disconnect-ExchangeOnline -Confirm:$false

}

function Test-UpdateCalendarPermission {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $Recipient,
    [Parameter(Mandatory)]
    [String]
    $Permission,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to the Exchange Online service
  Try {
    Connect-ExchangeOnline -Credential $Credential -ShowBanner:$false
  }
  Catch {
    Try {
        Connect-ExchangeOnline -Credential $Credential -ShowBanner:$false
    }
    Catch {
      Write-Error "Unable to connect to the Exchange Online service"
      Return
    }
  }

  # Verify
  If( (Get-MailboxFolderPermission -Identity "$($UserPrincipalName):\calendar" -User $Recipient).AccessRights -eq $Permission ) {
      Disconnect-ExchangeOnline -Confirm:$false
      Return $true
  } else {
    Disconnect-ExchangeOnline -Confirm:$false
      Return $false
  }

}