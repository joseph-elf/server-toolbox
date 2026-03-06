#!/usr/bin/env bash

set -e
set -o pipefail

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"



# Create .log file
LOG_FILE="$HOME/tmp/setup-nginx.log"
mkdir -p "$(dirname $LOG_FILE)" && > "$LOG_FILE"

update_apt -v -f $LOG_FILE 86400
echo "Install nginx"
sudo apt install nginx -y





# # WRITE THE REVERSE PROXY
# # in sites available
# sudo tee /etc/nginx/sites-available/fastapi > /dev/null << EOF
# server {
#     listen 80;      #lister ipv4:80
#     listen [::]:80; #listen ipv6:80

#     server_name josephelf.fr www.josephelf.fr;  #catch all

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






# # Link available to enable where nginx actually work, so in enable is a shortcut to available, s is a soft link anfd f force overwrite if already existing
# # you can remove the site by removing from enable, but can still keep it in available
# sudo ln -sf /etc/nginx/sites-available/fastapi /etc/nginx/sites-enabled/

# # remove the default enable
# sudo rm -f /etc/nginx/sites-enabled/default

# # test the new configuration (not the running one)
# sudo nginx -t

# # apply new config, but stop traffic NOT GOOD
# sudo systemctl restart nginx

# # apply new config, without stopping the traffic usually run conjointly with sudo nginx -t
# #sudo systemctl reload nginx

# #check status 
# #sudo systemctl status nginx


# echo "To start the server run : uvicorn main:app --host 127.0.0.1 --port 8000 --reload"
# echo "or run for deployment : bash start_fastapi.sh"
