#!/usr/bin/env python
#coding:utf-8

import urllib2
from xml.dom.minidom import parse
import sys
import argparse

parser=argparse.ArgumentParser(description="check nowsms status script.")
parser.add_argument("-H",dest="host",help="Host name argument for servers using host headers")
parser.add_argument("-P",dest="port",default=8800,help="nowsms http port ,default 8800.")
parser.add_argument("-u",dest="username",help="nowsms admin username")
parser.add_argument("-p",dest="password",help="nowsms admin user's password")

args=parser.parse_args()

if not args.host or not args.port or not args.username or not args.password :
    print "Critical - Invalid command,please check."
    sys.exit(2)

url='http://%s:%s/admin/xmlstatus?username=%s&password=%s' % (args.host,args.port,args.username,args.password)
req=urllib2.Request(url)
req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36")

try:
    response=urllib2.urlopen(req,timeout=5)
    DOMTree = parse(response)
except:
    print "Critical - nowsms admin status get error."
    sys.exit(2)

nowsms = DOMTree.documentElement

smsc = nowsms.getElementsByTagName("SMSCStatus")
mmsc = nowsms.getElementsByTagName("MMSCRouteStatus")
sms_sent = nowsms.getElementsByTagName("SMSSent")
sms_received = nowsms.getElementsByTagName("SMSReceived")

status = smsc[0].getElementsByTagName('Status')[0].childNodes[0].data
mlast7days = mmsc[0].getElementsByTagName('MessagesLast7Days')[0].childNodes[0].data

sms_sent_last7days = sms_sent[0].getElementsByTagName('MessagesLast7Days')[0].childNodes[0].data
sms_received_last7days = sms_received[0].getElementsByTagName('MessagesLast7Days')[0].childNodes[0].data

if status != 'OK':
    detail=smsc[0].getElementsByTagName('StatusDetail')[0].childNodes[0].data
    print "%s - %s" % (status,detail)
    sys.exit(2)
else:
    print "%s - nowsms is ok. | SMSSent7DAYS=%s;;;;SMSReceived7DAYS=%s;;;;" % (status,sms_sent_last7days,sms_received_last7days)
    sys.exit(0)
    