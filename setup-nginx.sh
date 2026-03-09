#!/usr/bin/env bash

set -e
set -o pipefail

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"

source "$TOOLBOX_FOLD/utils.sh"
source "$TOOLBOX_FOLD/admin-utils.sh"

# Create .log file
LOG_FILE="$HOME/ops/server-toolbox-logs/setup-nginx.log"
mkdir -p "$(dirname $LOG_FILE)" && > "$LOG_FILE"


update_apt -v -f $LOG_FILE 86400


echo "Install nginx"
echo "Running: sudo apt install nginx -y" >> "$LOG_FILE"
if ! sudo apt install nginx -y >>"$LOG_FILE" 2>&1; then
    echo "❌ nginx install/update failed"
    exit 1
fi



echo "✅ Nginx is installed"

sudo systemctl enable nginx
sudo systemctl start nginx

echo "For server management, it is more secure to use admin access for certain services."




if confirm " Do you want to create it now ?"; then
    create_apache_user $LOG_FILE
else
    echo "In the future use"
    echo "admin-utils.sh add-user"
fi




