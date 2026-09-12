@echo off
title Ultimate Windows Cleanup and Maintenance
color 0A

REM ============================================
REM  Self-elevate to Administrator if needed
REM ============================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

REM ============================================
REM  Define variables
REM ============================================
set "SYS=%SystemRoot%"
set "DRV=%SystemDrive%"
set "USER=%USERPROFILE%"
set "LOC=%LocalAppData%"
set "TEMP=%TEMP%"
set "WIN=%SystemRoot%"

echo ============================================
echo  Windows Cleanup and Maintenance Tool
echo  Running as: %USERNAME% on %COMPUTERNAME%
echo ============================================
echo.

REM ============================================
REM  Step 1: Take ownership of protected paths
REM ============================================
echo [1/14] Taking ownership of protected folders...
takeown /f "%LOC%\Microsoft\Windows\Explorer" /r /d y >nul 2>&1
takeown /f "%USERPROFILE%\AppData\Local\Temp" /r /d y >nul 2>&1
takeown /f "%WIN%\TEMP" /r /d y >nul 2>&1
takeown /f "%DRV%\$Recycle.bin" /r /d y >nul 2>&1

REM ============================================
REM  Step 2: Empty the Recycle Bin
REM ============================================
echo [2/14] Emptying the Recycle Bin...
del /q /s "%DRV%\$Recycle.bin\*" >nul 2>&1
for /d %%x in ("%DRV%\$Recycle.bin\*") do rd /s /q "%%x" >nul 2>&1
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
cls

REM ============================================
REM  Step 3: Clear Windows TEMP folder
REM ============================================
echo [3/14] Clearing Windows TEMP folder...
erase /F /S /Q "%WIN%\TEMP\*.*" >nul 2>&1
for /D %%G in ("%WIN%\TEMP\*") do RD /S /Q "%%G" >nul 2>&1
cls

REM ============================================
REM  Step 4: Clear user TEMP folders
REM ============================================
echo [4/14] Clearing user TEMP folders...
for /D %%G in ("%DRV%\Users\*") do (
    erase /F /S /Q "%%G\AppData\Local\Temp\*.*" >nul 2>&1
    rd /S /Q "%%G\AppData\Local\Temp\" >nul 2>&1
    if not exist "%%G\AppData\Local\Temp" md "%%G\AppData\Local\Temp"
)
cls

REM ============================================
REM  Step 5: Clear thumbnail cache
REM ============================================
echo [5/14] Clearing thumbnail cache...
taskkill /F /IM explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
del /F /S /Q /A "%LOC%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
cls

REM ============================================
REM  Step 6: Clear user TEMP (variable form)
REM ============================================
echo [6/14] Clearing user TEMP (alternate paths)...
del /f /s /q "%TEMP%\" >nul 2>&1
del /f /s /q "%TEMP%\*.tmp" >nul 2>&1
del /f /s /q "%TEMP%\*" >nul 2>&1
cls

REM ============================================
REM  Step 7: Clear system-level temp junk
REM ============================================
echo [7/14] Clearing system-level temp files...
del /f /s /q "%DRV%\*.tmp" >nul 2>&1
del /f /s /q "%DRV%\*._mp" >nul 2>&1
del /f /s /q "%DRV%\*.gid" >nul 2>&1
del /f /s /q "%DRV%\*.chk" >nul 2>&1
del /f /s /q "%DRV%\*.old" >nul 2>&1
del /f /s /q "%DRV%\recycled\*.*" >nul 2>&1
del /f /s /q "%DRV%\$Recycle.Bin\*.*" >nul 2>&1
del /f /s /q "%WIN%\*.bak" >nul 2>&1
del /f /s /q "%WIN%\prefetch\*.*" >nul 2>&1
rd /s /q "%WIN%\temp" >nul 2>&1
md "%WIN%\temp" >nul 2>&1
cls

REM ============================================
REM  Step 8: Clear user profile temp files
REM ============================================
echo [8/14] Clearing user profile temp files...
del /f /q "%USER%\cookies\*.*" >nul 2>&1
del /f /q "%USER%\recent\*.*" >nul 2>&1
del /f /s /q "%USER%\Local Settings\Temporary Internet Files\*.*" >nul 2>&1
del /f /s /q "%USER%\Local Settings\Temp\*.*" >nul 2>&1
del /f /s /q "%USER%\recent\*.*" >nul 2>&1
cls

REM ============================================
REM  Step 9: Clear browser caches
REM ============================================
echo [9/14] Clearing browser caches...
del /f /s /q "%LOC%\BraveSoftware\Brave-Browser\User Data\Default\Code Cache\*" >nul 2>&1
del /f /s /q "%LOC%\Google\Chrome\User Data\Default\Code Cache\*" >nul 2>&1
del /f /s /q "%LOC%\Microsoft\Edge\User Data\Default\Code Cache\*" >nul 2>&1
del /f /s /q "%LOC%\Mozilla\Firefox\Profiles\*" >nul 2>&1
timeout /t 2 /nobreak >nul

REM ============================================
REM  Step 10: Clear game cache folders
REM ============================================
echo [10/14] Clearing game cache folders...
del /f /s /q "%LOC%\FortniteGame\Saved\*" >nul 2>&1
del /f /s /q "%LOC%\EpicGamesLauncher\Saved\webcache\*" >nul 2>&1
del /f /s /q "%LOC%\Roblox\Downloads\*" >nul 2>&1
del /f /s /q "%LOC%\Steam\htmlcache\*" >nul 2>&1
cls

REM ============================================
REM  Step 11: Restart Explorer safely
REM ============================================
echo [11/14] Restarting Windows Explorer...
timeout /t 3 /nobreak >nul
powershell -Command "Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue" >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe
cls

REM ============================================
REM  Step 12: Stop Windows Update services and reset
REM ============================================
echo [12/14] Resetting Windows Update cache...
net stop UsoSvc >nul 2>&1
net stop bits >nul 2>&1
net stop dosvc >nul 2>&1
net stop wuauserv >nul 2>&1
rd /s /q "%WIN%\SoftwareDistribution" >nul 2>&1
md "%WIN%\SoftwareDistribution"
cls

REM ============================================
REM  Step 13: Run Disk Cleanup
REM ============================================
echo [13/14] Running Windows Disk Cleanup (cleanmgr)...
start "" /wait "%SystemRoot%\System32\cleanmgr.exe" /sagerun:50
cls

REM ============================================
REM  Step 14: Restart the services we stopped
REM ============================================
echo [14/14] Restarting services...
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
net start UsoSvc >nul 2>&1
net start dosvc >nul 2>&1

echo.
echo ============================================
echo  Cleanup complete.
echo  It is recommended to restart your PC.
echo ============================================
pause
exit
