@echo off
setlocal enabledelayedexpansion
title Automated ISO Installer Tool with Loading Bar

echo ====================================================
echo   AUTOMATED ISO INSTALLER TOOL
echo ====================================================
echo.

:: 1. Check Processor Architecture
echo [INFO] Checking system architecture...
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo [STATUS] Detected 64-bit Processor (AMD64/Intel64).
    set "ARCH=x64"
) else (
    echo [STATUS] Detected 32-bit Processor (x86).
    set "ARCH=x86"
)
echo.

:MAIN_MENU
echo ====================================================
echo   SELECT CATEGORY
echo ====================================================
echo  1) Windows
echo  2) Exit
echo ====================================================
set /p "CAT_CHOICE=Select an option (1-2): "

if "%CAT_CHOICE%"=="1" goto WINDOWS_MENU
if "%CAT_CHOICE%"=="2" goto END
echo [INVALID] Invalid option, please try again.
pause
cls
goto MAIN_MENU

:WINDOWS_MENU
cls
echo ====================================================
echo   WINDOWS CATEGORY - SELECT OS VERSION
echo ====================================================
echo  1) Windows 95
echo  2) Windows 98
echo  3) Windows ME
echo  4) Windows XP
echo  5) Windows Vista
echo  6) Windows 7
echo  7) Windows 8
echo  8) Windows 8.1
echo  9) Windows 10
echo  10) Windows 11
echo  11) Atlas OS (windows optimized)
echo  12) Go Back
echo ====================================================
set /p "OS_CHOICE=Select your OS version (1-12): "

set "LEGACY_OS=0"

if "%OS_CHOICE%"=="1" set "SELECTED_OS=Windows 95" & set "LEGACY_OS=1" & goto GET_ISO
if "%OS_CHOICE%"=="2" set "SELECTED_OS=Windows 98" & set "LEGACY_OS=1" & goto GET_ISO
if "%OS_CHOICE%"=="3" set "SELECTED_OS=Windows ME" & set "LEGACY_OS=1" & goto GET_ISO
if "%OS_CHOICE%"=="4" set "SELECTED_OS=Windows XP" & goto GET_ISO
if "%OS_CHOICE%"=="5" set "SELECTED_OS=Windows Vista" & goto GET_ISO
if "%OS_CHOICE%"=="6" set "SELECTED_OS=Windows 7" & goto GET_ISO
if "%OS_CHOICE%"=="7" set "SELECTED_OS=Windows 8" & goto GET_ISO
if "%OS_CHOICE%"=="8" set "SELECTED_OS=Windows 8.1" & goto GET_ISO
if "%OS_CHOICE%"=="9" set "SELECTED_OS=Windows 10" & goto GET_ISO
if "%OS_CHOICE%"=="10" set "SELECTED_OS=Windows 11" & goto GET_ISO
if "%OS_CHOICE%"=="11" set "SELECTED_OS=Atlas OS (windows optimized)" & goto GET_ISO
if "%OS_CHOICE%"=="12" cls & goto MAIN_MENU

echo [INVALID] Invalid option, please try again.
pause
goto WINDOWS_MENU

:GET_ISO
cls
echo ====================================================
echo   TARGET OS: %SELECTED_OS%
echo ====================================================
echo.

if "%LEGACY_OS%"=="1" (
    echo ****************************************************
    echo   WARNING: RESOLUTION SCALING ISSUE DETECTED
    echo ****************************************************
    echo   You have selected a legacy operating system.
    echo   These systems do not natively support high-DPI
    echo   or modern screen resolution scaling. 
    echo.
    echo   The installation window or desktop might appear
    echo   extremely small or distorted in Windows Sandbox.
    echo   You may need to manually adjust your sandbox or
    echo   host resolution to interact with it properly.
    echo ****************************************************
    echo.
    pause
    echo.
)

set /p "ISO_PATH=Drag and drop your %SELECTED_OS% ISO file here and press Enter: "
set "ISO_PATH=%ISO_PATH:"=%"

if not exist "%ISO_PATH%" (
    echo [ERROR] File does not exist at the specified path!
    pause
    goto GET_ISO
)

echo.
echo [INFO] Mounting ISO image: %ISO_PATH%...
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "(Mount-DiskImage -ImagePath '%ISO_PATH%' -PassThru | Get-Volume).DriveLetter"') do (
    set "DRIVE_LETTER=%%i"
)

if "%DRIVE_LETTER%"=="" (
    echo [ERROR] Failed to mount the ISO. Please ensure you ran this script as Administrator.
    goto END
)

set "MOUNTED_DRIVE=%DRIVE_LETTER%:"
echo [SUCCESS] ISO mounted successfully to drive %MOUNTED_DRIVE%
echo.

:: 5. Loading Bar Section (# Squares)
echo Preparing installation files for %SELECTED_OS%...
set "BAR="
for /L %%A in (1,1,20) do (
    set "BAR=!BAR!#"
    cls
    echo ====================================================
    echo   PREPARING INSTALLATION
    echo ====================================================
    echo.
    echo   Loading: [!BAR!                     ]
    echo.
    echo ====================================================
    timeout /t 1 >nul
)
cls

:: 6. Launch the Installer
echo [INFO] Launching setup for %SELECTED_OS% from drive %MOUNTED_DRIVE%...

if exist "%MOUNTED_DRIVE%\setup.exe" (
    echo [LAUNCHING] Starting setup.exe...
    start "" "%MOUNTED_DRIVE%\setup.exe"
) else (
    echo [ERROR] setup.exe was not found inside this ISO file.
)

:END
echo.
echo Press any key to exit...
pause >nul
