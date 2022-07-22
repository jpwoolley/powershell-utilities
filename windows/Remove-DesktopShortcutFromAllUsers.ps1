function Remove-DesktopShortcutFromAllUsers {
    <#
.SYNOPSIS
    Removes the named shortcut from the desktop of each user on the machine.
.DESCRIPTION
    Removes the named shortcut from the desktop of each user on the machine.
.EXAMPLE
    Remove-DesktopShortcutFromAllUsers -shortcutName "Adobe Reader"
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $shortcutName
    )

    $users = Get-ChildItem -Directory "C:\Users" 
    ForEach ($user in $users) { 
        If (Test-Path -Path "C:\Users\$($user.Name)\Desktop\${shortcutName}.lnk") { 
            Remove-Item -Path "C:\Users\$($user.Name)\Desktop\${shortcutName}.lnk" -Force 
        } 
    }

}