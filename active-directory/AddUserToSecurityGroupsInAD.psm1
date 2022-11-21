function AddUserToSecurityGroupsInAD {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [Object]
    $Username,
    [Parameter()]
    [Array]
    $SecurityGroups,
    [Parameter(Mandatory)]
    [String]
    $ActiveDirectoryServer,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )

  If (($null -ne $securityGroups) -and ($SecurityGroups.Length -gt 0)) {
    $SessionToActiveDirectory = New-PSSession -ComputerName $ActiveDirectoryServer -Credential $Credential
    Invoke-Command -Session $SessionToActiveDirectory {
      ForEach ($Group in $using:SecurityGroups) {
        Add-ADGroupMember -Identity $Group -Members $using:Username
      }
    }
    Remove-PSSession $SessionToActiveDirectory
  }

}

function Test-AddUserToSecurityGroupsInAD {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [Object]
    $Username,
    [Parameter()]
    [array]
    $SecurityGroups,
    [Parameter(Mandatory)]
    [String]
    $ActiveDirectoryServer,
    [Parameter(Mandatory)]
    [Object]
    $Credential
  )
  
  If (($null -ne $securityGroups) -and ($SecurityGroups.Length -gt 0)) {
    $SessionToActiveDirectory = New-PSSession -ComputerName $ActiveDirectoryServer -Credential $Credential
    $Result = Invoke-Command -Session $SessionToActiveDirectory {
      $Verify = @()
      $userGroupMembership = (Get-ADPrincipalGroupMembership $using:Username).Name
      ForEach ($Group in $using:SecurityGroups) {
        $Verify = $Verify + ($UserGroupMembership -contains $Group)
      }
      If ($Verify -contains $false) {
        return $false
      }
      Return $true
    }
    Remove-PSSession $SessionToActiveDirectory

    Return $Result
  }
}