#!/usr/bin/env bash

if [[ "${ADMIN_UTILS_LOADED:-0}" -eq 1 ]]; then
    return
fi
ADMIN_UTILS_LOADED=1

TOOLBOX_FOLD="${TOOLBOX_FOLD:-$( [ -d "$HOME/server-toolbox" ] && echo "$HOME/server-toolbox" || pwd )}"
source "$TOOLBOX_FOLD/utils.sh"


# Create .log file
LOG_FILE_local="$HOME/tmp/setup-apache.log"
mkdir -p "$(dirname $LOG_FILE_local)" && > "$LOG_FILE_local"


HTPASSWD_FILE="/etc/nginx/.htpasswd"



check_install_apache(){
    local LOG_FILE="${1:-$LOG_FILE_local}"
    if ! command -v htpasswd &> /dev/null; then
        echo "apache2-utils not installed, installing..."


        update_apt -v -f $LOG_FILE 86400

        

        if ! sudo apt install -y apache2-utils >>"$LOG_FILE" 2>&1; then
          echo "❌ apache2-utils installation failed"
          return 1
        fi
    fi

}


create_apache_user(){
    local LOG_FILE="${1:-$LOG_FILE_local}"
    
    check_install_apache $LOG_FILE

    read -p "Username : " username

    if [ ! -f "$HTPASSWD_FILE" ]; then
        sudo htpasswd -c "$HTPASSWD_FILE" "$username"
    else
        if grep -q "^${username}:" "$HTPASSWD_FILE"; then
        echo "User already exists."
        return 1
    fi
        sudo htpasswd "$HTPASSWD_FILE" "$username"
    fi
}


remove_apache_user() {

    # Check if htpasswd file exists
    if [[ ! -f "$HTPASSWD_FILE" ]]; then
        echo "Error: htpasswd file $HTPASSWD_FILE does not exist."
        return 1
    fi


    read -p "Username to remove: " username

    if ! grep -q "^${username}:" "$HTPASSWD_FILE"; then
        echo "User not found."
        return 1
    fi

    sudo htpasswd -D "$HTPASSWD_FILE" "$username"
    return $?
}


list_users() {
    echo "=== Toolbox Admin Users ==="
    cut -d: -f1 "$HTPASSWD_FILE"
}



main() {
    case "$1" in
        add-user)
            create_apache_user
            ;;
        remove-user)
            remove_apache_user
            ;;
        list-users)
            list_apache_users
            ;;
        *)
            echo "Usage:"
            echo "  admin-utils.sh add-user"
            echo "  admin-utils.sh remove-user"
            echo "  admin-utils.sh list-users"
            ;;
    esac
}

main "$@"