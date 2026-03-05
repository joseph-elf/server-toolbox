#!/usr/bin/env bash

set -e
set -o pipefail
source "$(dirname "$0")/utils.sh"

CONFIG_FILE=${1:-"config-server.sh"}

load_config_and_check -c "$CONFIG_FILE" -vr IP USERNAME SSH_KEY

REMOTE_COMMANDS="
run-parts /etc/update-motd.d/
echo
echo '###############################################'
echo '✅ Connection to the EC2 instance is succesfull'
echo '###############################################'
echo 
exec bash
"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -t "$USERNAME@$IP" "$REMOTE_COMMANDS"

