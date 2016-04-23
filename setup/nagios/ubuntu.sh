#!/bin/bash

#ubuntu nagios服务端一键安装脚本
#作者：章郎虫
#博客：http://www.sijitao.net/

#check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script."
    exit 1
fi

read -p "Do you want to install apache server?Please input yes or no.Default is yes:" is_apache
read -p "Do you want to install php?Please input yes or no.Default is yes:" is_php
read -p "Please input nagios admin password(default username:nagiosadmin):" nagios_pwd

cur_dir=$(pwd)
cd $cur_dir

echo "============================check files=================================="

sleep 5
if [ -s nagios-4.0.8.tar.gz ]; then
  echo "nagios-4.0.8.tar.gz [found]"
  else
  wget -c http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.8.tar.gz
fi
if [ -s nagios-plugins-2.0.3.tar.gz ]; then
  echo "nagios-plugins-2.0.3.tar.gz [found]"
  else
  wget -c http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz
fi
if [ -s nrpe-2.15.tar.gz ]; then
  echo "nrpe-2.15.tar.gz [found]"
  else
  wget -c http://prdownloads.sourceforge.net/sourceforge/nagios/nrpe-2.15.tar.gz
fi
if [ -s pnp4nagios-0.6.24.tar.gz ]; then
  echo "pnp4nagios-0.6.24.tar.gz [found]"
  else
  wget http://sourceforge.net/projects/pnp4nagios/files/PNP-0.6/pnp4nagios-0.6.24.tar.gz
fi

echo "============================install dependency============================"

sleep 5
apt-get update
apt-get -y install libgd2-noxpm libgd2-noxpm-dev libssl-dev libssl0.9.8 make openssl

echo "============================install apache2 ============================"

sleep 5
if [ "${is_apache:-yes}" = "yes" ];then
	mkdir -p $cur_dir/apache
        cd $cur_dir/apache
	wget http://download.chekiang.info/apache/ubuntu_apache.sh
	chmod +x ubuntu_apache.sh
	./ubuntu_apache.sh
fi

echo "============================install php ============================"

sleep 5
if [ "${is_php:-yes}" = "yes" ];then
	mkdir -p $cur_dir/php
        cd $cur_dir/php
	wget http://download.chekiang.info/nagios/setup/nagios/php/ubuntu_php.sh
	chmod +x ubuntu_php.sh
        ./ubuntu_php.sh
fi

echo "============================install nagios core==========================="

sleep 5
useradd -m -s /sbin/nologin nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd www

cd $cur_dir

tar zxvf nagios-4.0.8.tar.gz
cd nagios-4.0.8
./configure --with-command-group=nagcmd
make
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf

/usr/local/apache2/bin/htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin $nagios_pwd

echo "============================install nagios plugins==========================="

sleep 5
cd $cur_dir
tar zxvf nagios-plugins-2.0.3.tar.gz
cd nagios-plugins-2.0.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

echo "============================install nrpe==========================="

sleep 5
cd $cur_dir
tar zxvf nrpe-2.15.tar.gz
cd nrpe-2.15
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
make install-plugin
make install-daemon
make install-daemon-config

echo "============================start nagios==========================="
#check nagios install
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg
/usr/local/nagios/bin/nagiostats
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
/usr/local/nagios/libexec/check_nrpe -H localhost

sleep 5
update-rc.d nagios defaults
sed -i '/.*exit 0.*/i\/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d' /etc/rc.local

echo "============================install pnp4nagios==========================="

sleep 5
cd $cur_dir
apt-get -y install sendemail rrdtool librrds-perl

#install gd
cd php/php-5.5.18/ext/gd
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make
make install
cat >>/usr/local/php/etc/php.ini <<EOF
extension_dir='/usr/local/php/lib/php/extensions/no-debug-zts-20121212/'
extension=gd.so
EOF

sleep 5
cd $cur_dir

tar zxvf pnp4nagios-0.6.24.tar.gz
cd pnp4nagios-0.6.24
./configure --with-nagios-user=nagios --with-nagios-group=nagcmd
make all
make install
make install-webconf
make install-config
make install-init

sed -i 's/process_performance_data=0/process_performance_data=1/g' /usr/local/nagios/etc/nagios.cfg

cat >>/usr/local/nagios/etc/nagios.cfg<<"EOF"
# service performance data
service_perfdata_file=/usr/local/pnp4nagios/var/service-perfdata
service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE$
service_perfdata_file_mode=a
service_perfdata_file_processing_interval=15
service_perfdata_file_processing_command=process-service-perfdata-file

# host performance data starting with Nagios 3.0
host_perfdata_file=/usr/local/pnp4nagios/var/host-perfdata
host_perfdata_file_template=DATATYPE::HOSTPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tHOSTPERFDATA::$HOSTPERFDATA$\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$
host_perfdata_file_mode=a
host_perfdata_file_processing_interval=15
host_perfdata_file_processing_command=process-host-perfdata-file

EOF

sleep 1
cat >>/usr/local/nagios/etc/objects/commands.cfg<<"EOF"
define command{
       command_name    process-service-perfdata-file
       command_line    /bin/mv /usr/local/pnp4nagios/var/service-perfdata /usr/local/pnp4nagios/var/spool/service-perfdata.$TIMET$
}

define command{
       command_name    process-host-perfdata-file
       command_line    /bin/mv /usr/local/pnp4nagios/var/host-perfdata /usr/local/pnp4nagios/var/spool/host-perfdata.$TIMET$
}

EOF

sleep 1
cat >>/usr/local/nagios/etc/objects/templates.cfg<<"EOF"
define host {
   name       host-pnp
   action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=_HOST_
   register   0
}

define service {
   name       srv-pnp
   action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$
   register   0
}
EOF

update-rc.d npcd defaults
/etc/init.d/npcd start

#echo "============================install init==========================="
#sleep 5
#cd $cur_dir
#./setupinit.sh
