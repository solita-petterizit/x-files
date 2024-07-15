#!/usr/bin/env bash

# Fail fast
set -euo pipefail

# Ensure we are working in the correct directory (repo root)
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$SCRIPT_DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
REPO_ROOT=$(realpath "$SCRIPT_DIR/..")

# Make a destination directory
DEST_DIR="$REPO_ROOT/build"
echo "Ensuring $DEST_DIR exists"
mkdir -p "$REPO_ROOT/build"

# Set go build environment
export GOOS=linux
export GOARCH=amd64
export CGO_ENABLED=0
APP_DIR="$REPO_ROOT/app"
pushd "$APP_DIR" > /dev/null || exit 1
    CWD=$(pwd)
    # Build the binary
    echo "Building application ($CWD/main.go) for: $GOOS/$GOARCH (Cgo: $CGO_ENABLED)"
    go build -o "$DEST_DIR/app" "main.go"

    # Copy assets
    echo "Copying assets from $CWD to $DEST_DIR"
    cp "index.html" "$DEST_DIR/index.html"
    cp "styles.css" "$DEST_DIR/styles.css"
popd > /dev/null || exit 1

echo "Done. Build output:"
ls -laR "$DEST_DIR"
echo "******************************************************"
echo "Run in debug mode: $DEST_DIR/app"
echo "Run in production mode: GIN_MODE=release $DEST_DIR/app"
echo "******************************************************"
