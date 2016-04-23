#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

host='http://192.168.188.104'

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script."
    exit 1
fi

echo "============================add user=================================="

sleep 3

#issue=$(cat /etc/issue |awk '{print $2}' |awk -F "." '{print $1$2}')
#
#if [ "$issue" -eq "1004" ];then
#	adduser zhangnq
#	adduser zhangnq admin
#else
#	adduser zhangnq
#	adduser zhangnq sudo
#fi
#addgroup appl
#adduser appadmin
#usermod -g appl appadmin
#groupdel appadmin
#chgrp -R appl /home/appadmin
#chmod 750 /home/appadmin
userdel -r administrator
userdel -r user
usermod -p '!' root

echo "===========================setup default==================================="

sleep 3

if [ "$issue" -eq "1004" ];then
	wget http://192.168.188.102/mirror/sources.list.lucid -O sources.list
	mv /etc/apt/sources.list /etc/apt/source.list.`date "+%Y%m%d%H%M%S"`
	mv sources.list /etc/apt/
fi
if [ "$issue" -eq "1204" ];then
	wget http://192.168.188.102/mirror/sources.list.precise -O sources.list
	mv /etc/apt/sources.list /etc/apt/source.list.`date "+%Y%m%d%H%M%S"`
	mv sources.list /etc/apt/
fi

apt-get update
apt-get -y install ntpdate build-essential gcc g++ make zlibc zlib1g zlib1g-dev language-pack-zh-hans

#set localtime
cat >/etc/cron.daily/ntpdate <<EOF
#!/bin/bash
ntpdate ntp.ubuntu.com >>/var/log/ntpdate.log 2>&1
EOF
chmod +x /etc/cron.daily/ntpdate

#set default language
mv /etc/default/locale /etc/default/locale.`date "+%Y%m%d%H%M%S"`
cat >/etc/default/locale <<EOF
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
EOF
echo "en_US.UTF-8 UTF-8" >/var/lib/locales/supported.d/local

#Synchronization time
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

reboot
