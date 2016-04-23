#!/bin/bash

##################################
#
####nagios监控脚本
####作者：章郎虫
####博客：http://www.sijitao.net/
#
##################################

PROGNAME=`basename $0`
VERSION="Version 1.0"
AUTHOR="2013.12.03,www.sijitao.net"

ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3

interval=5
url="http://mirrors.163.com/centos/5.5/isos/x86_64/CentOS-5.5-x86_64-LiveCD.iso"

print_version() {
	echo "$VERSION $AUTHOR"
}

print_help() {
	print_version $PROGNAME $VERSION
	echo "$PROGNAME is a Nagios plugin to monitor download speed"
	echo "Use of wget download url file"
	echo "When using optional warning/critical thresholds all values except"
	echo "Usage parameters:"
	echo ""
	echo "$PROGNAME [-i/--interval] [-u|--url] [-w/--warning] [-c/--critical]"
	echo ""
	echo "Options:"
		echo "  --interval|-i)"
		echo "	  Defines the download file times"
		echo "          propose set < 5 second and  > 10 second"
		echo "	  Default is: 5 second"
		echo ""
		echo "  --url|-u)"
		echo " 	  Sets url page"
		echo "	  Defautl is :http://mirrors.163.com/centos/5.5/isos/x86_64/CentOS-5.5-x86_64-LiveCD.iso"
		echo "          Please set Fastest url"
		echo ""
		echo "  --warning|-w)"
		echo "          Sets a warning level for download speed. Defautl is: off"
		echo ""
		echo "  --critical|-c)"
		echo "          Sets a critical level for download speed. Defautl is: off"
	exit $ST_UK
}

while test -n "$1";do
	case "$1" in
		--help|-h)
			print_help
			exit $ST_UK
			;;
		--url|-u)
			url=$2
			shift
			;;
		--interval|-i)
			interval=$2
			shift
			;;
		--warning|-w)
			warn=$2
			shift
			;;
		--critical|-c)
			crit=$2
			shift
			;;
		*)
			echo "Unknown argument: $1"
			print_help
			exit $ST_UK
			;;
	esac
	shift
done

val_wcdiff() {
    if [ ${warn} -lt ${crit} ]
    then
        wcdiff=1
    fi
}

get_speed() {
	wget -b $url > /dev/null
	sleep $interval
	BS="`cat wget-log |tail -n20 |awk '{print $8}'|sed 's/K//'|awk '{sum+=$1};END{print sum}'`"
	speed=`echo $BS / 19|bc`
	killall wget
	rm CentOS*
	rm wget-log
}
do_output() {
	output="speed:${speed}"
}
do_perfdata() {
	perfdata="'speed'=${speed}"
}

if [ -n "$warn" -a -n "$crit" ]
then
    val_wcdiff
    if [ "$wcdiff" = 1 ];then
	echo "Please adjust your warning/critical thresholds. The critical must be lower than the warning level!"
        exit $ST_UK
    fi
fi

get_speed
do_output
do_perfdata

if [ -n "$warn" -a -n "$crit" ];then
	if [ $speed -le $warn -a $speed -gt $crit ];then
        	echo  "WARNING - $output |$perfdata"
        	exit $ST_WR
	elif [ $speed -lt $crit ];then
        	echo  "CRITICAL - $output|$perfdata"
		exit $ST_CR
	else
        	echo  "OK - $output|$perfdata"
		exit $ST_OK
	fi
else
	echo "OK - $output|$perfdata"
	exit $ST_OK
fi
