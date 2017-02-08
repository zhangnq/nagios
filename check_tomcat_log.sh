#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh

name=$1
logpath=$2

if [ ! $name ];then
  echo "Please input name."
  exit 2
fi
if [ ! $logpath ];then
  echo "Please input log path."
  exit 2
fi

#logs timestamp monitor
left=$(tail -n 100 $logpath|awk '{print $1,$2}'|grep '^[0-9]'|tail -n 1)
t1=$(date -d "$left" "+%s")
if [ $? -ne 0 ];then
    left=$(ls -l $logpath |awk '{print $(NF-1)}')
    t1=$(date -d "$left" "+%s")
fi

t2=$(date "+%s")
let interval=$t2-$t1

if [ $interval -gt 300 ];then
    echo "Warning - ${name}'s log haven't output for more than 5 minutes."
    exit 1
fi

####
echo "OK - ${name}'s log is ok."
exit 0
