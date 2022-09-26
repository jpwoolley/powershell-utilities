# This script fixes the 'Unquoted Service Path Enumeration' vulnerability on Windows machines. It's inspired by https://github.com/VectorBCO/windows-path-enumerate/ but greatly simplified. The first region of the sript contains code which detects and fixes
# the vulnerabilty. The second region contains a version of the code which can be used as a detection rule on Configuration Manager.

# Fix
<#
# Find and fix bad uninstall strings
$Paths = @(
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services"
)
If(Test-Path "C:\Program Files (x86)"){
    $Paths += "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
}

$KeysWithElegibleStrings = $Keys | Where-Object {((Get-ItemProperty -Path "Registry::$($_.Name)").UninstallString) -or ((Get-ItemProperty -Path "Registry::$($_.Name)").ImagePath)}

$BadUninstallStrings = @()
$BadImagePathStrings = @()
ForEach($Item in $KeysWithElegibleStrings){

    Try {
        If(Get-ItemPropertyValue -Path "Registry::$($Item.Name)" -Name "UninstallString" | Where-Object {($_ -Match '^((\w\:)|(%[-\w_()]+%))\\') -and ($_ -NotMatch 'MsiExec(\.exe)?') -and ($_ -like '* *.exe*')}){
            $BadUninstallStrings += $Item
    }
    }
    Catch [System.Management.Automation.PSArgumentException]{
        # Ignore
    }

    Try {
        If(Get-ItemPropertyValue -Path "Registry::$($Item.Name)" -Name "ImagePath" | Where-Object {($_ -Match '^((\w\:)|(%[-\w_()]+%))\\') -and ($_ -NotMatch 'MsiExec(\.exe)?') -and ($_ -like '* *.exe*')}){
            $BadImagePathStrings += $Item
    }
    }
    Catch [System.Management.Automation.PSArgumentException] {
        # Ignore
    }

}

ForEach($Item in $BadUninstallStrings){
    $BadString = Get-ItemPropertyValue -Path "Registry::$($Item.Name)" -Name "UninstallString"
    $BadString1 = ($BadString -split ".exe ")[0]
    $BadString2 = ($BadString -split ".exe ")[1]
    If($null -eq $BadString2){
        $GoodString = """$($BadString1)"""
    } else {
        $GoodString = """$($BadString1).exe"" $($BadString2)"
    }
    Set-ItemProperty -Path "Registry::$($Item.Name)" -Name "UninstallString" -Value $GoodString 
}

ForEach($Item in $BadImagePathStrings){
    $BadString = Get-ItemPropertyValue -Path "Registry::$($Item.Name)" -Name "ImagePath"
    $BadString1 = ($BadString -split ".exe ")[0]
    $BadString2 = ($BadString -split ".exe ")[1]
    If($null -eq $BadString2){
        $GoodString = """$($BadString1)"""
    } else {
        $GoodString = """$($BadString1).exe"" $($BadString2)"
    }
    Set-ItemProperty -Path "Registry::$($Item.Name)" -Name "ImagePath" -Value $GoodString 
}
#>

# Detection
<#
$Paths = @(
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services"
)
If(Test-Path "C:\Program Files (x86)"){
    $Paths += "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
}

$Keys = @()
ForEach($Path in $Paths){
    $ChildItems = Get-ChildItem -Path "Registry::$($Path)"
    ForEach($Child in $ChildItems){
        $Keys += $Child
    }
}

$KeysWithElegibleStrings = $Keys | Where-Object {((Get-ItemProperty -Path "Registry::$($_.Name)").UninstallString) -or ((Get-ItemProperty -Path "Registry::$($_.Name)").ImagePath)}

$BadUninstallStrings = @()
$BadImagePathStrings = @()
ForEach($Item in $KeysWithElegibleStrings){

    Try {
        If(Get-ItemPropertyValue -Path "Registry::$($Item.Name)" -Name "UninstallString" | Where-Object {($_ -Match '^((\w\:)|(%[-\w_()]+%))\\') -and ($_ -NotMatch 'MsiExec(\.exe)?') -and ($_ -like '* *.exe*')}){
            $BadUninstallStrings += $Item
    }
    }
    Catch [System.Management.Automation.PSArgumentException]{
        # Ignore
    }

    Try {
        If(Get-ItemPropertyValue -Path "Registry::$($Item.Name)" -Name "ImagePath" | Where-Object {($_ -Match '^((\w\:)|(%[-\w_()]+%))\\') -and ($_ -NotMatch 'MsiExec(\.exe)?') -and ($_ -like '* *.exe*')}){
            $BadImagePathStrings += $Item
    }
    }
    Catch [System.Management.Automation.PSArgumentException] {
        # Ignore
    }

}

If(($BadUninstallStrings.Length -le 0) -and ($BadImagePathStrings.Length -le 0)){
    Write-Host "Installed" -ForegroundColor Green
}
#>