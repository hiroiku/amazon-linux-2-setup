#!/bin/sh

# Install PHP 7.2
amazon-linux-extras install -y php7.2
yum install -y php-bcmath php-common php-fpm php-gd php-intl php-json php-mbstring php-mysql php-opcache php-pdo php-xml

# Enable php7.2-fpm
systemctl enable php-fpm
systemctl start php-fpm
