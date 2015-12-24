#!/bin/bash
#centos nagios pnp4nagios一键安装脚本
#作者：章郎虫
#博客：http://www.sijitao.net/

cd /usr/local/src

if [ -s pnp4nagios-0.6.24.tar.gz ]; then
  echo "pnp4nagios-0.6.24.tar.gz [found]"
  else
  wget http://sourceforge.net/projects/pnp4nagios/files/PNP-0.6/pnp4nagios-0.6.24.tar.gz
fi

echo "============================install pnp4nagios==========================="

sleep 5

yum install -y rrdtool rrdtool-perl perl-Time-HiRes

#install gd
yum install -y php-gd

sleep 5

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

chkconfig npcd on
/etc/init.d/npcd start

#config pnp4nagios to apache
cat > /etc/httpd/conf.d/pnp4nagios.conf<<EOF
Alias /pnp4nagios "/usr/local/pnp4nagios/share"
<Directory "/usr/local/pnp4nagios/share">
    AllowOverride None
    Order allow,deny
    Allow from all
    AuthName "Nagios Access"
    AuthType Basic
    AuthUserFile /usr/local/nagios/etc/htpasswd.users
    Require valid-user
    <IfModule mod_rewrite.c>
        # Turn on URL rewriting
        RewriteEngine On
        Options symLinksIfOwnerMatch
        # Installation directory
        RewriteBase /pnp4nagios/
        # Protect application and system files from being viewed
        RewriteRule "^(?:application|modules|system)/" - [F]
        # Allow any files or directories that exist to be displayed directly
        RewriteCond "%{REQUEST_FILENAME}" !-f
        RewriteCond "%{REQUEST_FILENAME}" !-d
        # Rewrite all other URLs to index.php/URL
        RewriteRule "^.*$" "index.php/$0" [PT]
    </IfModule>
</Directory>
EOF
/etc/init.d/httpd restart
rm -rf /usr/local/pnp4nagios/share/install.php
