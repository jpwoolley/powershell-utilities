function Remove-DeviceFromCollections ($device){

    <#
    .SYNOPSIS
        Removes a device from any device collections in which it is specified in a direct membership rule.
    .DESCRIPTION
        Removes a device from any device collections in which it is specified in a direct membership rule. 
    .EXAMPLE
        Before running this function, you must be connected to the Configuration Manager system.
        1. Open 'Configuration Manager Console' with elevated priviledges.
        2. Click the menu button in the top left corner.
        3. Select 'Connect via Windows PowerShell ISE'.
        4. Paste the function into the ISE window below the code
        for connecting to the site.
        5. Select it all and run it!

        Remove-DeviceFromCollections -device "Laptop1"
    #>

    Try {
        $deviceObject = (Get-CMDevice | Where-Object {$_.Name -eq $($device)})
      }
      Catch {
        Throw "Could not find a device with the name $($device)"
      }
      $deviceResourceID = (Get-CMDevice -Name $deviceObject.Name).ResourceID

    # Get collections with a direct membership rule for the device
    $collections = Get-CMDeviceCollection | Where-Object {$_.CollectionRules -like "*$($deviceObject.Name)*"}
    If($collections.Length -le 0){
        Write-Host "This device is not a member of any collections!" -ForegroundColor Green
        Return
    }

    # Remove direct membership rule from collections and update the collection
    ForEach ($collection in $collections){
        Write-Host "Removing device from $($collection.Name)..." -ForegroundColor Yellow
        Try {
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $collection.Name -ResourceId $deviceResourceID -Force
            Write-Host "Device removed!" -ForegroundColor Green
            Get-CMCollection -Name $collection.Name | Invoke-CMCollectionUpdate
        }
        Catch {
            Write-Host "Failed to remove device from $($collection.Name)..." -ForegroundColor Red
        }
    }

    Return
}