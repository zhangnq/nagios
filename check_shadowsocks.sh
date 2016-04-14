#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

left=`ps -ef|grep 'python /root/shadowsocks/shadowsocks/server.py'|grep -v grep|wc -l`
if [ $left -eq 0 ];then
    echo "CRITICAL - shadowsocks server is not running."
    exit 2
fi

echo "OK - shadowsocks server is ok."
exit 0