#!/bin/bash
#Function:实现一键部署nginx,mariadb,php
yum -y install pcre-devel gcc openssl-devel
yum -y install mariadb-server.x86_64  mariadb mariadb-devel php php-mysql php-fpm
systemctl restart php-fpm
systemctl restart mariadb
tar -xf /root/lnmp_soft.tar.gz
cd lnmp_soft/
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2/
useradd -s /sbin/nologin nginx
./configure --user=nginx --with-http_ssl_module --with-stream_ssl_module  --with-stream  --with-http_stub_status_module && make install

