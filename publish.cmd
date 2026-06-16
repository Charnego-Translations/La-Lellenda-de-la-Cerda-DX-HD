@echo off
setlocal enabledelayedexpansion

set CONFIGURATION=Release
set PUBLISH_DIR=Publish
set CSPROJ=ProjectZ.csproj

echo === Publishing La Lellenda de la Cerda DX HD ===
echo.

where dotnet >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: .NET SDK not found. Install it from https://dotnet.microsoft.com/download
    exit /b 1
)

echo   Cleaning %PUBLISH_DIR%...
if exist "%PUBLISH_DIR%" rmdir /s /q "%PUBLISH_DIR%"

for %%r in (win-x64 linux-x64 osx-x64 osx-arm64) do (
    set "OUTPUT=%PUBLISH_DIR%\%%r"
    echo   Publishing for %%r...
    dotnet publish "%CSPROJ%" -c "%CONFIGURATION%" -r %%r --self-contained true ^
        -p:PublishSingleFile=true -p:PublishTrimmed=false ^
        -o "!OUTPUT!"
    if !errorlevel! equ 0 (
        echo   Copying content...
        if exist "Data" xcopy /e /i /y "Data" "!OUTPUT!\Data\" >nul
        if exist "bin\%CONFIGURATION%\net8.0\Content" (
            xcopy /e /i /y "bin\%CONFIGURATION%\net8.0\Content" "!OUTPUT!\Content\" >nul
        ) else if exist "Content\bin\DesktopGL\Content" (
            xcopy /e /i /y "Content\bin\DesktopGL\Content" "!OUTPUT!\Content\" >nul
        )
        echo   %%r SUCCESS
    ) else (
        echo   %%r FAILED
    )
    echo.
)

echo === Done ===
