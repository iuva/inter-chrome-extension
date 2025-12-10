#!/bin/bash
# RealVNC Launcher Native Messaging Host for macOS/Linux
# This script launches the Python script for native messaging

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to find Python executable
find_python() {
    # Try different Python executables in order of preference
    for python_cmd in python3 python python3.9 python3.8 python3.7; do
        if command -v "$python_cmd" >/dev/null 2>&1; then
            # Check if it's Python 3
            if "$python_cmd" -c "import sys; sys.exit(0 if sys.version_info >= (3, 7) else 1)" 2>/dev/null; then
                echo "$python_cmd"
                return 0
            fi
        fi
    done
    return 1
}

# Find Python executable
PYTHON_EXE=$(find_python)

if [ -z "$PYTHON_EXE" ]; then
    echo "Error: Python 3.7 or later not found. Please install Python 3." >&2
    exit 1
fi

# Make sure the Python script is executable
chmod +x "$SCRIPT_DIR/realvnc_launcher.py"

# Launch the Python script
exec "$PYTHON_EXE" "$SCRIPT_DIR/realvnc_launcher.py"