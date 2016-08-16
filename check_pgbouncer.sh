#!/bin/bash

#define status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

res=`/opt/PostgreSQL/9.2/bin/psql -U postgres -p 5432 -d pgbouncer -A -t -c "show pools"`
conns=0
cl_waitings=0
req=0

for line in $res
do
	conn=`echo $line |awk -F '|' '{print $3}' `
	cl_waiting=`echo $line |awk -F '|' '{print $4}' `
	let conns=$conn+$conns
	let cl_waitings=$cl_waiting+$cl_waitings
done

let conns=$conns+$cl_waitings

max_conn=`grep "max_client_conn" /etc/pgbouncer/pgbouncer.ini |awk '{print $NF}'`

w_conn=`echo "$max_conn*0.8"|bc`
c_conn=`echo "$max_conn*0.95"|bc`
w_conn=`echo ${w_conn%.*}`
c_conn=`echo ${c_conn%.*}`

left=`tail /var/log/pgbouncer/pgbouncer.log |grep -c "LOG Stats:.*req/s"`
if [ $left -ne 0 ];then
	req=`tail /var/log/pgbouncer/pgbouncer.log |grep "LOG Stats:.*req/s" |tail -n 1 |awk '{print $6}'`
fi

if [ $conns -gt $w_conn -o $req -lt 600 ];then
	echo "WARNING - max_conn=$max_conn,conns=$conns,req=$req,cl_waiting=$cl_waitings | conn=$conns;$w_conn;$c_conn;;req=$req;600;300;;"
	exit $STATE_WARNING
fi

if [ $conns -gt $c_conn -o $req -lt 300 ];then
        echo "CRITICAL - max_conn=$max_conn,conns=$conns,req=$req,cl_waiting=$cl_waitings | conn=$conns;$w_conn;$c_conn;;req=$req;600;300;;"
	exit $STATE_CRITICAL
fi


a=`tail /var/log/pgbouncer/pgbouncer.log |grep -c "LOG Stats"`

if [ $a -lt 1 ];then
	echo "WARNING - Please check pgbouncer stats!"
	exit $STATE_WARNING
fi

echo "OK - It's ok! max_conn=$max_conn,conns=$conns,req=$req,cl_waiting=$cl_waitings | conn=$conns;$w_conn;$c_conn;;req=$req;600;300;;"
exit $STATE_OK