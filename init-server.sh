#!/usr/bin/env bash

set -e
set -o pipefail

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"

CONFIG_FILE=${1:-"config-server.sh"}


load_config_and_check -c "$CONFIG_FILE" -vr IP USERNAME SSH_KEY GIT_HUB_servertoolbox
load_config_and_check -c "$CONFIG_FILE" -v GIT_HUB_repos

ssh-keygen -R $IP

# Send the config file to the root of the server
echo
echo '#################################################'
echo "🚀 Send $CONFIG_FILE to the server"

scp -i "$SSH_KEY" \
    -C \
    -q \
    $CONFIG_FILE \
    "$USERNAME@$IP:~/$CONFIG_FILE"

echo '#################################################'
echo





REMOTE_COMMANDS="
run-parts /etc/update-motd.d/
echo
echo '###############################################'
echo '✅ Connection to the EC2 instance is succesfull'
echo '###############################################'
echo 
echo '🔌 If you want to connect, run :'
echo 'ssh -i $SSH_KEY -t $USERNAME@$IP'
echo
echo '#################################################'
echo '🚀 Download SERVER-TOOLBOX'
git clone $GIT_HUB_servertoolbox;
echo 'and install it (path variable)'
bash server-toolbox/install-toolbox.sh
echo '#################################################'
echo
"

GIT_COMMANDS=""
if [[ -n "${GIT_HUB_repos:-}" ]]; then
    if declare -p GIT_HUB_repos 2>/dev/null | grep -q 'declare \-a'; then
        # Variable is an array
        for repo in "${GIT_HUB_repos[@]}"; do
            GIT_COMMANDS+="
            echo
            echo '##########################################'
            echo '🚀 Download $repo'
            git clone $repo
            echo '##########################################'
            "
        done
    else
        # Variable exists but is not an array (treat as single value)
        GIT_COMMANDS+="
            echo
            echo '##########################################'
            echo '🚀 Download $GIT_HUB_repos'
            git clone $GIT_HUB_repos
            echo '##########################################'
            "
    fi
else
    GIT_COMMANDS+="
            echo
            echo '##########################################'
            echo '⚠️ No repositery to download'
            echo '##########################################'
            "
fi

REMOTE_COMMANDS+=$GIT_COMMANDS
REMOTE_COMMANDS+="
exec bash
"

ssh -i "$SSH_KEY"\
    -t "$USERNAME@$IP"\
     "$REMOTE_COMMANDS"

