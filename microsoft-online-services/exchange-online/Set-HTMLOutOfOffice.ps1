function Set-HTMLOutOfOffice {
    <#
    .SYNOPSIS
        Sets an HTML automatic reply for a mailbox.
    .DESCRIPTION
        Sets an HTML automatic reply for a mailbox. The message can include HTML elements but only include the elements which go inside the <body> tag. You must also include either -Internal, -External or both.
    .EXAMPLE
        $myOutOfOffice = @"
            <h1>Out of office</h1>
            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
        "@
        Set-HTMLOutOfOffice -mailbox "person@mail.com" -message $myOutOfOffice -Internal -External
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $mailbox,
        [Parameter(Mandatory)]
        [String]
        $message,
        [Parameter()]
        [switch]
        $internal,
        [Parameter()]
        [switch]
        $external
    )

    # Get the mailbox
    $mailbox = Get-Mailbox | Where-Object { $_.PrimarySmtpAddress -eq $mailbox }

    $messageStart = @"
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body>
"@
    $messageEnd = @"
</body>
</html>
"@
    $emailBody = $messageStart + $message + $messageEnd

    # Set the automatic reply
    If ($internal) {
        Set-MailboxAutoReplyConfiguration -Identity $mailbox -AutoReplyState Enabled -InternalMessage $emailBody
    }
    If ($external) {
        Set-MailboxAutoReplyConfiguration -Identity $mailbox -AutoReplyState Enabled -ExternalMessage $emailBody
    }

}