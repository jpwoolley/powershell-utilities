function ForceAzureADConnectSync ($Machine) {

  # This step forces a sync of all onprem AD databases
  (Get-ADDomainController -Filter *).Name | Foreach-Object { repadmin /syncall $_ (Get-ADDomain).DistinguishedName /AdeP | Out-Null }
  
  # This step forces a sync of your onprem AD with Azure AD. $Machine should be the hostname of the machine which hosts the Azure AD Connect software.
  Try {
      Invoke-Command -ComputerName $Machine -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta } | Out-Null
  }
  Catch {
      Start-Sleep 60
      Invoke-Command -ComputerName $Machine -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta } | Out-Null
  }
}