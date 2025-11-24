@echo off
setlocal enabledelayedexpansion

rem Read version from rune.json in current directory (where script was called from)
for /f "tokens=2 delims=:, " %%a in ('type "rune.json" ^| findstr /C:"\"version\""') do (
    set VERSION=%%a
)

rem Remove quotes from version string
set VERSION=%VERSION:"=%

rem Ensure bin directory exists
if not exist "bin" (
    mkdir "bin"
)

rem Run the build
echo Building Rune version %VERSION%
odin build "src" -out:"bin/rune.exe" -debug -collection:rune=src/ -define:VERSION=%VERSION%