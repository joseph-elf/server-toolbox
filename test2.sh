#!/usr/bin/env bash




TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
echo "The toolbox loaded is located in $TOOLBOX_FOLD."

source "$TOOLBOX_FOLD/admin-utils.sh"

echo "create_apache_user"
create_apache_user

echo "add_user"
admin-utils.sh add-user



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