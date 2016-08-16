#!/bin/bash

#系统当前时间
t1=`date "+%Y-%m-%d %H:%M:%S"`
t2=`date +%s -d "$t1"`

#define status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

cnt=`ps -ef|grep nfs |grep -v grep |wc -l`
if [ $cnt -eq 0 ];then
        echo "CRITICAL - NFS service is not running!"
        exit $STATE_CRITICAL
else
	echo "OK - NFS service is ok!"
	exit $STATE_OK
fi
