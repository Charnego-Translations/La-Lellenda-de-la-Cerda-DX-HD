@echo off
echo Publishing for DesktopGL (cross-platform)...
echo.
echo To publish for Windows x64:
echo   dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o Publish\windows-x64
echo.
echo To publish for Linux x64:
echo   dotnet publish -c Release -r linux-x64 --self-contained true -p:PublishSingleFile=true -o Publish\linux-x64
echo.
echo To publish for macOS Intel:
echo   dotnet publish -c Release -r osx-x64 --self-contained true -p:PublishSingleFile=true -o Publish\osx-x64
echo.
echo To publish for macOS Apple Silicon:
echo   dotnet publish -c Release -r osx-arm64 --self-contained true -p:PublishSingleFile=true -o Publish\osx-arm64
echo.
echo Example:
echo   dotnet publish -c Release -r osx-arm64 --self-contained true -p:PublishSingleFile=true -o Publish\osx-arm64
