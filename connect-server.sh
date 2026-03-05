#!/usr/bin/env bash

set -e
set -o pipefail

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"

CONFIG_FILE=${1:-"config-server.sh"}




load_config_and_check -c "$CONFIG_FILE" -vr IP USERNAME SSH_KEY

REMOTE_COMMANDS="
run-parts /etc/update-motd.d/
echo
echo '###############################################'
echo '✅ Connection to the EC2 instance is succesfull'
echo '###############################################'
echo 
echo 'Run ssh -i $SSH_KEY -t $USERNAME@$IP if you want to connect.'
exec bash
"

ssh -i "$SSH_KEY"\
    -t "$USERNAME@$IP"\
    "$REMOTE_COMMANDS"

