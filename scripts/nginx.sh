#!/bin/sh

# Install Nginx
amazon-linux-extras install -y nginx1.12

# Enable nginx
systemctl enable nginx
systemctl start nginx

# /etc/nginx/nginx.conf
cat > /etc/nginx/nginx.conf << "EOF"
user nginx;
worker_processes  auto;
worker_rlimit_nofile  20000;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections 4096;
    multi_accept on;
    use epoll;
}

http {
    server_tokens off;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    charset UTF-8;
    client_max_body_size 0;
    server_names_hash_bucket_size 128;

    log_format  ltsv  'domain:$host\t'
                      'host:$remote_addr\t'
                      'user:$remote_user\t'
                      'time:$time_local\t'
                      'method:$request_method\t'
                      'path:$request_uri\t'
                      'protocol:$server_protocol\t'
                      'status:$status\t'
                      'size:$body_bytes_sent\t'
                      'referer:$http_referer\t'
                      'agent:$http_user_agent\t'
                      'response_time:$request_time\t'
                      'cookie:$http_cookie\t'
                      'set_cookie:$sent_http_set_cookie\t'
                      'upstream_addr:$upstream_addr\t'
                      'upstream_cache_status:$upstream_cache_status\t'
                      'upstream_response_time:$upstream_response_time';
    # access_log /var/log/nginx/access.log ltsv;
    sendfile    on;
    tcp_nopush  on;
    tcp_nodelay on;
    keepalive_timeout 5;
    connection_pool_size 1024;
    request_pool_size 8k;

    gzip on;
    gzip_http_version 1.0;
    gzip_disable "msie6";
    gzip_proxied any;
    gzip_min_length 1024;
    gzip_comp_level 2;
    gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript application/json;

    # brotli on;
    # brotli_static on;
    # brotli_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript application/json;
    # brotli_comp_level 3;
    # brotli_min_length 1024;

    # open_file_cache max=100000 inactive=20s;
    # open_file_cache_valid 30s;
    # open_file_cache_min_uses 2;
    # open_file_cache_errors on;
    # fastcgi_cache_path /var/cache/nginx/wordpress levels=1:2 keys_zone=wpcache:30m max_size=512M inactive=600m;
    # fastcgi_ignore_headers "Vary" "Cache-Control" "Expires";

    include /etc/nginx/conf.d/*.conf;
}
EOF

mkdir /etc/nginx/include.d

# /etc/nginx/include.d/common.conf
cat > /etc/nginx/include.d/common.conf << "EOF"
location / {
    try_files $uri $uri/ /index.php?$args;
}

location = /favicon.ico {
    log_not_found off;
    access_log off;
}
EOF

# /etc/nginx/include.d/wordpress.conf
cat > /etc/nginx/include.d/wordpress.conf << "EOF"
if (!-e $request_filename) {
    rewrite /wp-admin$ $scheme://$host$uri/ permanent;
    rewrite ^/[_0-9a-zA-Z-]+(/wp-.*) $1 last;
    rewrite ^/[_0-9a-zA-Z-]+.*(/wp-admin/.*\.php)$ $1 last;
    rewrite ^/[_0-9a-zA-Z-]+(/.*\.php)$ $1 last;
}
EOF

# /etc/nginx/include.d/ssl.conf
mkdir /etc/ssl/localhost
yes '' | openssl req -x509 -newkey rsa:2048 -nodes -sha256 -keyout /etc/ssl/localhost/localhost.key -out /etc/ssl/localhost/localhost.crt -days 3650
openssl dhparam 2048 -out /etc/ssl/dhparam.key
openssl rand 48 > /etc/ssl/ssl_session_ticket.key

cat > /etc/nginx/include.d/ssl.conf << "EOF"
ssl_certificate         /etc/ssl/localhost/localhost.crt;
ssl_certificate_key     /etc/ssl/localhost/localhost.key;
ssl_dhparam             /etc/ssl/dhparam.key;
ssl_session_tickets     on;
ssl_session_ticket_key  /etc/ssl/ssl_session_ticket.key;
ssl_session_cache       shared:SSL:1m;
ssl_session_timeout     5m;
#ssl_ct on;
#ssl_ct_static_scts /etc/pki/tls/certs/scts;
ssl_protocols   TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers     "EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
ssl_prefer_server_ciphers on;
# #OCSP stapling
# ssl_stapling on;
# ssl_stapling_verify on;
# resolver 8.8.4.4 8.8.8.8 valid=300s;
# resolver_timeout 10s;
EOF

# Restart nginx
rm -f /etc/nginx/conf.d/php-fpm.conf
systemctl restart nginx
