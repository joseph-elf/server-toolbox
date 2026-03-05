#!/usr/bin/env bash
set -e
set -o pipefail


source "$(dirname "$0")/utils.sh"



CONFIG_FILE=${1:-config-server.sh}


if [[ ! -f "./$CONFIG_FILE" ]]; then
    echo "❌ Error: $CONFIG_FILE not found in the current directory!"
    exit 1
fi


echo
echo "🚀 Opening $CONFIG_FILE :"
source "./$CONFIG_FILE"

check_variable -rv IP
check_variable -rv USERNAME
check_variable -rv SSH_KEY
check_variable -v GIT_HUB_repos

echo "✅ Opening $CONFIG_FILE is done."


