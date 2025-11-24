#!/bin/bash

# Read version from rune.json in current directory
VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' rune.json | sed 's/.*"\([^"]*\)".*/\1/')

# Ensure bin directory exists
if [ ! -d "bin" ]; then
    mkdir "bin"
fi

# Run the build
echo "Building Rune version $VERSION"
odin build "src" -out:"bin/rune" -collection:rune=src/ -define:VERSION=$VERSION