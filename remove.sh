#!/bin/sh

# Environments
# --------------------------------
while true; do
    echo -n "Please input provision name to delete: "
    read PROVISION

    if [ -n "$PROVISION" ]; then
        break
    fi
done

# Delete php7.2-fpm
# --------------------------------
rm -f /etc/php-fpm.d/$PROVISION.conf
systemctl restart php-fpm

# Delete Nginx config file
# --------------------------------
rm -f /etc/nginx/conf.d/$PROVISION.conf
systemctl restart nginx

# Delete User
# --------------------------------
userdel -r $PROVISION
