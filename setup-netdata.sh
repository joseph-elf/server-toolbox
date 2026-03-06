#!/usr/bin/env bash

set -e
set -o pipefail

# Create .log file
LOG_FILE="$HOME/tmp/setup-netdata.log"
mkdir -p "$(dirname $LOG)" && > "$LOG_FILE"

update_apt -v -f $LOG_FILE 86400
echo "Install netdata"



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