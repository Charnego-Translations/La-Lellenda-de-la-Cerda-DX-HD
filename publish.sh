#!/bin/bash

CONFIGURATION="Release"
PUBLISH_DIR="Publish"
CSPROJ="ProjectZ.csproj"

if ! command -v dotnet &>/dev/null; then
    echo "ERROR: .NET SDK not found. Install it from https://dotnet.microsoft.com/download"
    exit 1
fi

SDK_VERSION=$(dotnet --list-sdks 2>/dev/null | head -1)
if [ -z "$SDK_VERSION" ]; then
    echo "ERROR: .NET SDK not found (only runtime may be installed)."
    echo "Install the .NET 8.0 SDK:"
    echo "  brew install --cask dotnet-sdk"
    echo "Or download from: https://dotnet.microsoft.com/download/dotnet/8.0"
    echo "After installing, verify with: dotnet --list-sdks"
    exit 1
fi
echo "  Using .NET SDK: $SDK_VERSION"

echo "=== Publishing La Lellenda de la Cerda DX HD ==="
echo ""

publish_rid() {
    local rid=$1
    local output="$PUBLISH_DIR/$rid"
    echo "  Publishing for $rid..."
    if dotnet publish "$CSPROJ" -c "$CONFIGURATION" -r "$rid" --self-contained true \
        -p:PublishSingleFile=true -p:PublishTrimmed=false \
        -o "$output"; then
        echo "  $rid SUCCESS"
    else
        echo "  $rid FAILED"
    fi
    echo ""
}

publish_native() {
    case "$(uname -s)" in
        Darwin)  publish_rid "osx-arm64" ;;
        Linux)   publish_rid "linux-x64" ;;
        *)       publish_rid "win-x64" ;;
    esac
}

publish_cross() {
    publish_rid "osx-arm64"
    publish_rid "osx-x64"
    publish_rid "win-x64"
    publish_rid "linux-x64"
}

case "${1:-all}" in
    native) publish_native ;;
    cross)  publish_cross ;;
    all)    publish_native; echo "--- Cross-compilation targets ---"; publish_cross ;;
    *)      echo "Usage: $0 [native|cross|all]"; exit 1 ;;
esac

echo "=== Done ==="
