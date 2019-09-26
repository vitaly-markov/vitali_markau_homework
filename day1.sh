#!/bin/bash
yum install httpd
cmd
fireall-cmd -permanent -add-port=80/tcp 
fireall-cmd -permanent -add-port=443/tcp
firewall-cmd --reload
systemctl start httpd
httpd -S
systemctl status httpd
yum install wget
wget http://ftp.byfly.by/pub/apache.org//httpd/httpd-2.4.41.tar.gz
tar -xvzf httpd-2.4.41.tar.gz
yum install gcc
mkdir /usr/local/apache2/
cd httpd-2.4.41
yum -y install arp apr-devel apr-util apr-util-devel pcre pcre-devel
./configure -prefix=/usr/local/apache2/
make
make install
touch /usr/local/apache2/htdocs/index.html
vi /usr/local/apache2/htdocs/index.html
/usr/local/apache2/bin/apachectl start
/usr/local/apache2/bin/apachectl -S
/usr/local/apache2/bin/apachectl stop
touch /etc/httpd/conf.d/vhosts.conf
vi /etc/httpd/conf.d/vhosts.conf

vim httpd.conf
/etc/httpd/conf.d/vhosts.conf


<VirtualHost *>
ServerName www.vitali.markau
ServerAlias vitali.markov
DocumentRoot /var/www/html
RewriteEngine  on
RewriteRule    "/$"  "/index.html" [R,L,NC]
RewriteRule    "^/index\.html$"  "/ping.html" [R,L,NC]
RewriteRule  !^/ping - [F,NC]
</VirtualHost>
~                  








yum install epel-release
yum install cronolog
mkdir var/log/vitali.markau



CustomLog "|/usr/sbin/cronolog /var/log/vitali.markau/access_log.%Y-%m-%d" combined
ErrorLog "|/usr/sbin/cronolog /var/log/vitali.markau/error_log.%Y-%m-%d"





LogFormat "%h %A %l %u %t \"%r\" %>s %p %b" markau.log
ErrorLog syslog:local6
CustomLog "|/usr/bin/logger -t httpd -i -p local5.notice" markau.log



