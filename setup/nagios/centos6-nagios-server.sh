#!/bin/bash
#Date: 2015/12/17
#BY:renzhenxing
#EDIT:zhangnq
#BLOG:http://www.sijitao.net/
#install nagios-server or nagios-plugs

read -p "Please input your nagiosadmin's password:" a
selinux=`grep SELINUX=enforcing /etc/selinux/config | awk -F "=" '{print $2}'`

if [ "$selinux" == "enforcing" ]
   then
      echo "your system Selinux not shut down,"
      exit 1
fi

yum install -y httpd php

yum install -y wget gcc gcc++ gcc* bc net-snmp net-snmp-utils net-snmp-libs  libpng libpng-devel libjpeg libjpeg-devel openssl098e gd* gd2* openssl-devel* openssl*

cd /usr/local/src

if [ -f nagios-4.0.8.tar.gz ]
then
     echo ".........................................nagios.tar.gz..................is OK!!!"
else
     echo "nagios.tar.gz.............................is not ok!!!..................download"
     wget http://jaist.dl.sourceforge.net/project/nagios/nagios-4.x/nagios-4.0.8/nagios-4.0.8.tar.gz
fi

#http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
if [ -f nagios-plugins-2.1.1.tar.gz ]
then
    echo "............................................nagios-plugs .................is ok!!!"
else
    echo "nagios-plugins-2.1.1.tar.gz....................is not ok !!!! ..............download"
    wget https://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
fi

if [ -f nrpe-2.15.tar.gz ]
then
   echo "............................................nrpe-2.15.tar.gz.................is ok!!!"
else
   echo "..................................nrpe-2.15.tar.gz...is not ok!!!............download"
   wget http://jaist.dl.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
fi


###add install nagios ID：
useradd -m nagios
echo "nagios" | passwd --stdin nagios

###add install  gid：
groupadd nagcmd

###daemon 为apache运行账号：
usermod -a -G nagcmd daemon

###install nagios-4.0.8.tar.gz
tar -zxf nagios-4.0.8.tar.gz && cd nagios-4.0.8
./configure --with-command-group=nagcmd --with-gd-lib=/usr/local/libgd/lib/ --with-gd-inc=/usr/local/libgd/include/
make all
make install
make install-init
make install-config
make install-commandmode
cd ../

cat >>/etc/httpd/conf/httpd.conf<<EOF
###nagios's cgi for httpd:
ScriptAlias /nagios/cgi-bin "/usr/local/nagios/sbin"
<Directory "/usr/local/nagios/sbin">
#  SSLRequireSSL
   Options ExecCGI
   AllowOverride None
   Order allow,deny
   Allow from all
#  Order deny,allow
#  Deny from all
#  Allow from 127.0.0.1
   AuthName "Nagios Access"
   AuthType Basic
   AuthUserFile /usr/local/nagios/etc/htpasswd.users
   Require valid-user
</Directory>
Alias /nagios "/usr/local/nagios/share"
<Directory "/usr/local/nagios/share">
#  SSLRequireSSL
   Options None
   AllowOverride None
   Order allow,deny
   Allow from all
#  Order deny,allow
#  Deny from all
#  Allow from 127.0.0.1
   AuthName "Nagios Access"
   AuthType Basic
   AuthUserFile /usr/local/nagios/etc/htpasswd.users
   Require valid-user
</Directory>
EOF

##########################################################

###location nagios admin   password(default:che100):
htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin $a

###service httpd server:
service httpd restart

###install nagios-plugs（default：/usr/local/nagios/）：
tar -xzf nagios-plugins-2.1.1.tar.gz
cd nagios-plugins-2.1.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install
cd ../

###install nrpe:
tar -zxf nrpe-2.15.tar.gz
cd nrpe-2.15
./configure && make all && make install-plugin

###禁用ｓｕｅｘｅｃ的功能．此功能对ＣＧＩ的执行路径进行了限制
setenforce 0

###start nagios  server:
service nagios restart


echo "--------------- nagios server install ok!!!------------------------"
echo "  "
echo "--------------service nagios start is start -----------------------"
echo "  "

