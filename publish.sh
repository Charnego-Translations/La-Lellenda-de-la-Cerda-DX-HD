#!/bin/bash
set -e

CONFIGURATION="Release"
PUBLISH_DIR="Publish"
CSPROJ="ProjectZ.csproj"

echo "=== Publishing La Lellenda de la Cerda DX HD ==="
echo ""

publish_rid() {
    local rid=$1
    local output="$PUBLISH_DIR/$rid"
    echo "  Publishing for $rid..."
    dotnet publish "$CSPROJ" -c "$CONFIGURATION" -r "$rid" --self-contained true \
        -p:PublishSingleFile=true -p:PublishTrimmed=false \
        -o "$output"
    if [ $? -eq 0 ]; then
        echo "  $rid SUCCESS"
    else
        echo "  $rid FAILED"
    fi
    echo ""
}

case "$(uname -s)" in
    Darwin)
        publish_rid "osx-arm64"
        publish_rid "osx-x64"
        publish_rid "win-x64"
        publish_rid "linux-x64"
        ;;
    Linux)
        publish_rid "linux-x64"
        publish_rid "win-x64"
        publish_rid "osx-x64"
        publish_rid "osx-arm64"
        ;;
    *)
        publish_rid "win-x64"
        publish_rid "linux-x64"
        publish_rid "osx-x64"
        publish_rid "osx-arm64"
        ;;
esac

echo "=== Done ==="
