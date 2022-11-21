function GrantPermissionToDistributionLists {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $UserPrincipalName,
        [Parameter(Mandatory)]
        [array]
        $Addresses,
        [Parameter()]
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

    If (($null -ne $Addresses) -and ($Addresses.Length -gt 0)) {
        ForEach ($Address in $Addresses) {
            # Grant permission to distribution lists
            Try {
                Add-DistributionGroupMember -Identity $Address -Member $UserPrincipalName
                Start-Sleep 60
            }
            Catch {
                Write-Error "Could not add to distribution list $($Address)"
            }
        }
    }

    Disconnect-ExchangeOnline -Confirm:$false

}

function Test-GrantPermissionToDistributionLists {

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
      Return $false
    }
  }
    
    # Verify
    ForEach ($Address in $Addresses) {
        $ListMembership = Get-DistributionGroupMember -Identity $Address | ForEach-Object { $_.Alias }
        If ( !($ListMembership -contains $UserPrincipalName) -and !($ListMembership -contains $UserPrincipalName -replace "@.*","") ) {
            Disconnect-ExchangeOnline -Confirm:$false
            return $false
        }
    }

    Disconnect-ExchangeOnline -Confirm:$false
    return $true

}