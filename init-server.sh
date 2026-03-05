#!/bin/bash

GIT_HUB_EC2_connect=https://github.com/joseph-elf/server-toolbox.git



REMOTE_COMMANDS="echo '✅ Connection to the EC2 instance is succesfull'
    echo

    git clone $GIT_HUB_EC2_connect;

    grep -qxF 'export PATH=\"\$HOME/EC2_connect:\$PATH\"' ~/.bashrc || \
    echo 'export PATH=\"\$HOME/EC2_connect:\$PATH\"' >> ~/.bashrc

    source ~/.bashrc;
    echo
    "


if [[ -z "$GIT_HUB_repo_of_the_project" ]]; then
    echo "⚠️ Git-Hub repo of the project is not defined, dont forget to clone it !"
    REMOTE_COMMANDS="$REMOTE_COMMANDS
    echo '⚠️ Git-Hub repo of the project is not defined, dont forget to clone it !'
    "
else 
    echo "and clone "$GIT_HUB_repo_of_the_project
    REMOTE_COMMANDS="$REMOTE_COMMANDS
    git clone $GIT_HUB_repo_of_the_project;
    "

fi

REMOTE_COMMANDS="$REMOTE_COMMANDS
    echo
    echo '#################################################################'
    echo
    "

echo 

ssh -i $SSH_FILE -o StrictHostKeyChecking=no -t "$USERNAME@$IP" "$REMOTE_COMMANDS exec bash"








#!/usr/bin/env bash

set -e
set -o pipefail
source "$(dirname "$0")/utils.sh"

GIT_HUB_servertoolbox=https://github.com/joseph-elf/server-toolbox.git

CONFIG_FILE=${1:-"config-server.sh"}


load_config_and_check -c "$CONFIG_FILE" -vr IP USERNAME SSH_KEY

REMOTE_COMMANDS="
run-parts /etc/update-motd.d/
echo
echo '###############################################'
echo '✅ Connection to the EC2 instance is succesfull'
echo '###############################################'
echo 

git clone $GIT_HUB_servertoolbox;

grep -qxF 'export PATH=\"\$HOME/server-toolbox:\$PATH\"' ~/.bashrc || \
echo 'export PATH=\"\$HOME/server-toolbox:\$PATH\"' >> ~/.bashrc
source ~/.bashrc;
chmod +x \$HOME/server-toolbox/*.sh
echo
exec bash
"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -t "$USERNAME@$IP" "$REMOTE_COMMANDS"

