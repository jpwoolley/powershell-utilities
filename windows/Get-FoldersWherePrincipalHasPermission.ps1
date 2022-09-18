function Get-FoldersWherePrincipalHasPermission {
  <#
  .SYNOPSIS
    Scans a fodler and subfolders and tells you which folders the specified security principals have access to.
  .DESCRIPTION
    The function takes two arguments, both of which should be supplied as arrays. The array can either contain 1 value or multiple. $Folders is the path of the 'root' folder. The script will scan this folder and every folder below it. $SecurityPrincples is the user of groups that you want to check to see what access they have. Note that you have to include the domain of the principal as well (e.g. "domain\user" or "domain\usergroup").
  .EXAMPLE
    Get-FoldersWherePrincipalHasPermission -Folders @("C:\", "D:\Folder") -SecurityPrincples @("domain\user", "domain\usergroup")
  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [array]
    $Folders,
    [Parameter(Mandatory)]
    [array]
    $SecurityPrincples
  )
    
  $result = @()

  ForEach ($Folder in $Folders) {
    
    $WorkingFolders = Get-ChildItem $Folder -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Attributes -eq "Directory" }
    
    ForEach ($WorkingFolder in $WorkingFolders) {

      # Get explicit permissions on folder
      $permissions = ($WorkingFolder | Get-Acl -ErrorAction SilentlyContinue).Access | Where-Object { $_.IsInherited -eq $false } | Where-Object { $SecurityPrincples -contains $_.IdentityReference }
        
      ForEach ($permission in $permissions) {
        $result += @{
          "Folder"            = $WorkingFolder.FullName
          "SecurityPrinciple" = $permission.IdentityReference
          "Rights"            = $permission.FileSystemRights
        }
      }
    }
  }
    
  Return $result
}