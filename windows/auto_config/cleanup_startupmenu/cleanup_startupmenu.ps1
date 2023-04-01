
# Remove 'Recently added' section
reg import .\custom_menu.reg

# Remove 'Show all apps' section
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoStartMenuMorePrograms /t REG_DWORD /d 1 /f

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoStartMenuMorePrograms /t REG_DWORD /d 1 /f

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoStartMenuPinnedList /t REG_DWORD /d 0 /f

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoCommonGroups /t REG_DWORD /d 0 /f

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoSearchInternetInStartMenu /t REG_DWORD /d 0 /f

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoSearchFilesInStartMenu /t REG_DWORD /d 0 /f

# Restart explorer.exe to take the changes into effect
Stop-Process -ProcessName explorer