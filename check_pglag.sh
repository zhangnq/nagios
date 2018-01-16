#!/bin/bash

#define status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

lag_w=3600
lag_c=10800

#lag time second
lag_tm=`/opt/PostgreSQL/93/bin/psql -U postgres -p 5432 -d postgres -A -t -c "SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp())::integer END AS replication_lag;"`

if [ $? -ne 0 ];then
  echo "CRITICAL - PostgreSQL is not running."
  exit $STATE_CRITICAL
fi

if [ $lag_tm -gt $lag_w ];then
  echo "WARNING - Lag time $lag_tm s. | lag_tm=$lag_tm;$lag_w;$lag_c;;"
  exit $STATE_WARNING
fi

if [ $lag_tm -gt $lag_c ];then
  echo "CRITICAL - Lag time $lag_tm s. | lag_tm=$lag_tm;$lag_w;$lag_c;;"
  exit $STATE_CRITICAL
fi

echo "OK - Lag time $lag_tm s. | lag_tm=$lag_tm;$lag_w;$lag_c;;"
exit $STATE_OK
