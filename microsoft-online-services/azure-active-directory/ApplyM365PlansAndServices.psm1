function ApplyM365PlansAndServices {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $Plan,
    [Parameter(Mandatory)]
    [String]
    $UsageLocation,
    [Parameter()]
    [Array]
    $AddServices,
    [Parameter()]
    [Array]
    $RemoveServices,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to Azure Active Directory service
  Try {
    Connect-MsolService -Credential $Credential
  }
  Catch {
    Try {
      Connect-MsolService -Credential $Credential 
    }
    Catch {
      Write-Error "Unable to connect to the Azure Active Directory service"
      Return
    }
  }
  
  # Check whether the user already has the licence assigned, or whether a spare licence is available
  If ((Get-MsolUser -UserPrincipalName $UserPrincipalName).Licenses | Where-Object { $_.AccountSkuId -eq $Plan }) {
    $AlreadyAssigned = $true
  }
  else {
    $PlanObject = Get-MsolAccountSku | Where-Object { $_.AccountSkuId -eq $Plan }
    If ( !($PlanObject.ActiveUnits -gt $PlanObject.ConsumedUnits) ) {
      Write-Error "Unable to apply licence. Not enough available licences remaining"
      Return
    }
  }
  
  # Check whether usage location is set correctly and set it if required
  If ( !(Get-MsolUser -UserPrincipalName $UserPrincipalName).UsageLocation -eq $UsageLocation ) {
    Try {
      Set-MsolUser -UserPrincipalName $UserPrincipalName -UsageLocation $UsageLocation
    }
    Catch {
      Write-Error "Unexpected error occured whilst applying usage location"
      Return
    }
  }

  # if licence is already assigned, find out currently disabled services to avoid overwriting
  If ($AlreadyAssigned) {
    $currentDisabledServices = @()
    If ((Get-MsolUser -UserPrincipalName $UserPrincipalName).Licenses | Where-Object { $_.AccountSkuId -eq $Plan }) {
      $currentDisabledServices = (((Get-MsolUser -UserPrincipalName $UserPrincipalName).Licenses | Where-Object { $_.AccountSkuId -eq $Plan }).ServiceStatus | Where-Object { $_.ProvisioningStatus -eq "Disabled" }).ServicePlan.ServiceName
    }
    # Add currently disabled services to 'remove' array
    If ($currentDisabledServices) {
      $RemoveServices = $RemoveServices + $currentDisabledServices
    }
    # Remove any 'services to enable' from 'services to disable'
    $RemoveServices = $RemoveServices | ForEach-Object { $_ | Where-Object { $_ -notin $AddServices } }
  }

  # Build licence object and assign to user
  $licenseOptions = New-MsolLicenseOptions -AccountSkuId $Plan -DisabledPlans $RemoveServices
  Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -AddLicenses $Plan -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 5
  Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -LicenseOptions $licenseOptions -ErrorAction SilentlyContinue
  Start-Sleep 60

  # Disconnect from the Azure Active Directory service
  [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()

}

function Test-ApplyM365PlansAndServices {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $UserPrincipalName,
    [Parameter(Mandatory)]
    [String]
    $Plan,
    [Parameter()]
    [Array]
    $AddServices,
    [Parameter()]
    [Array]
    $RemoveServices,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  # Attempt to connect to Azure Active Directory service
  Try {
    Connect-MsolService -Credential $Credential
  }
  Catch {
    Try {
      Connect-MsolService -Credential $Credential 
    }
    Catch {
      Write-Error "Unable to connect to the Azure Active Directory service"
      Return
    }
  }
   
  # Verify whether plan has been assigned
  If ( ((Get-MsolUser -UserPrincipalName $UserPrincipalName).Licenses | Where-Object { $_.AccountSkuId -eq $Plan }).Count -lt 1 ) {
    [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
    return $false
  }
  # Verify whether correct services are enabled
  # Get enabled services
  $EnabledServices = ((Get-MsolUser -UserPrincipalName $UserPrincipalName).Licenses | Where-Object { $_.AccountSkuId -eq $Plan }).ServiceStatus | Where-Object {$_.ProvisioningStatus -ne "Disabled" }
  # Check for added services
  If (($null -ne $AddServices) -and ($AddServices.Length -gt 0)) {
    ForEach ($Service in $AddServices) {
      If (-not ($EnabledServices.ServicePlan.ServiceName -contains $Service)) {
        [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
        return $false
      }
    }
  }
  # Check for removed services
  If (($null -ne $RemoveServices) -and ($RemoveServices.Length -gt 0)) {
    ForEach ($Service in $RemoveServices) {
      If ($EnabledServices.ServicePlan.ServiceName -contains $Service) {
        [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
        return $false
      }
    }
  }

  # Disconnect from the Azure Active Directory service
  [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
  return $true
  
}