@echo off
setlocal enabledelayedexpansion
title Open Source Batch Driver Updater (Robust Version)
color 0A

:: ========================================================
:: CHECK FOR ADMINISTRATOR PRIVILEGES
:: ========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ========================================================
    echo  [!] ERROR: ADMINISTRATOR RIGHTS REQUIRED
    echo ========================================================
    echo  This script requires elevated permissions to manage drivers.
    echo  Please right-click 'open_driver_updater.bat' and select:
    echo  "Run as administrator".
    echo ========================================================
    pause
    exit /b
)

:MENU
cls
color 0A
echo ========================================================
echo           OPEN SOURCE WINDOWS DRIVER UPDATER
echo ========================================================
echo  [1] Backup All Current Drivers
echo  [2] Create System Restore Point (Safe)
echo  [3] Scan Hardware IDs (HWIDs)
echo  [4] Install Driver from Folder (.inf)
echo  [5] Trigger Windows PnP Hardware Rescan
echo  [6] Exit
echo ========================================================
set /p CHOICE="Select an option (1-6): "

if "%CHOICE%"=="1" goto BACKUP
if "%CHOICE%"=="2" goto RESTORE_POINT
if "%CHOICE%"=="3" goto SCAN_HW
if "%CHOICE%"=="4" goto INSTALL_DRIVER
if "%CHOICE%"=="5" goto RESCAN
if "%CHOICE%"=="6" exit
goto MENU

:: ========================================================
:: 1. BACKUP DRIVERS
:: ========================================================
:BACKUP
cls
echo [*] Backing up all installed drivers to 'C:\DriverBackup'...
if not exist "C:\DriverBackup" mkdir "C:\DriverBackup"

pnputil /export-driver * "C:\DriverBackup" >nul 2>&1

if %errorlevel% equ 0 (
    echo [+] Drivers successfully backed up to C:\DriverBackup
) else (
    echo [!] Warning: Some drivers could not be exported, or backup finished with minor errors.
)
pause
goto MENU

:: ========================================================
:: 2. CREATE SYSTEM RESTORE POINT
:: ========================================================
:RESTORE_POINT
cls
echo [*] Attempting to create System Restore Point...
echo [*] (This may take a moment. If System Protection is disabled, it will be skipped gracefully.)

:: Try to enable system restore on C: and create a checkpoint, suppressing red error text if it fails
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'Pre-Driver Update Backup' -RestorePointType 'DEVICE_DRIVER_INSTALL' -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1

if %errorlevel% equ 0 (
    echo [+] System Restore point created successfully.
) else (
    echo [-] System Restore is disabled by your OS or unavailable. Skipping to prevent crash.
)
pause
goto MENU

:: ========================================================
:: 3. SCAN HARDWARE IDs
:: ========================================================
:SCAN_HW
cls
echo [*] Fetching Hardware Devices and IDs...
echo --------------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | Where-Object {$_.Status -eq 'OK'} | Select-Object FriendlyName, InstanceId | Format-Table -AutoSize"
echo --------------------------------------------------------
echo [*] Full driver inventory saved silently to 'hwid_log.txt'.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | Select-Object FriendlyName, InstanceId, Status | Out-File -FilePath 'hwid_log.txt' -ErrorAction SilentlyContinue"
pause
goto MENU

:: ========================================================
:: 4. INSTALL DRIVER (.INF)
:: ========================================================
:INSTALL_DRIVER
cls
echo [*] Install Driver Package
echo.
set /p DRIVER_PATH="Enter full folder path containing driver .inf files: "

:: Remove any accidental double quotes the user might have pasted
set DRIVER_PATH=%DRIVER_PATH:"=%

if not exist "%DRIVER_PATH%" (
    echo [!] Error: The folder "%DRIVER_PATH%" does not exist.
    pause
    goto MENU
)

echo.
echo [*] Attempting safe System Restore point first...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Checkpoint-Computer -Description 'Pre-Driver Install' -RestorePointType 'DEVICE_DRIVER_INSTALL' -ErrorAction Stop } catch { }" >nul 2>&1

echo [*] Installing drivers using PnPUtil...
pnputil /add-driver "%DRIVER_PATH%\*.inf" /subdirs /install

:: Handle standard success (0) and reboot required (3010)
if %errorlevel% equ 0 (
    echo.
    echo [+] Driver installation complete!
) else if %errorlevel% equ 3010 (
    echo.
    echo [+] Driver installation complete, but a REBOOT is required!
) else (
    echo.
    echo [!] Driver installation finished, but some drivers failed to install. Check for incompatible files.
)
pause
goto MENU

:: ========================================================
:: 5. RESCAN HARDWARE
:: ========================================================
:RESCAN
cls
echo [*] Rescanning hardware for changes...
pnputil /scan-devices >nul 2>&1
echo [+] Device scan complete.
pause
goto MENU
