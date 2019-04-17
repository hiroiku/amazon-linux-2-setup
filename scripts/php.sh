#!/bin/sh

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Install PHP 7.2
VERSIONS=(`amazon-linux-extras list | grep -oP "^\s+?.+\s+?\K(php\d+?\.\d+?)" | sort -nr`)
LATEST=("${VERSIONS[@]:0}")
amazon-linux-extras install -y $LATEST

rm -rf /etc/php-fpm.d/*
yum install -y php-bcmath php-common php-fpm php-gd php-intl php-json php-mbstring php-opcache php-pdo php-xml
systemctl enable php-fpm
systemctl start php-fpm

# Enable memcached
yum install -y memcached php-pecl-memcached
systemctl enable memcached
systemctl start memcached
