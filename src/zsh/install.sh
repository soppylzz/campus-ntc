#!/usr/bin/env zsh

set -e 

BIN_NAME="cntc"
TARGET_DIR="$HOME/.local/bin"
SRC_PATH="${${(%):-%x}:A:h}/bin/$BIN_NAME"

mkdir -p "$TARGET_DIR"

ln -sf "$SRC_PATH" "$TARGET_DIR/$BIN_NAME"

echo "Installed $BIN_NAME to $TARGET_DIR"
echo "Make sure $TARGET_DIR is in your PATH."