#!/usr/bin/env bash

set -e
set -o pipefail

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"

# Check the config requirements
CONFIG_FILE=${1:-"config-server.sh"}
load_config_and_check -c "$CONFIG_FILE" -vr PYTHON_VERSION VENV_NAME



# Create .log file
mkdir -p "$HOME/tmp"
LOG_FILE="$HOME/tmp/setup-python.log"
> "$LOG_FILE"





# Install PYTHON

INSTALL_LIST=()
# Python interpreter
if ! command -v python${PYTHON_VERSION} >/dev/null 2>&1; then
    INSTALL_LIST+=("python${PYTHON_VERSION}")
    echo "📦 python${PYTHON_VERSION} needs to be installed"
else
    echo "✅ python${PYTHON_VERSION} is already installed"
fi

# venv
if ! dpkg-query -W -f='${Status}' python${PYTHON_VERSION}-venv 2>/dev/null | grep -q "ok installed"; then
    INSTALL_LIST+=("python${PYTHON_VERSION}-venv")
    echo "📦 python${PYTHON_VERSION}-venv needs to be installed"
else
    echo "✅ python${PYTHON_VERSION}-venv is already installed"
fi

# dev headers
if ! dpkg-query -W -f='${Status}' python${PYTHON_VERSION}-dev 2>/dev/null | grep -q "ok installed"; then
    INSTALL_LIST+=("python${PYTHON_VERSION}-dev")
    echo "📦 python${PYTHON_VERSION}-dev needs to be installed"
else
    echo "✅ python${PYTHON_VERSION}-dev is already installed"
fi

# pip
if ! command -v pip3 >/dev/null 2>&1; then
    INSTALL_LIST+=("python3-pip")
    echo "📦 python3-pip needs to be installed"
else
    echo "✅ python3-pip is already installed"
fi




# Install missing packages 
if [[ ${#INSTALL_LIST[@]} -gt 0 ]]; then
    echo "🔧 Reconciling runtime dependencies..."
    
    update_apt -v -f $LOG_FILE 86400

    echo "⬇️ Install missing dependencies"
    echo "Running: sudo apt install -y ${INSTALL_LIST[@]}" >> "$LOG_FILE"
    sudo apt install -y "${INSTALL_LIST[@]}" >>"$LOG_FILE" 2>&1 || {
        echo "❌ apt install failed"
        exit 1
    }
    echo "✅ Dependencies installed."
else
    echo "✅ Runtime environment is already installed"
fi









# Test the environment

echo "🧠 Verifying Python runtime..."
python3 - << EOF
import sys
print("Python runtime OK")
print("Version:", sys.version)
EOF
echo "✅ Guardian check completed"










# Create the venv and pip install requirements.txt

VENV_PATH="$HOME/$VENV_NAME"

# Remove old venv if exists
if [ -d "$VENV_PATH" ]; then
    if [[ "$VENV_PATH" == "$HOME/"* ]]; then
        echo "🗑️ Removing existing virtual environment..."
        rm -rf "$VENV_PATH"
    fi
fi

echo "🆕 Creating virtual environment..."
python3 -m venv "$VENV_PATH"

# Activate environment
source "$VENV_PATH/bin/activate"

echo "Upgrading pip..."
echo "Running: pip install --upgrade pip" >> "$LOG_FILE"
if ! pip install --upgrade pip >>"$LOG_FILE" 2>&1; then
    echo "❌ Pip upgrade failed"
    exit 1
fi

if [[ ! -f "$PWD/requirements.txt" ]]; then
    echo "⚠️ requirements.txt missing — skipping dependency installation"
else
    pip install -r "$PWD/requirements.txt"
fi

echo "✅ Environment setup complete! To activate later:"
echo "source $VENV_PATH/bin/activate"


