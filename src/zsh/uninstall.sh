#!/usr/bin/env zsh

set -e 

BIN_NAME="cntc"
TARGET_DIR="$HOME/.local/bin"
LINK_PATH="$TARGET_DIR/$BIN_NAME"

if [ -L "$LINK_PATH" ]; then
    rm -f "$LINK_PATH"
    echo "Uninstalled $BIN_NAME from $TARGET_DIR"
else
    echo "No installation found for $BIN_NAME in $TARGET_DIR"
fi