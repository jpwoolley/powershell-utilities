# This script fixes the 'Unquoted Service Path Enumeration' vulnerability on Windows machines. It's inspired by https://github.com/VectorBCO/windows-path-enumerate/ but greatly simplified.
#
# The following few lines of code can be used as a detection rule in SCCM:
# $Keys = $Paths | ForEach-Object {Get-ChildItem "Registry::$($_)"}
# $BadUninstallStrings = $Keys | Where-Object {(Get-ItemProperty -Path "Registry::$($_.Name)").UninstallString} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "UninstallString") -Match '^((\w\:)|(%[-\w_()]+%))\\'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "UninstallString") -NotMatch 'MsiExec(\.exe)?'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "UninstallString") -Like '* *.exe*'}
# $BadImagePathStrings = $Keys | Where-Object {((Get-ItemProperty -Path "Registry::$($_.Name)").ImagePath)} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "ImagePath") -Match '^((\w\:)|(%[-\w_()]+%))\\'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "ImagePath") -NotMatch 'MsiExec(\.exe)?'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "ImagePath") -Like '* *.exe*'}

## Main
# Places to look for bad strings
$Paths = @(
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services"
)
If(Test-Path "C:\Program Files (x86)"){
    $Paths += "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
}
# Filter through to find all the bad strings
$Keys = $Paths | ForEach-Object {Get-ChildItem "Registry::$($_)"}
$BadUninstallStrings = $Keys | Where-Object {(Get-ItemProperty -Path "Registry::$($_.Name)").UninstallString} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "UninstallString") -Match '^((\w\:)|(%[-\w_()]+%))\\'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "UninstallString") -NotMatch 'MsiExec(\.exe)?'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "UninstallString") -Like '* *.exe*'}
$BadImagePathStrings = $Keys | Where-Object {((Get-ItemProperty -Path "Registry::$($_.Name)").ImagePath)} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "ImagePath") -Match '^((\w\:)|(%[-\w_()]+%))\\'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "ImagePath") -NotMatch 'MsiExec(\.exe)?'} | Where-Object {(Get-ItemPropertyValue -Path "Registry::$($_.Name)" -Name "ImagePath") -Like '* *.exe*'}
# Fix bad uninstall strings, if any
If(($null -ne $BadUninstallStrings) -and ($BadUninstallStrings.Length -gt 0)){
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
}
# Fix bad image path strings, if any
If(($null -ne $BadImagePathStrings) -and ($BadImagePathStrings.Length -gt 0)){
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
}