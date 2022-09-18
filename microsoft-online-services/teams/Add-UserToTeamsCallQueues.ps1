function Add-UserToTeamsCallQueues {

    <#
.SYNOPSIS
    Adds a user to specified Teams call queues. Returns a value or true or false depending on the outcome.
.DESCRIPTION
    Takes a string value for $User and an array value for $Queues (even if just one value). The function loops through each value in the $Queues array, adding the $user. Afterwards, the function then loops through each queue again to verify that the user has been added.
.EXAMPLE
    Add-UserToTeamsCallQueues -User "John" -Queues @("Sales", "Accounts")
    # Expected output in terminal - "User has been added to the specified call queues"
    # Expected output value - $true
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $User,
        [Parameter(Mandatory = $true)]
        [array] $Queues   
    )

    Process {
        # Add user to queues
        $UserObject = Get-CsOnlineUser -Identity $User | Select-Object Identity
        ForEach ($Queue in $Queues) {
            $QueueIdentity = (Get-CsCallQueue -NameFilter $Queue).Identity
            $QueueCurrentUsers = (Get-CsCallQueue -NameFilter $Queue).Users
            $QueueNewUsers = $QueueCurrentUsers += $UserObject
            Set-CsCallQueue -Identity $QueueIdentity -Users $QueueNewUsers | Out-Null         
        }

        # Verify
        $Verify = @()
        ForEach ($Queue in $Queues) {
            $QueueUsers = Get-CsCallQueue -NameFilter $Queue | Select-Object Users
            $Verify += $QueueUsers -contains $UserObject
        }
        If!($Verify -contains $false) {
            Write-Host "User has been added to the specified call queues"
            return $true
        } else {
            Write-Host "Failed to add user to the specified call queues"
            return $false
        }
    }

}