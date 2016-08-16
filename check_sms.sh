#!/bin/bash


#define status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

sms_home=/home/zhangnq/sms

cd $sms_home

a=`ps -ef |grep -v grep |grep -c smsserver`
if [ $a -eq 0 ];then
	echo "CRITICAL - SMS service is not running!"
	exit $STATE_CRITICAL
fi

s1=`tail -n 10 $sms_home/sms.log |grep -c ERROR`

#modem status

m_cnt=0
err=0
for modem in `grep ^[a-z] SmsServer.conf |grep "gateway.*" |cut -d, -f1|awk -F '=' '{print $NF}'`
do
	m=`grep "GTW: $modem: Gateway status" sms.log |sed -n '$p'|awk '{print $NF}'`
	if [ "$m" != "STARTED" ];then
		let err=$err+1
	fi
	let m_cnt=$m_cnt+1
done

case $err in

$m_cnt)
	echo "CRITICAL - All gateway's status is error!" 
	exit $STATE_CRITICAL
	;;
1 | 2 | 3 | 4)
	echo "WARNING - There are $err modems running error!"
	;;
*)
	if [ $s1 -ne 0 ];then
        	echo "CRITICAL - SMS service is running error!"
        	exit $STATE_CRITICAL
	else
        	echo "OK - SMS service is Ok!"
        	exit $STATE_OK
	fi
	;;
esac