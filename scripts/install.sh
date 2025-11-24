#!/bin/bash

# ---------------------------------------------
# Determine install directory
# ---------------------------------------------
DEFAULT_INSTALL_DIR="$HOME/.local/bin"
echo "Installing Rune"
echo ""
echo "Default installation directory: $DEFAULT_INSTALL_DIR"
read -p "Enter custom installation path (or press Enter for default): " CUSTOM_PATH

if [ -z "$CUSTOM_PATH" ]; then
    INSTALL_DIR="$DEFAULT_INSTALL_DIR"
else
    INSTALL_DIR="$CUSTOM_PATH"
fi

CLONE_DIR="/tmp/rune-install-$$"
REPO_URL="https://github.com/dalapierre/rune.git"

echo ""
echo "Rune will be installed at $INSTALL_DIR"
read -p "Do you wish to proceed? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Installation cancelled."
    exit 0
fi
echo ""

# ---------------------------------------------
# Check Git installation
# ---------------------------------------------
if ! command -v git &> /dev/null; then
    echo ""
    echo "Error: Git is not installed or not in PATH."
    echo "Please install Git and try again."
    exit 1
fi

# ---------------------------------------------
# Ensure install directory exists
# ---------------------------------------------
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    if [ $? -ne 0 ]; then
        echo ""
        echo "Failed to create installation directory"
        exit 1
    fi
fi

# ---------------------------------------------
# Remove previous clone
# ---------------------------------------------
if [ -d "$CLONE_DIR" ]; then
    echo ""
    echo "Removing old temporary files..."
    rm -rf "$CLONE_DIR"
fi

# ---------------------------------------------
# Clone repository
# ---------------------------------------------
echo "Cloning Rune repository"
git clone --quiet "$REPO_URL" "$CLONE_DIR"
if [ $? -ne 0 ]; then
    echo ""
    echo "Failed to clone repository"
    exit 1
fi

# ---------------------------------------------
# Run the build script
# ---------------------------------------------
cd "$CLONE_DIR"
bash scripts/build.sh
if [ $? -ne 0 ]; then
    echo ""
    echo "Build failed"
    exit 1
fi

# ---------------------------------------------
# Check that rune binary was built
# ---------------------------------------------
if [ ! -f "$CLONE_DIR/bin/rune" ]; then
    echo ""
    echo "Error: Build succeeded but rune not found in bin directory"
    exit 1
fi

# ---------------------------------------------
# Copy final binary
# ---------------------------------------------
echo "Installing rune to $INSTALL_DIR..."
cp "$CLONE_DIR/bin/rune" "$INSTALL_DIR/rune" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo ""
    echo "Failed to copy binary"
    rm -rf "$CLONE_DIR"
    exit 1
fi

# Make it executable
chmod +x "$INSTALL_DIR/rune"

# ---------------------------------------------
# Cleanup clone
# ---------------------------------------------
echo "Clean up..."
rm -rf "$CLONE_DIR"

echo ""
echo "Installation complete"
echo "Don't forget to add $INSTALL_DIR to your PATH to use rune from anywhere."