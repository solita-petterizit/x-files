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

APP_DIR="$REPO_ROOT/app"
pushd "$APP_DIR" > /dev/null || exit 1
    CWD=$(pwd)
    # Build the binary
    echo "Testing application $CWD"
    go test . -v
popd > /dev/null || exit 1

