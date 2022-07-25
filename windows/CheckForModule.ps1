function CheckForModule {
  <#
  .SYNOPSIS
    Checks whether a named module is installed or needs updating.
  .DESCRIPTION
    Checks whether a named module is installed or needs updating. Module is installed to the user profile.
  .EXAMPLE
    CheckForModule -ModuleName "ExchangeOnlineManagement"
  #>
  
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String]
    $ModuleName
  )

  Try {
    # Check whether module is installed
    $InstalledModule = Get-Module -Name $ModuleName
  }
  Catch {
    # Couldn't find module. Now installing from PowerShell Gallery
    Install-Module -Name $ModuleName -Force -Scope CurrentUser
    Return
  }

  # Check whether a newer version is available
  $InstalledVersion = $InstalledModule.Version
  $LatestVersion = (Find-Module -Name $ModuleName).Version
  If ($LatestVersion -gt $InstalledVersion) {
    Install-Module -Name $ModuleName -Force -Scope CurrentUser
    Return
  }

}