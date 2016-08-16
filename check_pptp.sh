#!/bin/bash

#系统当前时间
t1=`date "+%Y-%m-%d %H:%M:%S"`
t2=`date +%s -d "$t1"`

#define status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

cnt=`ps -ef|grep pptp |grep -v grep |wc -l`
if [ $cnt -eq 0 ];then
	echo "CRITICAL - PPTP service is not running!"
	exit $STATE_CRITICAL
else
	con=`ps -ef|grep pptpd-options |grep -v grep |wc -l`
	if [ $con -gt 5 -a $con -le 10 ];then
		echo "WARNING - There are $con vpn users connected! | conn=$con;5;10;;"
		exit $STATE_WARNING
	elif [ $con -gt 10 ];then
		echo "CRITICAL - There are $con vpn users connected! | conn=$con;5;10;;"
		exit $STATE_CRITICAL
	else
		echo "OK - PPTP service is running ok! | conn=$con;5;10;;"
		exit $STATE_OK
	fi
fi