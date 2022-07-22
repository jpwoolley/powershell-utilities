function Set-MicrosoftPlanAndServices {
  <#
  .SYNOPSIS
    Assign a plan to a Microsoft 365 user, or update the list of enabled services.
  .DESCRIPTION
    Assign a plan to a Microsoft 365 user, or update the list of enabled services. The -add and -remove parameter can be used to add or remove services whislt preserving the existing services for that user (as assigning a licence overwrites the assigned services)
  .EXAMPLE
    The example below would be used to assign an E3 licence to a user called person@domain.com
    Set-MicrosoftPlanAndServices -user person@domain.com -plan "reseller-account:SPE_E3" -usageLocation "GB"

    The example below would be used to remove the EXCHANGE_S_ENTERPRISE service from that user while preserving the current assigned services
    Set-MicrosoftPlanAndServices -user person@domain.com -plan "reseller-account:SPE_E3" -usageLocation "GB" -Remove "EXCHANGE_S_ENTERPRISE"

    The example below would be used to add the EXCHANGE_S_ENTERPRISE service from that user while preserving the current assigned services
    Set-MicrosoftPlanAndServices -user person@domain.com -plan "reseller-account:SPE_E3" -usageLocation "GB" -Add "EXCHANGE_S_ENTERPRISE"
  #>

  [CmdletBinding()]
  param (
      [Parameter(Mandatory)]
      [String]
      $user,
      [Parameter(Mandatory)]
      [String]
      $plan,
      [Parameter(Mandatory)]
      [String]
      $usageLocation,
      [Parameter()]
      [String]
      $add,
      [Parameter()]
      [String]
      $remove
  )

  # Check whether the user already has the licence assigned, or whether a spare licence is available
  If ((Get-MsolUser -UserPrincipalName $user).Licenses | Where-Object { $_.AccountSkuId -eq $plan }) {
    $alreadyAssigned = $true
  }
  else {
    $planObject = Get-MsolAccountSku | Where-Object { $_.AccountSkuId -eq $plan }
    If ( !($planObject.ActiveUnits -gt $planObject.ConsumedUnits) ) {
      Throw "Unable to apply licence. Not enough available licences remaining"
    } 
  }
  
  # Check whether usage location is set correctly and set it if required
  If ( !(Get-MsolUser -UserPrincipalName $user).UsageLocation -eq $usageLocation ) {
    Try {
      Set-MsolUser -UserPrincipalName $user -UsageLocation $usageLocation
    }
    Catch {
      Throw "Unexpected error occured whilst applying usage location"
    }
  }

  # if licence is already assigned, find out currently disabled services to avoid overwriting
  If ($alreadyAssigned) {
    $currentDisabledServices = @()
    If ((Get-MsolUser -UserPrincipalName $user).Licenses | Where-Object { $_.AccountSkuId -eq $plan }) {
      $currentDisabledServices = (((Get-MsolUser -UserPrincipalName $user).Licenses | Where-Object { $_.AccountSkuId -eq $plan }).ServiceStatus | Where-Object { $_.ProvisioningStatus -eq "Disabled" }).ServicePlan.ServiceName
    }
    # Add currently disabled services to 'remove' array
    If ($currentDisabledServices) {
      $remove = $remove + $currentDisabledServices
    }
    # Remove any 'services to enable' from 'services to disable'
    $remove = $remove | ForEach-Object { $_ | Where-Object { $_ -notin $add } }
  }

  # Build licence object and assign to user
  $licenseOptions = New-MsolLicenseOptions -AccountSkuId $plan -DisabledPlans $remove
  Set-MsolUserLicense -UserPrincipalName $user -AddLicenses $plan -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 5
  Set-MsolUserLicense -UserPrincipalName $user -LicenseOptions $licenseOptions -ErrorAction SilentlyContinue
  Start-Sleep 30
   
  # Verify whether licence and services have been assigned
  If ( !(Get-MsolUser -UserPrincipalName $user).Licenses | Where-Object { $_.AccountSkuId -eq $plan } ) {
    Throw "Failed to apply licence"
  }
  If ( (((Get-MsolUser -UserPrincipalName $user).Licenses | Where-Object { $_.AccountSkuId -eq $plan }).ServiceStatus | Where-Object { $_.ProvisioningStatus -ne "Disabled" } | Where-Object { $_.ServicePlan.ServiceName -in $remove }) ) {
    Throw "Failed to apply services"
  }

  Return
}