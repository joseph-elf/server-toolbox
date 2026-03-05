#!/usr/bin/env bash

set -e
set -o pipefail
source "$(dirname "$0")/utils.sh"

CONFIG_FILE=${1:-"config-server.sh"}


load_config_and_check -c "$CONFIG_FILE" -vr IP USERNAME SSH_KEY GIT_HUB_servertoolbox
load_config_and_check -c "$CONFIG_FILE" -v GIT_HUB_repos


# Send the config file to the root of the server
echo
echo '#################################################'
echo "🚀 Send $CONFIG_FILE to the server"

scp -i "$SSH_KEY" \
    -o StrictHostKeyChecking=no \
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
echo '#################################################'
echo '🚀 Download SERVER-TOOLBOX and make it executable'
git clone $GIT_HUB_servertoolbox;
echo -e 'Add the server-toolbox repository to the PATH and\nmake .sh executable.'
grep -qxF 'export PATH=\"\$HOME/server-toolbox:\$PATH\"' ~/.bashrc || \
echo 'export PATH=\"\$HOME/server-toolbox:\$PATH\"' >> ~/.bashrc
source ~/.bashrc;
chmod +x \$HOME/server-toolbox/*.sh
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

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -t "$USERNAME@$IP" "$REMOTE_COMMANDS"

