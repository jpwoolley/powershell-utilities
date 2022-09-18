function Enable-OnPremMailboxInHybridEnvironment {

    <#
    .SYNOPSIS
        Enable an on-premises Exchange mailbox for a user in a hybrid environment.
    .DESCRIPTION
        Enable an on-premises Exchange mailbox for a user in a hybrid environment. You must specify the user and the hostname of the Exchange server. Optionally, you can also pass in a PSCredential object for automation. Uses PowerShel remoting to connect to the Exchange server so can be run from any machine on the same network.
    .EXAMPLE
        $Credential = Get-Credential
        Enable-OnPremMailboxInHybridEnvironment -User "john" -ExchangeServer "exchange.company" -AdminCredential $Credential
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $User,
        [Parameter(Mandatory)]
        [String]
        $ExchangeServer,
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        $AdminCredential
    )
        
    Process {
        # Action
        If($AdminCredential){
            $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://vm-exhyb-prd-01.tmbc.local/PowerShell/ -Authentication Kerberos -Credential $AdminCredential
        } else {
            $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://vm-exhyb-prd-01.tmbc.local/PowerShell/ -Authentication Kerberos
        }

        Invoke-Command -Session $session {
            Enable-RemoteMailbox -Identity $using:User -RemoteRoutingAddress "$($using:User)@TonbridgeAndMallingBC.mail.onmicrosoft.com"
        } | Out-Null

        # Verify
        $onpremMailbox = Invoke-Command -Session $session { Get-User -Identity $using:User }
        If( !($onpremMailbox.RecipientTypeDetails -eq "RemoteUserMailbox") ){
            Write-Error "Failed to enable on-premises mailbox for user $($User)"
        }

        Remove-PSSession $Session
    }

}