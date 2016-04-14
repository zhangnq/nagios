#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

left=`ps -ef|grep 'python /home/py27/nbhao/nbhao.py'|grep -v grep|wc -l`
if [ $left -eq 0 ];then
    echo "CRITICAL - nbhao server is not running."
    exit 2
fi

declare -i lt
declare -i nt
declare -i interval

log_time=`tail -n 1 /var/log/nbhao.log|awk '{print $1,$2}'`
lt=`date +%s -d "$log_time"`
nt=`date +%s`

interval=nt-lt

if [ $interval -gt 3600 ];then
    echo "WARNING - nbhao server's log status is changed an hour ago."
    exit 1
else
    echo "OK - nbhao server is ok."
    exit 0
fi