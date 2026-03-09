#!/usr/bin/env bash

set -e
set -o pipefail


TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"


# Create .log file
LOG_FILE="$HOME/ops/server-toolbox-logs/setup-node.log"
mkdir -p "$(dirname $LOG_FILE)" && > "$LOG_FILE"


update_apt -v -f $LOG_FILE 86400

echo "Install node js"


if ! sudo apt install nodejs -y >>"$LOG_FILE" 2>&1; then
          echo "❌ nodejs installation failed"
          return 1
fi


if ! sudo apt install npm -y >>"$LOG_FILE" 2>&1; then
          echo "❌ npm installation failed"
          return 1
fi




npm install

npm run build

npm start







PUBLIC_IP=$(curl -s https://api.ipify.org)

SERVER_NAME="$PUBLIC_IP"
NODE_PORT="3000"


NODE_CONFIG=""
NODE_CONFIG+="$(cat <<EOF
server {

    listen 80;      #lister ipv4:80
    listen [::]:80; #listen ipv6:80

    server_name $SERVER_NAME;

    location /node/ {
EOF
)"

if confirm " Do you want to make NODE WEBSITE only accessible to admin ?"; then
    if confirm " Do you want to create a new admin ?"; then
        create_apache_user $LOG_FILE
    fi

NODE_CONFIG+="$(cat <<EOF


        auth_basic "Admin Only";
        auth_basic_user_file /etc/nginx/.htpasswd;


EOF
)"
fi



NODE_CONFIG+="$(cat <<EOF


        proxy_pass http://127.0.0.1:$NODE_PORT/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        map $http_upgrade $connection_upgrade {
            default upgrade;
            ''      close;
        }

    }

    
}
EOF
)"


NODE_FILE="$HOME/ops/nginx-sites/node"
mkdir -p "$(dirname $NODE_FILE)" && > "$NODE_FILE"

printf "%s\n" "$NODE_CONFIG" | sudo tee "$NODE_FILE" > /dev/null

sudo ln -sf "$NODE_FILE" "/etc/nginx/sites-available/node"
sudo ln -sf "/etc/nginx/sites-available/node" "/etc/nginx/sites-enabled/node"

sudo nginx -t
sudo systemctl reload nginx

