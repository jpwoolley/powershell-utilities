function Grant-AccessToMailboxesAndDistributionLists {

    <#
.SYNOPSIS
    Grants the specified user permission to mailboxes and distribution lists.
.DESCRIPTION
    Grants the specified user permission to mailboxes and distribution lists. $User is a string value and $Addresses is an array (even if only one address is to be specified). For mailboxes, the user will be granted 'FullAccess' and 'SendAs' permission. A non-terminating error will be written to console for any addresses which the user couldn't be granted access to.
.EXAMPLE
    Grant-AccessToMailboxesAndDistributionLists -User "John" -Addresses @("bob@example.com", "finance@example.com")
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $User,
        [Parameter(Mandatory)]
        [array]
        $Addresses
    )

    Process {

        # Make sure that user exists
        Try {
            Get-User -Identity $User
        }
        Catch {
            Throw "Could not find user $($User)"
        }

        # Make sure that $Address array is not empty 
        If( ($null -eq $Addresses) -or ($Addresses.length -lt 1) ) {
            Throw "Mailboxes array is empty"            
        }
    
        ForEach ($Address in $Addresses) {
            
            # Grant permission to mailboxes
            If(( Get-Mailbox -Identity $Address).Count -gt 0 ) {
                Try {
                    Add-MailboxPermission -Identity $Address -User $User -AccessRights FullAccess -InheritanceType All
                    Add-RecipientPermission -Identity $Address -AccessRights "SendAs" -Trustee $User
                }
                Catch {
                    Write-Error "Could not grant permission to mailbox $($Address)"
                }
            }

            # Grant permission to distribution lists
            If( (Get-DistributionGroup -Identity).Count -gt 0 ) {
                Try {
                    Add-DistributionGroupMember -Identity $Address -Member $User
                }
                Catch {
                    Write-Error "Could not add to distribution list $($Address)"
                }
            }
            
        }
    
    }

}

