#!/usr/bin/env bash


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



NGINX_CONFIG+="
$(cat <<EOF
test
EOF
)"




echo "$NGINX_CONFIG"


# auth_basic "Admin Area";
# auth_basic_user_file /etc/nginx/admin.htpasswd;