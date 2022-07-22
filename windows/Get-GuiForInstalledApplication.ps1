function Get-GuiForInstalledApplication {
    <#
.SYNOPSIS
    Searches the registry for installed applications. Returns an array of objects containing matching application names and the location.
.DESCRIPTION
    Searches the registry for installed applications. Returns an array of objects containing matching application names and the location.
.NOTES
    
.LINK
    
.EXAMPLE
    $results = Get-GuiForInstalledApplications -applicationName "Acrobat"

    If results are found, returned array will look like:
    @(
      @{
        "DisplayName" = "Adobe Acrobat DC"
        "Location" = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-1033-FFFF-7760-0C0F074E4100}"
      }
    )
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $applicationName
    )

    $registryLoations = (
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", # 64-bit applications installed to machine
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", # 32-bit applications installed to machine
        "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" # applications installed to user profile
    )

    $results = @()

    ForEach ($location in $registryLoations) {
        $keys = Get-ChildItem -Path $location
        ForEach ($key in $keys) {
            Try {
                $test = $key | Get-ItemPropertyValue -Name "DisplayName" | Where-Object { $_ -Like "*$($applicationName)*" } 
            }
            Catch {
            }
            If ($test) {
                $results = $results + @{
                    "DisplayName" = $test
                    "Location"    = $key.Name
                }
            } 
        }

    }

    return $results

}