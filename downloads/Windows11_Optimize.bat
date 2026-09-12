@echo off
NET SESSION >nul 2>&1 || (echo Run as Administrator & pause & exit)

echo ============================================
echo   WINDOWS 11 DEEP OPTIMIZATION
echo   Safe to run. Reboot when done.
echo ============================================

:: ===== 1. TELEMETRY & DATA COLLECTION =====
sc delete DiagTrack >nul 2>&1
sc delete dmwappushservice >nul 2>&1
sc delete diagnosticshub.standardcollector.service >nul 2>&1
sc delete WMPNetworkSvc >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v Start /t REG_DWORD /d 4 /f

:: ===== 2. CORTANA =====
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f

:: ===== 3. ONEDRIVE =====
taskkill /f /im OneDrive.exe >nul 2>&1
%SystemRoot%\System32\OneDriveSetup.exe /uninstall >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

:: ===== 4. XBOX SERVICES =====
sc delete XblGameSave >nul 2>&1
sc delete XboxNetApiSvc >nul 2>&1
sc delete XboxGipSvc >nul 2>&1
sc delete BITS >nul 2>&1
sc delete WSearch >nul 2>&1

:: ===== 5. WIDGETS & CHAT (TaskbarX) =====
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v ChatIcon /t REG_DWORD /d 3 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f

:: ===== 6. SEARCH INDEXER (heavy RAM/CPU) =====
sc config WSearch start= disabled
sc stop WSearch >nul 2>&1

:: ===== 7. SUPERFETCH / SysMain =====
sc config SysMain start= disabled
sc stop SysMain >nul 2>&1

:: ===== 8. WINDOWS UPDATE (set to manual only) =====
sc config wuauserv start= demand
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

:: ===== 9. DISABLE SCHEDULED TASKS =====
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable >nul 2>&1

:: ===== 10. SCHEDULE.TASKS VIA REGISTRY (broad disable) =====
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v DisableAutomaticDesktopBrowse /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f

:: ===== 11. VISUAL EFFECTS (Performance mode) =====
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_DWORD /d 0 /f

:: ===== 12. TRANSPARENCY & ANIMATIONS =====
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f

:: ===== 13. POWER =====
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /setacvalueindex scheme_current sub_processor PERFINCTIME 0
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100
powercfg /setactive scheme_current

:: ===== 14. MMCSS NETWORK =====
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d ffffffff /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f

:: ===== 15. GAME DVR (causes real frame drops) =====
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f

:: ===== 16. CLEAN TEMP FILES =====
del /q /f /s "%TEMP%\*" >nul 2>&1
del /q /f /s "C:\Windows\Temp\*" >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1

echo.
echo ============================================
echo   DONE. Reboot now.
echo ============================================
pause