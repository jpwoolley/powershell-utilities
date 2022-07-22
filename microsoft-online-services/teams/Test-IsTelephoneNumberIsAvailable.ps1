function Test-IsTelephoneNumberIsAvailable ($number) {
  <#
.SYNOPSIS
  Tests where a telephone number is already assigned in Microsoft Teams. Returns true (if the number is available) or false (if it's already in use)
.DESCRIPTION
  Tests where a telephone number is already assigned in Microsoft Teams. Returns true (if the number is available) or false (if it's already in use)
.EXAMPLE
  Test-IsTelephoneNumberIsAvailable -number +442079460621
#>

  $test = Get-CsOnlineUser | Where-Object { $_.LineURI -Like "*$($number)" -or $_.PrivateLine -Like "*$($number)" }

  If ($test) {
    Return $false
  }
  else {
    Return $true
  }

}