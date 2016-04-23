#!/bin/bash

##################################
#
####nagios监控脚本
####作者：章郎虫
####博客：http://www.sijitao.net/
#
####ping.sh脚本
for ip in `seq 101 110`
do
        ping -c 1 192.168.1.$ip |awk 'NR==2{print $3}' |while read from
        do
        if [ "$from"x != "from"x ];then
                echo "192.168.1.$ip" >/tmp/ping.log
        fi
        done
done
##################################

#define status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

cd /tmp
state="ok"

for state in `cat ping.log`
do

        if [ "$state"x != ""x  ];then
                echo "CRITICAL - $state is down!"
                exit $STATE_CRITICAL
        fi
done

if [ "$state"x = "ok"x  ];then
        echo "OK - All internal servers is uptime!"
        exit $STATE_OK
fi
