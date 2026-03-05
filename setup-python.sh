#!/usr/bin/env bash

set -e
set -o pipefail
source "$(dirname "$0")/utils.sh"

CONFIG_FILE=${1:-"config-server.sh"}

load_config_and_check -c "$CONFIG_FILE" -vr PYTHON_VERSION VENV_NAME


# Version of Python
PYTHON_VERSION=3.12
VENV_NAME=venv


########################################
# Configuration
########################################


########################################
# Dependency reconciliation
########################################

INSTALL_LIST=()

# Python interpreter
if ! command -v python${PYTHON_VERSION} >/dev/null 2>&1; then
    INSTALL_LIST+=("python${PYTHON_VERSION}")
fi

# venv
if ! dpkg-query -W -f='${Status}' python${PYTHON_VERSION}-venv 2>/dev/null | grep -q "ok installed"; then
    INSTALL_LIST+=("python${PYTHON_VERSION}-venv")
fi

# dev headers
if ! dpkg-query -W -f='${Status}' python${PYTHON_VERSION}-dev 2>/dev/null | grep -q "ok installed"; then
    INSTALL_LIST+=("python${PYTHON_VERSION}-dev")
fi

# pip
if ! command -v pip3 >/dev/null 2>&1; then
    INSTALL_LIST+=("python3-pip")
fi


# Install missing packages 
if [[ ${#INSTALL_LIST[@]} -gt 0 ]]; then
    echo "🔧 Reconciling runtime dependencies..."
    sudo apt update
    sudo apt install -y "${INSTALL_LIST[@]}"
else
    echo "✅ Runtime environment already converged"
fi


echo "🧠 Verifying Python runtime..."

python${PY_VERSION} - << EOF
import sys

print("Python runtime OK")
print("Version:", sys.version)
EOF

echo "✅ Guardian check completed"






# if [ -d "~/$VENV_NAME" ]; then
#     echo "Removing existing virtual environment..."
#     rm -rf $VENV_NAME
# fi

# echo "Creating virtual environment..."
# python$PYTHON_VERSION -m venv ~/$VENV_NAME

# source ~/$VENV_NAME/bin/activate

# echo "Upgrading pip..."
# pip install --upgrade pip

# echo "Installing packages from requirements.txt..."
# pip install -r requirements.txt

# echo "✅ Environment setup complete! To activate later: source ~/$VENV_NAME/bin/activate"
