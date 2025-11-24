@echo off
setlocal enabledelayedexpansion

rem Parse command line arguments
set CUSTOM_PATH=
set SHOW_HELP=

:parse_args
if "%~1"=="" goto :done_parsing
if /i "%~1"=="-h" (
    set SHOW_HELP=1
    shift
    goto :parse_args
)
if /i "%~1"=="--help" (
    set SHOW_HELP=1
    shift
    goto :parse_args
)
if /i "%~1"=="-p" (
    set CUSTOM_PATH=%~2
    shift
    shift
    goto :parse_args
)
shift
goto :parse_args
:done_parsing

rem Show help if requested
if defined SHOW_HELP (
    echo.
    echo This script installs Rune by:
    echo   1. Cloning the Rune repository
    echo   2. Builds the project using build.bat or build.sh
    echo   3. Copying executable to the installation directory
    echo   4. Cleaning up the cloned repository
    echo.
    echo Usage:
    echo   install.bat [OPTIONS]
    echo.
    echo Options:
    echo   -h, --help          Show this help message
    echo   -p PATH             Install to a custom directory
    echo.
    echo Examples:
    echo   install.bat                           Install to %%LOCALAPPDATA%%\Rune
    echo   install.bat -p D:\tools\rune          Install to D:\dev\tools\rune
    echo.
    echo After installation, add the installation directory to your PATH to use 'rune' from anywhere.
    exit /b 0
)

rem Define directories
if defined CUSTOM_PATH (
    set INSTALL_DIR=%CUSTOM_PATH%
) else (
    set INSTALL_DIR=%LOCALAPPDATA%\Rune
)
set CLONE_DIR=%INSTALL_DIR%\Rune
set REPO_URL=https://github.com/ametyx/rune.git

echo.
echo Rune will be installed at %INSTALL_DIR%
set /p CONFIRM="Do you wish to proceed? [y/N]: "
if /i not "%CONFIRM%"=="y" (
    echo.
    echo Installation cancelled.
    exit /b 0
)
echo.

rem Check if git is installed
git --version >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo Error: Git is not installed or not in PATH.
    echo Please install Git and try again.
    exit /b 1
)

rem Create installation directory if it doesn't exist
if not exist "%INSTALL_DIR%" (
    echo Creating installation directory...
    mkdir "%INSTALL_DIR%"
    if !errorLevel! neq 0 (
        echo.
        echo Failed to create installation directory
        exit /b 1
    )
)

rem Remove old clone if it exists
if exist "%CLONE_DIR%" (
    echo.
    echo Removing old installation...
    rmdir /s /q "%CLONE_DIR%"
)

rem Clone the repository
echo Cloning Rune repository
git clone --quiet "%REPO_URL%" "%CLONE_DIR%"
if !errorLevel! neq 0 (
    echo.
    echo Failed to clone repository
    exit /b 1
)

rem Run the build script
cd /d "%CLONE_DIR%"
call scripts\build.bat
if !errorLevel! neq 0 (
    echo.
    echo Build failed
    exit /b 1
)

rem Check if the binary was built
if not exist "%CLONE_DIR%\bin\rune.exe" (
    echo.
    echo Error: Build succeeded but rune.exe not found in bin directory
    exit /b 1
)

rem Copy the binary to installation directory
copy /Y "%CLONE_DIR%\bin\rune.exe" "%INSTALL_DIR%\rune.exe" >nul
if !errorLevel! neq 0 (
    echo.
    echo Failed to copy binary
    exit /b 1
)

rem Delete the cloned repository
cd /d "%INSTALL_DIR%"
rmdir /s /q "%CLONE_DIR%"

echo.
echo Installation complete