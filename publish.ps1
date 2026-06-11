param(
    [ValidateSet("windows", "desktopgl", "android", "all")]
    [string]$Target = "all",
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release"
)

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Publish-Windows {
    Write-Host "=== Publishing Windows (DirectX) ===" -ForegroundColor Cyan
    & dotnet publish $RootDir\ProjectZ.csproj -c $Configuration -r win-x64 --self-contained true `
        -p:PublishSingleFile=true -p:PublishTrimmed=false `
        -o $RootDir\Publish\windows-win-x64
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Windows build SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Windows build FAILED" -ForegroundColor Red
    }
}

function Publish-DesktopGL {
    Write-Host "=== Publishing DesktopGL (Linux/macOS) ===" -ForegroundColor Cyan
    
    # Linux x64
    Write-Host "  Building for Linux x64..." -ForegroundColor Yellow
    & dotnet publish $RootDir\ProjectZ.DesktopGL\ProjectZ.DesktopGL.csproj -c $Configuration `
        -r linux-x64 --self-contained true -p:PublishSingleFile=true `
        -o $RootDir\Publish\desktopgl-linux-x64
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Linux build SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "  Linux build FAILED" -ForegroundColor Red
    }

    # macOS x64
    Write-Host "  Building for macOS x64..." -ForegroundColor Yellow
    & dotnet publish $RootDir\ProjectZ.DesktopGL\ProjectZ.DesktopGL.csproj -c $Configuration `
        -r osx-x64 --self-contained true -p:PublishSingleFile=true `
        -o $RootDir\Publish\desktopgl-osx-x64
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  macOS build SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "  macOS build FAILED" -ForegroundColor Red
    }
}

function Publish-Android {
    Write-Host "=== Publishing Android ===" -ForegroundColor Cyan
    & dotnet publish $RootDir\ProjectZ.Android\ProjectZ.Android.csproj -c $Configuration `
        -f net8.0-android -o $RootDir\Publish\android
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Android build SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Android build FAILED (requires Android SDK)" -ForegroundColor Red
    }
}

switch ($Target) {
    "windows"   { Publish-Windows }
    "desktopgl" { Publish-DesktopGL }
    "android"   { Publish-Android }
    "all" {
        Publish-Windows
        Publish-DesktopGL
        Publish-Android
    }
}
