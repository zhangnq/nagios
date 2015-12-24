#!/bin/bash

#example
#command[check_eth0_ifstat]=/usr/local/nagios/libexec/custom/check_ifstat.sh eth0

a=$1

#define status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

w_if=102400
c_if=102400

STATIN=`/usr/bin/ifstat -i $a 3 1 | sed -n '3p' |awk '{print $1}'| cut -f 1 -d "."`
STATOUT=`/usr/bin/ifstat -i $a 3 1 | sed -n '3p' |awk '{print $2}'| cut -f 1 -d "."`
if [ $STATIN -gt $c_if ]||[ $STATOUT -gt $c_if ]
     then
          echo "CRITICAL - INPUT=$STATIN KB/s,OUTPUT=$STATOUT KB/s. | INPUT=$STATIN;$w_if;$c_if;;OUTPUT=$STATOUT;$w_if;$c_if;;"
          exit $STATE_CRITICAL
fi
if ([ $STATIN -gt $w_if ] && [ $STATIN -lt $c_if ])|| ([ $STATOUT -gt $w_if ] && [ $STATOUT -lt $c_if ])
     then
         echo "WARNING - INPUT=$STATIN KB/s,OUTPUT=$STATOUT KB/s. | INPUT=$STATIN;$w_if;$c_if;;OUTPUT=$STATOUT;$w_if;$c_if;;"
         exit $STATE_WARNING
fi
         echo "OK - INPUT=$STATIN KB/s,OUTPUT=$STATOUT KB/s. | INPUT=$STATIN;$w_if;$c_if;;OUTPUT=$STATOUT;$w_if;$c_if;;"
         exit $STATE_OK
