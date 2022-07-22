function Stop-Applications {
    <#
.SYNOPSIS
    Ends the specified applications.
.DESCRIPTION
    Ends the specified applications. Takes an array containing the process names of the applications.
.EXAMPLE
    Stop-Applications -applications @("OUTLOOK", "EXCEL", "WINWORD", "MSACCESS", "MSPUB", "ONENOTE", "POWERPNT")
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [array]
        $applications
    )

    $openApps = Get-Process | Where-Object { $applications -contains $_.Name }
    foreach ($app in $openApps) {
        Try {
            Stop-Process -Name $app.ProcessName -Force
            Write-Host "Successfully ended $($app.ProcessName)" -ForegroundColor Green
        }
        Catch {
            Write-Host "Failed to end $($app.ProcessName)" -ForegroundColor Red
            $failure = $true
        }
    
    }

    If ($failure) {
        Throw "Failed to close applications"
    }
    else {
        Return
    }

}