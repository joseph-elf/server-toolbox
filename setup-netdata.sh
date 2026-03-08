#!/usr/bin/env bash

set -e
set -o pipefail


TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"


# Create .log file
LOG_FILE="$HOME/tmp/setup-netdata.log"
mkdir -p "$(dirname $LOG_FILE)" && > "$LOG_FILE"

update_apt -v -f $LOG_FILE 86400
echo "Install netdata"

CONF_FILE="/etc/nginx/sites-available/netdata"


#install htop (monitor in terminal) and netdata (GUI online monitor)

if ! sudo apt install htop >>"$LOG_FILE" 2>&1; then
          echo "❌ htop installation failed"
          return 1
fi


if ! sudo apt install netdata -y >>"$LOG_FILE" 2>&1; then
          echo "❌ netdata installation failed"
          return 1
fi


















# # start netdata
sudo systemctl start netdata

# # MMMH I dont think we need to open as we proxy reverse with nginx
# #sudo ufw allow 19999

# # start when reboot
sudo systemctl enable netdata









# # CONFIGURE NGINX REVERSE PROXY
# # location /netdata/ {
# #         proxy_pass http://127.0.0.1:19999/;
# #         proxy_set_header Host $host;
# #         proxy_http_version 1.1;
# #         proxy_set_header Connection "";
# #         proxy_redirect off;
# #     }

PUBLIC_IP=$(curl -s https://api.ipify.org)

SERVER_NAME="$PUBLIC_IP"
NETDATA_PORT="19999"

NGINX_CONFIG=""
NGINX_CONFIG+="$(cat <<EOF
server {

    listen 80;      #lister ipv4:80
    listen [::]:80; #listen ipv6:80

    server_name $SERVER_NAME;

    location /netdata/ {
EOF
)"

if confirm " Do you want to make NETDATA only accessible to admin ?"; then
    if confirm " Do you want to create a new admin ?"; then
        create_apache_user $LOG_FILE
    fi

NGINX_CONFIG+="$(cat <<EOF


        auth_basic "Admin Only";
        auth_basic_user_file /etc/nginx/.htpasswd;


EOF
)"
fi



NGINX_CONFIG+="$(cat <<EOF


        proxy_pass http://127.0.0.1:$NETDATA_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    
}
EOF
)"




printf "%s\n" "$NGINX_CONFIG" | sudo tee /etc/nginx/sites-available/netdata > /dev/null

sudo ln -sf "$CONF_FILE" /etc/nginx/sites-enabled/netdata

sudo nginx -t
sudo systemctl reload nginx

# # WRITE THE REVERSE PROXY
# # in sites available

# sudo tee /etc/nginx/sites-available/fastapi > /dev/null << EOF
# server {
#     listen 80;      #lister ipv4:80
#     listen [::]:80; #listen ipv6:80

#     server_name $PUBLIC_IP;  #catch all

#     root /var/www/html; #static files user can access
#     index index.html;   #default file openned
    
#     location /api/ {
#         proxy_pass http://127.0.0.1:8000/;  # send request to local:8000, api
#         proxy_set_header Host \$host;   #give the server domain to the api
#         proxy_set_header X-Real-IP \$remote_addr;   #send the user ip to api
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;   
#         proxy_set_header X-Forwarded-Proto \$scheme;    #tell the api if its http or https
#     }

#     location /netdata/ {
#         proxy_pass http://127.0.0.1:19999/;
#         proxy_set_header Host \$host;
#         proxy_http_version 1.1;
#         proxy_set_header Connection "";
#         proxy_redirect off;
#     }

#     location / {    #handle request starting by /
#         try_files \$uri /index.html;
#     }
 
# }
# EOF