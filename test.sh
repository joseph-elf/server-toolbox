#!/usr/bin/env bash
set -e
set -o pipefail


TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
echo "The toolbox loaded is located in $TOOLBOX_FOLD."
source "$TOOLBOX_FOLD/utils.sh"
#source "$(dirname "$0")/utils.sh"


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



if [[ -n "${GIT_HUB_repos:-}" ]]; then
    if declare -p GIT_HUB_repos 2>/dev/null | grep -q 'declare \-a'; then
        # Variable is an array
        for repo in "${GIT_HUB_repos[@]}"; do
            echo "yoooo $repo"
        done
    else
        # Variable exists but is not an array (treat as single value)
        echo "yoooo $GIT_HUB_repos"
    fi
else
    echo "No repositories defined."
fi


