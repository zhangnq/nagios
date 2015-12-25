#!/bin/bash
#Date: 2015/12/17
#BY:zhangnq
#BLOG:http://www.sijitao.net/
#install nagios-plugs nagios-nrpe

mkdir /usr/local/nagios
/usr/sbin/useradd -m -s/sbin/nologin nagios
chown nagios.nagios /usr/local/nagios/
groupadd nagcmd
usermod -a -G nagcmd nagios

yum groupinstall -y "Development Tools"
yum install -y gcc make openssl openssl-devel bc

cd /usr/local/src

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

tar zxvf nagios-plugins-2.1.1.tar.gz
cd nagios-plugins-2.1.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios --prefix=/usr/local/nagios
make && make install
chown -R nagios.nagios /usr/local/nagios/libexec
cd ..

tar zxvf nrpe-2.15.tar.gz
cd nrpe-2.15
./configure --with-ssl=/usr/bin/openssl
make all
make install
make install-plugin
make install-daemon
make install-daemon-config
cd ..
sed -i 's/allowed_hosts=.*/allowed_hosts=127.0.0.1/g' /usr/local/nagios/etc/nrpe.cfg
cnt=`grep -c "/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d" /etc/rc.local`
if [ $cnt -eq 0 ];then
	#sed -i '/.*exit 0.*/i\/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d' /etc/rc.local
	echo "/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d" >>/etc/rc.local
fi
cat >>/usr/local/nagios/etc/nrpe.cfg<<"EOF"
command[check_swap]=/usr/local/nagios/libexec/check_swap -w 90% -c 60%
command[check_/]=/usr/local/nagios/libexec/check_disk -w 20% -c 10% -p /
EOF

/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d

cd /root

cat >restart_nrpe.sh<<"EOF"
#!/bin/bash
export PATH="$PATH"
killall nrpe
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
sleep 1
ps -ef|grep nagios
EOF
chmod +x restart_nrpe.sh

#install nagios plugins
cd /usr/local/nagios/libexec
wget http://download.chekiang.info/nagios/check_tcp_stat.sh
chmod +x check_tcp_stat.sh
chown nagios:nagios check_tcp_stat.sh
wget http://download.chekiang.info/nagios/check_mem.sh
chmod +x check_mem.sh
chown nagios:nagios check_mem.sh
wget http://download.chekiang.info/nagios/check_net_traffic.sh
chmod +x check_net_traffic.sh
chown nagios:nagios check_net_traffic.sh

cat >>/usr/local/nagios/etc/nrpe.cfg<<"EOF"
command[check_tcp_stat]=/usr/local/nagios/libexec/check_tcp_stat.sh -w 100 -c 200
command[check_mem]=/usr/local/nagios/libexec/check_mem.sh -w 80% -c 90%
command[check_net_traffic]=/usr/local/nagios/libexec/check_net_traffic.sh -d eth0 -w 5M -c 20M
EOF
sleep 3
/root/restart_nrpe.sh

