#!/bin/bash

#nagios exit code
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

help () {
        local command=`basename $0`
        echo "NAME
        ${command} -- check memory status
SYNOPSIS
        ${command} [OPTION]
DESCRIPTION
        -w warning=<percent>
        -c critical=<percent>
USAGE:
        $0 -w 50% -c 60%" 1>&2
        exit ${STATE_WARNING}
}

check_num () {
        local num_str="$1"
        echo ${num_str}|grep -E '^[0-9]+$' >/dev/null 2>&1 || local stat='not a positive integers!'
        if [ "${stat}" = 'not a positive integers!' ];then
                echo "${num_str} ${stat}" 1>&2
                exit ${STATE_WARNING}
        else
                local num_int=`echo ${num_str}*1|bc`
                if [ ${num_int} -lt 0 ];then
                        echo "${num_int} must be greater than 0!" 1>&2
                        exit ${STATE_WARNING}
                fi
        fi
}

#input
while getopts w:c: opt
do
        case "$opt" in
        w) 
                warning=$OPTARG
                warning_num=`echo "${warning}"|sed  's/%//g'`
                check_num "${warning_num}"
        ;;
        c) 
                critical=$OPTARG
                critical_num=`echo "${critical}"|sed  's/%//g'`
                check_num "${critical_num}"
        ;;
        *) help;;
        esac
done
shift $[ $OPTIND - 1 ]

[ $# -gt 0 -o -z "${warning_num}" -o -z "${critical_num}" ] && help

if [ -n "${warning_num}" -a -n "${critical_num}" ];then
        if [ ${warning_num} -ge ${critical_num} ];then
                echo "-w ${warning} must lower than -c ${critical}!" 1>&2
                exit ${STATE_UNKNOWN}
        fi
fi

datas=`awk -F':|k' '$2~/[0-9]+/{datas[$1]=$2}END{for (data in datas) {print data"="datas[data]}}' /proc/meminfo | grep -Ev '[)|(]'`

var=`echo "${datas}"|sed 's/ //g'`
eval "${var}"

MemUsed=`echo ${MemTotal}-${MemFree}-${Cached}-${Buffers}|bc`
MemUsage=`echo "${MemUsed}/${MemTotal}*100"|bc -l`
MemUsage_num=`echo ${MemUsage}/1|bc`
#echo ${MemUsage_num}
MemTotal_MB=`echo ${MemTotal}/1024|bc`
MemUsed_MB=`echo ${MemUsed}/1024|bc`
MemFree_MB=`echo ${MemFree}/1024|bc`
Cached_MB=`echo ${Cached}/1024|bc`
Buffers_MB=`echo ${Buffers}/1024|bc`

message () {
local stat="$1"
echo "MEMORY is ${stat} - Usage: ${MemUsage_num}%. Total: ${MemTotal_MB} MB Used: ${MemUsed_MB} MB Free: ${MemFree_MB} MB | Used=${MemUsed_MB};; Cached=${Cached_MB};; Buffers=${Buffers_MB};; Free=${MemFree_MB};;"
}

[ ${MemUsage_num} -lt ${warning_num} ] && message "OK" && exit ${STATE_OK}
[ ${MemUsage_num} -ge ${critical_num} ] && message "Critical" && exit ${STATE_CRITICAL}
[ ${MemUsage_num} -ge ${warning_num} ] && message "Warning" && exit ${STATE_WARNING}
