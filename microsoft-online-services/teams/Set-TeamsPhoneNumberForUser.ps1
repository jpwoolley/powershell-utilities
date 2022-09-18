function Set-TeamsPhoneNumberForUser {
    <#
    .SYNOPSIS
        Sets the telephone number in Teams for a user and, optionally, sets the OfficePhone attribute in ActiveDirectory.
    .DESCRIPTION
        Sets the telephone number in Teams for a user and, optionally, sets the OfficePhone attribute in ActiveDirectory.

    .EXAMPLE
        Set-TeamsPhoneNumberForUser -User "John" -PhoneNumber "+441234567890" -SetADAttribute
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $User,
        [Parameter(Mandatory)]
        [String]
        $PhoneNumber,
        [Parameter()]
        [switch]
        $SetADAttribute       
    )

    Process
    {
        # Action
        Set-CsPhoneNumberAssignment -Identity $User -PhoneNumber $PhoneNumber -PhoneNumberType "DirectRouting"

        # Verify
        If( (Get-CsOnlineUser -Identity $User).LineURI -Like "*$($PhoneNumber)*" ){
            Write-Host "Teams phone number successfully set for $($User)" -ForegroundColor Green
        } else {
            Throw "Failed to set Teams phone number for $($User)"
        }

        If($SetADAttribute){
            # Action
            # Having this value set will cause this action to fail
            If( (Get-Aduser -Identity $User -Properties msRTCSIP-DeploymentLocator).'msRTCSIP-DeploymentLocator' -eq "SRV:" ){
                Set-ADUser -Identity $User -Clear msRTCSIP-DeploymentLocator
            }
            Set-ADUser -Identity $User -OfficePhone $PhoneNumber

            # Verify
            If( (Get-ADUser -Identity $User -Properties OfficePhone).OfficePhone -eq $PhoneNumber ){
                Write-Host "Active Directory OfficePhone attribute successfully set for $($User)" -ForegroundColor Green
            } else {
                Throw "Failed to set Active Directory OfficePhone attribute for $($User)"
            }
        }
    }

}