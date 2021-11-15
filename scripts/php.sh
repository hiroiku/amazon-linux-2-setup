#!/bin/sh

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Install PHP 7.3
amazon-linux-extras install -y php8.0

yum install -y php-bcmath php-common php-fpm php-gd php-intl php-json php-mbstring php-opcache php-pdo php-xml
systemctl enable php-fpm
systemctl start php-fpm

# Enable memcached
amazon-linux-extras install -y memcached1.5
yum install -y php-pecl-memcached
systemctl enable memcached
systemctl start memcached
