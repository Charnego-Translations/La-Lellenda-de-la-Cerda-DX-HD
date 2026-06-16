#!/bin/bash

CONFIGURATION="Release"
PUBLISH_DIR="Publish"
CSPROJ="ProjectZ.csproj"
APP_NAME="La Lellenda de la Cerda DX HD"

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

echo "=== Publishing $APP_NAME ==="
echo ""

echo "  Cleaning $PUBLISH_DIR..."
rm -rf "$PUBLISH_DIR"

copy_content() {
    local output=$1
    # Copy Data (raw assets)
    if [ -d "Data" ]; then
        cp -R "Data/" "$output/Data/"
    fi
    # Copy Content (compiled .xnb files)
    # First try build output, then fall back to MGCB cache
    if [ -d "bin/$CONFIGURATION/net8.0/Content" ]; then
        cp -R "bin/$CONFIGURATION/net8.0/Content/" "$output/Content/"
    elif [ -d "Content/bin/DesktopGL/Content" ]; then
        cp -R "Content/bin/DesktopGL/Content/" "$output/Content/"
    fi
}

publish_rid() {
    local rid=$1
    local output="$PUBLISH_DIR/$rid"
    echo "  Publishing for $rid..."
    if dotnet publish "$CSPROJ" -c "$CONFIGURATION" -r "$rid" --self-contained true \
        -p:PublishSingleFile=true -p:PublishTrimmed=false \
        -o "$output"; then
        echo "  Copying content..."
        copy_content "$output"
        echo "  $rid SUCCESS"
    else
        echo "  $rid FAILED"
    fi
    echo ""
}

create_app_bundle() {
    local rid=$1
    local published="$PUBLISH_DIR/$rid"
    local app_bundle="$PUBLISH_DIR/$APP_NAME.app"
    local contents="$app_bundle/Contents"
    local macos_dir="$contents/MacOS"
    local resources_dir="$contents/Resources"

    if [ ! -f "$published/$APP_NAME" ] && [ ! -f "$published/$APP_NAME.exe" ]; then
        echo "  ERROR: no published output found for $rid. Run publish first."
        return 1
    fi

    echo "  Creating .app bundle for $rid..."
    rm -rf "$app_bundle"
    mkdir -p "$macos_dir" "$resources_dir"

    cp -R "$published/" "$macos_dir/"

    local icon_source="Resources/Icon.icns"
    local icon_name="AppIcon"
    if [ -f "$icon_source" ]; then
        cp "$icon_source" "$resources_dir/$icon_name.icns"
    else
        echo "  Warning: Resources/Icon.icns not found. Using default icon."
    fi

    cat > "$contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>$icon_name</string>
    <key>CFBundleIdentifier</key>
    <string>com.cerda.$APP_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

    chmod +x "$macos_dir/$APP_NAME"
    echo "  Created: $app_bundle"
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
    native)  publish_native ;;
    cross)   publish_cross ;;
    bundle)
        if [ -n "$2" ]; then
            publish_rid "$2" && create_app_bundle "$2"
        else
            case "$(uname -s)" in
                Darwin)
                    local rid="osx-arm64"
                    publish_rid "$rid" && create_app_bundle "$rid"
                    ;;
                *)
                    echo "  bundle is only supported on macOS."
                    exit 1
                    ;;
            esac
        fi
        ;;
    all)
        publish_native
        echo "--- Cross-compilation targets ---"
        publish_cross
        if [ "$(uname -s)" = "Darwin" ]; then
            echo "--- Creating .app bundle ---"
            create_app_bundle "osx-arm64"
        fi
        ;;
    *)
        echo "Usage: $0 [native|cross|bundle [rid]|all]"
        echo "  native  - publish for current platform only"
        echo "  cross   - publish for all platforms"
        echo "  bundle  - publish + create .app bundle (macOS only)"
        echo "  all     - native + cross + bundle (default)"
        exit 1
        ;;
esac

echo "=== Done ==="
