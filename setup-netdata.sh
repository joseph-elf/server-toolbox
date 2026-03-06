#!/usr/bin/env bash

set -e
set -o pipefail


STAMP="/var/lib/apt/periodic/update-success-stamp"

if [ ! -f "$STAMP" ] || [ $(( $(date +%s) - $(stat -c %Y "$STAMP") )) -gt 86400 ]; then
    sudo apt update
    
    echo "Running: sudo apt update" >> "$LOG_FILE"
    sudo apt update >>"$LOG_FILE" 2>&1 || {
        echo "❌ apt update failed"
        exit 1
    }

else
    echo "APT update was run within the last 24h."
fi



#install htop (monitor in terminal) and netdata (GUI online monitor)
sudo apt install htop

sudo apt install netdata -y

# start netdata
sudo systemctl start netdata

# MMMH I dont think we need to open as we proxy reverse with nginx
#sudo ufw allow 19999

# start when reboot
sudo systemctl enable netdata

# CONFIGURE NGINX REVERSE PROXY
# location /netdata/ {
#         proxy_pass http://127.0.0.1:19999/;
#         proxy_set_header Host $host;
#         proxy_http_version 1.1;
#         proxy_set_header Connection "";
#         proxy_redirect off;
#     }