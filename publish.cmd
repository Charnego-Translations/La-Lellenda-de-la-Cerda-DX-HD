@echo off
setlocal enabledelayedexpansion

set CONFIGURATION=Release
set PUBLISH_DIR=Publish
set CSPROJ=ProjectZ.csproj

echo === Publishing La Lellenda de la Cerda DX HD ===
echo.

for %%r in (win-x64 linux-x64 osx-x64 osx-arm64) do (
    echo   Publishing for %%r...
    dotnet publish "%CSPROJ%" -c "%CONFIGURATION%" -r %%r --self-contained true ^
        -p:PublishSingleFile=true -p:PublishTrimmed=false ^
        -o "%PUBLISH_DIR%\%%r"
    if !errorlevel! equ 0 (
        echo   %%r SUCCESS
    ) else (
        echo   %%r FAILED
    )
    echo.
)

echo === Done ===
