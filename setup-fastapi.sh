#!/usr/bin/env bash

set -e
set -o pipefail

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"

source "$TOOLBOX_FOLD/utils.sh"
source "$TOOLBOX_FOLD/admin-utils.sh"


# Create .log file
LOG_FILE="$HOME/ops/server-toolbox-logs/setup-fastapi.log"
mkdir -p "$(dirname $LOG_FILE)" && > "$LOG_FILE"




# Check the config requirements
CONFIG_FILE=${1:-"config-server.sh"}
load_config_and_check -c "$CONFIG_FILE" -vr VENV_NAME


source $HOME/$VENV_NAME/bin/activate


if [[ ! -f "$PWD/requirements.txt" ]]; then
    echo "⚠️ requirements.txt missing — skipping dependency installation"
    echo "install fastapi, uvicorn and gunicorn for minimal API."
    pip install fastapi uvicorn gunicorn
else
    pip install fastapi uvicorn gunicorn
    pip install -r "$PWD/requirements.txt"
fi







# Create .log file

FASTAPI_LOG_FOLD="$HOME/ops/API-logs"
FASTAPI_LOG_FILE=$FASTAPI_LOG_FOLD/fastapi.log
FASTAPI_ERROR_FILE=$FASTAPI_LOG_FOLD/fastapi-error.log

sudo mkdir -p "$FASTAPI_LOG_FOLD"

sudo touch "$FASTAPI_LOG_FILE"
sudo touch "$FASTAPI_ERROR_FILE"


sudo chown ubuntu:ubuntu $FASTAPI_LOG_FILE
sudo chown ubuntu:ubuntu $FASTAPI_ERROR_FILE




SYSTEMD_CONFIG=""
SYSTEMD_CONFIG+="$(cat <<EOF
[Unit]
Description=FastAPI App
After=network.target

[Service]
User=ubuntu
WorkingDirectory=$PWD
ExecStart=$HOME/$VENV_NAME/bin/gunicorn main:app -c $PWD/config-gunicorn.py
ExecReload=/bin/kill -HUP $MAINPID

StandardOutput=append:$FASTAPI_LOG_FILE
StandardError=append:$FASTAPI_ERROR_FILE

Restart=always
RestartSec=10

LimitNOFILE=4096
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF
)"



SYSTEMD_FILE="$HOME/ops/systemd/fastapi.service"
mkdir -p "$(dirname $SYSTEMD_FILE)" && > "$SYSTEMD_FILE"

printf "%s\n" "$NGINX_CONFIG" | sudo tee "$NGINX_FILE" > /dev/null

sudo ln -sf "$SYSTEMD_FILE" "/etc/systemd/system/fastapi.service"







# printf "%s\n" "$SYSTEMD_CONFIG" | sudo tee "$PWD/fastapi.service" > /dev/null

# sudo ln -sf "$PWD/fastapi.service" "/etc/systemd/system/fastapi.service"



#reload systemd
sudo systemctl daemon-reload


# start/restart fastapi system md
sudo systemctl start fastapi
#sudo systemctl restart fastapi
#sudo systemctl stop fastapi

# start automatically when reboot
sudo systemctl enable fastapi

# monitor
#sudo systemctl status fastapi
#sudo journalctl -u fastapi -f



















PUBLIC_IP=$(curl -s https://api.ipify.org)

SERVER_NAME="$PUBLIC_IP"
FASTAPI_PORT="8000"

NGINX_CONFIG=""
NGINX_CONFIG+="$(cat <<EOF
server {

    listen 80;      #lister ipv4:80
    listen [::]:80; #listen ipv6:80

    server_name $SERVER_NAME;

    location /fastapi/ {
EOF
)"

if confirm " Do you want to make the API only accessible to admin ?"; then
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


        proxy_pass http://127.0.0.1:$FASTAPI_PORT/;
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



NGINX_FILE="$HOME/ops/nginx-sites/fastapi"
mkdir -p "$(dirname $NGINX_FILE)" && > "$NGINX_FILE"

printf "%s\n" "$NGINX_CONFIG" | sudo tee "$NGINX_FILE" > /dev/null

sudo ln -sf "$NGINX_FILE" "/etc/nginx/sites-available/fastapi"
sudo ln -sf "/etc/nginx/sites-available/fastapi" "/etc/nginx/sites-enabled/fastapi"




sudo nginx -t
sudo systemctl reload nginx