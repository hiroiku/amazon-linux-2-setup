#!/bin/sh

# Install PHP 7.2
amazon-linux-extras install -y php7.2
yum install -y php-bcmath php-common php-fpm php-gd php-intl php-json php-mbstring php-opcache php-pdo php-xml
yum install -y memcached php-pecl-memcached

# Enable php7.2-fpm
systemctl enable php-fpm
systemctl start php-fpm

# Enable memcached
systemctl enable memcached
systemctl start memcached
