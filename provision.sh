# Environments
# --------------------------------
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
cat > /etc/php-fpm.d/$PROVISION.conf << EOF
[$PROVISION]
user  = $PROVISION
group = $PROVISION
listen       = /run/php-fpm/$PROVISION.sock
listen.owner = $PROVISION
listen.group = $PROVISION
listen.mode  = 0666
php_value[session.save_handler] = memcached
php_value[session.save_path]    = localhost:11211
pm                   = dynamic
pm.max_children      = 5
pm.start_servers     = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

systemctl restart php-fpm

# Create Nginx config file
# --------------------------------
cat > /etc/nginx/conf.d/$PROVISION.conf << EOF
server {
    listen      80;
    server_name $FQDN;
    root        /home/$PROVISION/DocumentRoot;
    index       index.php index.html index.htm;
    charset     UTF-8;
    access_log  /home/$PROVISION/log/nginx/access.log ltsv;
    error_log   /home/$PROVISION/log/nginx/error.log warn;

    include /etc/nginx/include.d/common.conf;

    location ~ [^/]\.php(/|\$) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)\$;

        if (!-f \$document_root\$fastcgi_script_name) {
            return 404;
        }

        fastcgi_pass unix:/run/php-fpm/$PROVISION.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_buffers 256 128k;
        fastcgi_buffer_size 128k;
        fastcgi_intercept_errors on;
        fastcgi_read_timeout 120s;
    }
}

server {
    listen      443 ssl http2;
    server_name $FQDN;
    root        /home/$PROVISION/DocumentRoot;
    index       index.php index.html index.htm;
    charset     UTF-8;
    access_log  /home/$PROVISION/log/nginx/access.log ltsv;
    error_log   /home/$PROVISION/log/nginx/error.log warn;

    include /etc/nginx/include.d/ssl.conf;
    include /etc/nginx/include.d/common.conf;

    location ~ [^/]\.php(/|\$) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)\$;

        if (!-f \$document_root\$fastcgi_script_name) {
            return 404;
        }

        fastcgi_pass unix:/run/php-fpm/$PROVISION.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_buffers 256 128k;
        fastcgi_buffer_size 128k;
        fastcgi_intercept_errors on;
        fastcgi_read_timeout 120s;
    }
}
EOF

systemctl restart nginx
