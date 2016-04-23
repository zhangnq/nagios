#!/bin/bash

rm -rf /usr/local/php

echo "============================install dependency=================================="

sleep 5
for packages in build-essential gcc g++ make automake autoconf re2c wget cron bzip2 libzip-dev libc6-dev file rcconf flex vim nano bison m4 gawk less make cpp binutils diffutils unzip tar bzip2 libbz2-dev unrar p7zip libncurses5-dev libncurses5 libncurses5-dev libncurses5-dev libtool libevent-dev libpcre3 libpcre3-dev libpcrecpp0  libssl-dev zlibc openssl libsasl2-dev libxml2 libxml2-dev libltdl3-dev libltdl-dev libmcrypt-dev libmysqlclient15-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libfreetype6 libfreetype6-dev libjpeg62 libjpeg-dev libpng-dev libpng12-0 libpng12-dev curl libcurl3 libmhash2 libmhash-dev libpq-dev libpq5 gettext libncurses5-dev libjpeg-dev libpng12-dev libxml2-dev zlib1g-dev libfreetype6 libfreetype6-dev libssl-dev libcurl3 libcurl4-gnutls-dev mcrypt libcap-dev ;
do
	apt-get install -y $packages --force-yes;apt-get -fy install;apt-get -y autoremove;
done

echo "============================install php=================================="

sleep 5
cur_dir=$(pwd)
cd $cur_dir

#wget http://download.chekiang.info/nagios/setup/nagios/php/php-5.5.18.tar.gz
wget -c http://www.php.net/distributions/php-5.5.18.tar.gz

tar zxvf php-5.5.18.tar.gz
cd php-5.5.18
./configure --prefix=/usr/local/php --with-openssl --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml  --enable-sockets --with-apxs2=/usr/local/apache2/bin/apxs --with-mcrypt  --with-config-file-path=/usr/local/php/etc --with-bz2  --enable-maintainer-zts
make
make install
cp php.ini-production /usr/local/php/etc/php.ini

cat >>/usr/local/apache2/conf/httpd.conf <<EOF
<IfModule php5_module>
AddType application/x-httpd-php .php
AddType application/x-httpd-php-source .phps
</IfModule>
EOF

echo "============================restart apache=================================="

sleep 5
/etc/init.d/apache2 stop
sleep 1
/etc/init.d/apache2 start
sleep 5
ps -ef|grep apache
