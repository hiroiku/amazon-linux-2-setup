# Environments
# --------------------------------

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

while true; do
    echo -n "Please input provision name: "
    read PROVISION

    if [ -n "$PROVISION" ]; then
        break
    fi
done

while true; do
    echo -n "Please input FQDN: "
    read FQDN

    if [ -n "$FQDN" ]; then
        break
    fi
done

# Add User
# --------------------------------
useradd -m -s /bin/bash $PROVISION
sudo -u $PROVISION mkdir /home/$PROVISION/DocumentRoot
chmod 755 /home/$PROVISION
mkdir -p /home/$PROVISION/log/nginx
chmod -R 755 /home/$PROVISION/log

# Create php7.2-fpm
# --------------------------------
sed -e "s/{PROVISION}/$PROVISION/g" ./templates/etc/php-fpm.d/template.conf > /etc/php-fpm.d/$PROVISION.conf
systemctl restart php-fpm

# Create Nginx config file
# --------------------------------
sed -e "s/{PROVISION}/$PROVISION/g" -e "s/{FQDN}/$FQDN/g" ./templates/etc/nginx/conf.d/template.conf > /etc/nginx/conf.d/$PROVISION.conf
systemctl restart nginx
