#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#process
left=`ps -ef|grep '/opt/PostgreSQL/93/bin/postgres'|grep -cv grep`
if [ $left -eq 0 ];then
  echo "Critical - PostgreSQL is not running."
  exit 2
fi

#idle in transaction
left=`ps -ef|grep postgres|grep 'idle in transaction'|grep -cv grep`
if [ $left -gt 5 ];then
  echo "Warning - PostgreSQL idle in transaction count is $left."
  exit 1
fi

#connections
max=1000
conns=`ps -ef|grep postgres|grep -cv grep`

let conn_ratio=($conns*100)/$max
if [ $conn_ratio -gt 95 ];then
  echo "Critical - PostgreSQL connections ratio reached ${conn_ratio}%."
  exit 2
fi
if [ $conn_ratio -gt 80 ];then
  echo "Warning - PostgreSQL connections ratio reached ${conn_ratio}%."
  exit 1
fi

#slow query
sql="select count(pid) from pg_stat_activity where state != 'idle' and query not ilike '%pg_stat_activity%' and now() - query_start > '10 minutes'::interval;"
slow_query_cnt=`/opt/PostgreSQL/93/bin/psql -h 127.0.0.1 -p 5432 -U postgres -d postgres -c "$sql" -t -A`
if [ $slow_query_cnt -ne 0 ];then
  echo "Warning - PostgreSQL slow query count is $slow_query_cnt. | conn_ratio=$conn_ratio;80;95;;slow_query=$slow_query_cnt;;;;"
  echo 1
fi

#ok
echo "OK - PostgreSQL is running ok. | conn_ratio=$conn_ratio;80;95;;slow_query=$slow_query_cnt;;;;"
exit 0