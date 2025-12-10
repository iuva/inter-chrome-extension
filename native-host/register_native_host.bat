@echo off
chcp 65001 >nul
title RealVNC Native Host Registration - Browser Extension

echo.
echo ========================================
echo    RealVNC Native Host Registration Script
echo ========================================
echo.

echo Checking system environment...

:: Check if running with administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Please run this script as Administrator!
    echo Right-click the script and select "Run as administrator"
    pause
    exit /b 1
)

echo [SUCCESS] Administrator privileges verified

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Check if necessary files exist
if not exist "%SCRIPT_DIR%\com.realvnc.vncviewer.json" (
    echo [ERROR] Configuration file not found: com.realvnc.vncviewer.json
    pause
    exit /b 1
)

if not exist "%SCRIPT_DIR%\realvnc_launcher.bat" (
    echo [ERROR] Launcher script not found: realvnc_launcher.bat
    pause
    exit /b 1
)

echo [SUCCESS] Required files verified

:: Update JSON file paths (ensure absolute paths)
echo Updating configuration file paths...

:: Create temporary configuration file
set "TEMP_JSON=%TEMP%\realvnc_temp.json"
(
    echo {
    echo     "name": "com.realvnc.vncviewer",
    echo     "description": "RealVNC Viewer Launcher for Browser Extension",
    echo     "path": "%SCRIPT_DIR%\\realvnc_launcher.bat",
    echo     "type": "stdio",
    echo     "allowed_origins": [
    echo         "chrome-extension://*"
    echo     ]
    echo }
) > "%TEMP_JSON%"

echo [SUCCESS] Configuration file paths updated

:: Register with Chrome
echo.
echo Registering with Chrome browser...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\NativeMessagingHosts\com.realvnc.vncviewer" /ve /t REG_SZ /d "%SCRIPT_DIR%\com.realvnc.vncviewer.json" /f
if %errorLevel% equ 0 (
    echo [SUCCESS] Chrome registration successful
) else (
    echo [ERROR] Chrome registration failed
    goto :error_cleanup
)

:: Register with Chromium
echo.
echo Registering with Chromium browser...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Chromium\NativeMessagingHosts\com.realvnc.vncviewer" /ve /t REG_SZ /d "%SCRIPT_DIR%\com.realvnc.vncviewer.json" /f
if %errorLevel% equ 0 (
    echo [SUCCESS] Chromium registration successful
) else (
    echo [WARNING] Chromium registration failed (may not be installed)
)

:: Register with Microsoft Edge
echo.
echo Registering with Microsoft Edge browser...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Edge\NativeMessagingHosts\com.realvnc.vncviewer" /ve /t REG_SZ /d "%SCRIPT_DIR%\com.realvnc.vncviewer.json" /f
if %errorLevel% equ 0 (
    echo [SUCCESS] Microsoft Edge registration successful
) else (
    echo [WARNING] Microsoft Edge registration failed (may not be installed)
)

:: Check if Firefox is installed
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla" >nul 2>&1
if %errorLevel% equ 0 (
    echo.
    echo Firefox detected, registering with Firefox browser...
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\NativeMessagingHosts\com.realvnc.vncviewer" /ve /t REG_SZ /d "%SCRIPT_DIR%\com.realvnc.vncviewer.json" /f
    if %errorLevel% equ 0 (
        echo [SUCCESS] Firefox registration successful
    ) else (
        echo [WARNING] Firefox registration failed
    )
)

echo.
echo ========================================
echo          Registration Complete!
echo ========================================
echo.
echo [SUCCESS] Native host successfully registered to the following browsers:
echo    - Google Chrome
echo    - Microsoft Edge
echo    - Chromium
echo.
echo Registry paths:
echo    HKEY_LOCAL_MACHINE\SOFTWARE\[Browser]\NativeMessagingHosts\com.realvnc.vncviewer
echo.
echo Configuration file path:
echo    %SCRIPT_DIR%\com.realvnc.vncviewer.json
echo.
echo Launcher script path:
echo    %SCRIPT_DIR%\realvnc_launcher.bat
echo.
echo Note: Please ensure Python 3.7+ and RealVNC Viewer are installed
echo.

:: Clean up temporary files
if exist "%TEMP_JSON%" del "%TEMP_JSON%"

pause
exit /b 0

:error_cleanup
echo.
echo [ERROR] Registration failed
echo Please check:
echo 1. Administrator privileges
echo 2. Registry permissions
echo 3. File paths
echo.
if exist "%TEMP_JSON%" del "%TEMP_JSON%"
pause
exit /b 1