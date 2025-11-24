#!/bin/bash

# Parse command line arguments
CUSTOM_PATH=""
SHOW_HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        -p)
            CUSTOM_PATH="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Show help if requested
if [ "$SHOW_HELP" = true ]; then
    echo ""
    echo "This script installs Rune by:"
    echo "  1. Cloning the Rune repository"
    echo "  2. Builds the project using build.bat or build.sh"
    echo "  3. Copying executable to the installation directory"
    echo "  4. Cleaning up the cloned repository"
    echo ""
    echo "Usage:"
    echo "  install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -p PATH             Install to a custom directory"
    echo ""
    echo "Examples:"
    echo "  install.sh                           Install to ~/.local/bin"
    echo "  install.sh -p /usr/local/bin         Install to /usr/local/bin (requires sudo)"
    echo ""
    echo "After installation, add the installation directory to your PATH to use 'rune' from anywhere."
    exit 0
fi

# Define directories
if [ -n "$CUSTOM_PATH" ]; then
    INSTALL_DIR="$CUSTOM_PATH"
else
    INSTALL_DIR="$HOME/.local/bin"
fi

CLONE_DIR="/tmp/rune-install-$"
REPO_URL="https://github.com/ametyx/rune.git"

echo ""
echo "Rune will be installed at $INSTALL_DIR"
read -p "Do you wish to proceed? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Installation cancelled."
    exit 0
fi
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo ""
    echo "Error: Git is not installed or not in PATH."
    echo "Please install Git and try again."
    exit 1
fi

# Create installation directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    if [ $? -ne 0 ]; then
        echo ""
        echo "Failed to create installation directory"
        exit 1
    fi
fi

# Remove old clone if it exists
if [ -d "$CLONE_DIR" ]; then
    echo ""
    echo "Removing old temporary files..."
    rm -rf "$CLONE_DIR"
fi

# Clone the repository
echo "Cloning Rune repository"
git clone --quiet "$REPO_URL" "$CLONE_DIR"
if [ $? -ne 0 ]; then
    echo ""
    echo "Failed to clone repository"
    exit 1
fi

# Run the build script
cd "$CLONE_DIR"
bash scripts/build.sh
if [ $? -ne 0 ]; then
    echo ""
    echo "Build failed"
    exit 1
fi

# Check if the binary was built
if [ ! -f "$CLONE_DIR/bin/rune" ]; then
    echo ""
    echo "Error: Build succeeded but rune not found in bin directory"
    exit 1
fi

# Copy the binary to installation directory
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

# Delete the cloned repository
rm -rf "$CLONE_DIR"

echo ""
echo "Installation complete"