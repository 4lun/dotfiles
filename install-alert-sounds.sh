#!/bin/bash
# Install custom alert sounds to ~/Library/Sounds

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/sounds"
TARGET_DIR="$HOME/Library/Sounds"

mkdir -p "$TARGET_DIR"
cp -f "$SOURCE_DIR"/*.aiff "$TARGET_DIR/"

echo "Alert sounds installed to $TARGET_DIR"
