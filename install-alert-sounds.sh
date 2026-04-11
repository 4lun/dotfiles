#!/bin/bash
# Install custom alert sounds to ~/Library/Sounds

if [[ "$(uname)" != "Darwin" ]]; then
	echo "This script is macOS only (~/Library/Sounds doesn't exist elsewhere)." >&2
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/sounds"
TARGET_DIR="$HOME/Library/Sounds"

mkdir -p "$TARGET_DIR"
cp -f "$SOURCE_DIR"/*.aiff "$TARGET_DIR/"

echo "Alert sounds installed to $TARGET_DIR"
