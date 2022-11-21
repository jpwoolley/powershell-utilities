# Provisioning a user in AAD requires a sync of the Azure Connector. The code below simply checks to see if this has happened already.

function Test-ProvisionUserInAAD {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $userPrincipalName,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to the Exchange Online service
  Try {
    Connect-AzureAD -Credential $Credential | Out-Null
  }
  Catch {
    Try {
        Connect-AzureAD -Credential $Credential | Out-Null
    }
    Catch {
      Write-Error "Unable to connect to the Exchange Online service"
      Return
    }
  }

  Do {
    Try {
      $User = Get-AzureADUser -ObjectId $userPrincipalName
    }
    Catch {
      Start-Sleep 60
      $checkCount = $checkCount + 1
    }
    if ($User.Length -gt 0) {
      # User has been provisioned
      Disconnect-AzureAD
      return $true
    }
  } While ($checkCount -le 30)
    
  # User has failed to provision
  Disconnect-AzureAD
  return $false

}