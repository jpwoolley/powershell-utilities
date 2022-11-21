function GrantPermissionToSharedMailboxes {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter()]
    [array]
    $Addresses,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  If(($null -eq $Addresses) -or ($Addresses.Length -eq 0)){
    Return
  }
  
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

  ForEach ($Address in $Addresses) {
    # Grant permission to mailboxes
    If($null -ne (Get-Mailbox -Identity $Address)){
      Try {
        Add-MailboxPermission -Identity $Address -User $UserPrincipalName -AccessRights FullAccess -InheritanceType All | Out-Null
        Add-RecipientPermission -Identity $Address -AccessRights "SendAs" -Trustee $UserPrincipalName -Confirm:$false | Out-Null
        Start-Sleep 60
      }
      Catch {
        Write-Error "Could not grant permission to mailbox $($Address)"
      }
    }
  }

  Disconnect-ExchangeOnline -Confirm:$false

}

function Test-GrantPermissionToSharedMailboxes {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter()]
    [array]
    $Addresses,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  If(($null -eq $Addresses) -or ($Addresses.Length -eq 0)){
    Return $true
  }

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

  ForEach ($Address in $Addresses) {
    # Grant permission to mailboxes
    If (-not ((Get-MailboxPermission -Identity $Address).User -contains $UserPrincipalName)) {
      Disconnect-ExchangeOnline -Confirm:$false
      Return $false
    }
  }
  
  Disconnect-ExchangeOnline -Confirm:$false
  Return $true
  
}