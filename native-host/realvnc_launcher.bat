@echo off
REM RealVNC Launcher Native Messaging Host for Windows
REM This batch file launches the Python script for native messaging

setlocal

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Try to find Python executable
set "PYTHON_EXE="

REM Check for Python in common locations
if exist "C:\Python39\python.exe" (
    set "PYTHON_EXE=C:\Python39\python.exe"
) else if exist "C:\Python38\python.exe" (
    set "PYTHON_EXE=C:\Python38\python.exe"
) else if exist "C:\Python37\python.exe" (
    set "PYTHON_EXE=C:\Python37\python.exe"
) else (
    REM Try to use python from PATH
    where python >nul 2>&1
    if %errorlevel% equ 0 (
        set "PYTHON_EXE=python"
    ) else (
        where python3 >nul 2>&1
        if %errorlevel% equ 0 (
            set "PYTHON_EXE=python3"
        ) else (
            echo Python not found. Please install Python 3.7 or later.
            exit /b 1
        )
    )
)

REM Launch the Python script
"%PYTHON_EXE%" "%SCRIPT_DIR%realvnc_launcher.py"

endlocal