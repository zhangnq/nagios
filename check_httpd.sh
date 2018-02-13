#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#ajp_ilink_receive timeout
error_log_path=/usr/local/apache2/logs/error_log
num=20

err_cnt=`tail -n $num $error_log_path|grep ajp_ilink_receive|grep -cv grep`
let ratio=($err_cnt*100)/$num
if [ $ratio -gt 80 ];then
  echo "Critical - apache ajp receive timeout,ratio ${ratio}%."
  exit 2
fi
if [ $ratio -gt 60 ];then
  echo "Warning - apache ajp receive timeout,ratio ${ratio}%."
  exit 1
fi

#process
mpm_config_path=/usr/local/apache2/conf/extra/httpd-mpm.conf
max_cnt=`grep mpm_prefork_module $mpm_config_path -A 8|grep MaxClients|awk '{print $NF}'`
now_cnt=`ps -ef|grep '/usr/local/apache2/bin/httpd -k start'|grep -cv grep`

if [ $now_cnt -eq 0 ];then
  echo "Critical - apache httpd is stoped."
  exit 2
fi

let ratio=($now_cnt*100)/$max_cnt
if [ $ratio -gt 90 ];then
  echo "Critical - apache process count is $now_cnt,ratio ${ratio}%."
  exit 2
fi
if [ $ratio -gt 70 ];then
  echo "Warning - apache process count is $now_cnt,ratio ${ratio}%."
  exit 1
fi

#ok
echo "OK - apache is running ok.|process=$now_cnt;;;;"
exit 0