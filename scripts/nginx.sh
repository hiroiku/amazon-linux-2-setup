#!/bin/sh

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Install Nginx
amazon-linux-extras install -y nginx1

# Enable nginx
systemctl enable nginx
systemctl start nginx

# /etc/nginx/nginx.conf
cat < ../templates/etc/nginx/nginx.conf > /etc/nginx/nginx.conf

# /etc/nginx/conf.d/_default.conf
cp ../templates/etc/nginx/conf.d/_default.conf /etc/nginx/conf.d/_default.conf

# /etc/nginx/include.d
mkdir -p /etc/nginx/include.d

# /etc/nginx/include.d/common.conf
cat < ../templates/etc/nginx/include.d/common.conf > /etc/nginx/include.d/common.conf

# /etc/nginx/include.d/wordpress.conf
cat < ../templates/etc/nginx/include.d/wordpress.conf > /etc/nginx/include.d/wordpress.conf

# /etc/nginx/include.d/ssl.conf
mkdir -p /etc/ssl/localhost
yes '' | openssl req -x509 -newkey rsa:2048 -nodes -sha256 -keyout /etc/ssl/localhost/localhost.key -out /etc/ssl/localhost/localhost.crt -days 3650
openssl dhparam 2048 -out /etc/ssl/dhparam.key
openssl rand 48 > /etc/ssl/ssl_session_ticket.key
cat < ../templates/etc/nginx/include.d/ssl.conf > /etc/nginx/include.d/ssl.conf

# Restart nginx
systemctl restart nginx
