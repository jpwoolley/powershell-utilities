# Get all installed applications
# There are 2 useful ways of doing this. The first method uses a WMI query. The second method uses the Get-ItemProperty cmdlet to query the "[...]\Uninstall" registry keys.

# WMI query
Get-WmiObject Win32_Product | Select-Object Name,Vendor,Version,InstallDate,InstallLocation,IdentifyingNumber | Sort-Object Name | Format-Table -AutoSize

# Using Get-ItemProperty to query the registry
# Applications, installed to the user profile: 
Get-ItemProperty  HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object  DisplayName | Format-Table –AutoSize
# 64-bit applications, installed computer-wide: 
Get-ItemProperty  HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object  DisplayName | Format-Table –AutoSize 
# 32-bit applications 
Get-ItemProperty  HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object  DisplayName | Format-Table –AutoSize