#!/usr/bin/env bash

set -e
set -o pipefail

PUBLIC_IP=$(curl -s https://api.ipify.org)

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"


# Create .log file
LOG_FILE="$HOME/tmp/setup-netdata.log"
mkdir -p "$(dirname $LOG_FILE)" && > "$LOG_FILE"

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



NGINX_CONFIG=""

NGINX_CONFIG+="$(cat <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location /api/ {
        proxy_pass http://127.0.0.1:$API_PORT/;
    }
}

EOF
)"

echo $NGINX_CONFIG




# # WRITE THE REVERSE PROXY
# # in sites available

sudo tee /etc/nginx/sites-available/fastapi > /dev/null << EOF
server {
    listen 80;      #lister ipv4:80
    listen [::]:80; #listen ipv6:80

    server_name $PUBLIC_IP;  #catch all

    root /var/www/html; #static files user can access
    index index.html;   #default file openned
    
    location /api/ {
        proxy_pass http://127.0.0.1:8000/;  # send request to local:8000, api
        proxy_set_header Host \$host;   #give the server domain to the api
        proxy_set_header X-Real-IP \$remote_addr;   #send the user ip to api
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;   
        proxy_set_header X-Forwarded-Proto \$scheme;    #tell the api if its http or https
    }

    location /netdata/ {
        proxy_pass http://127.0.0.1:19999/;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_redirect off;
    }

    location / {    #handle request starting by /
        try_files \$uri /index.html;
    }
 
}
EOF