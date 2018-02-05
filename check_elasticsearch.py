#!/usr/bin/env python
#coding:utf-8

import urllib2
import sys
import argparse
import json
import base64

parser=argparse.ArgumentParser(description="check elastic search health.")
parser.add_argument("-H",dest="host",help="Host")
parser.add_argument("-P",dest="port",default=9200,help="elastic search http port,default 9200.")
parser.add_argument("-u",dest="username",default=None,help="http auth username")
parser.add_argument("-p",dest="password",default=None,help="http auth password")

args=parser.parse_args()

if not args.host or not args.port:
    print "Critical - Invalid command,please check."
    sys.exit(2)


url='http://%s:%s/_cluster/health' % (args.host,args.port)
req=urllib2.Request(url)
if args.username and args.password:
    base64string = base64.b64encode('%s:%s' % (args.username,args.password))
    req.add_header("Authorization", "Basic %s" % base64string)

req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36")

try:
    response=urllib2.urlopen(req,timeout=30)
except urllib2.HTTPError,e:
    print "Critical - %s" % e
    sys.exit(2)
except:
    print "Critical - elasticsearch health status get error."
    sys.exit(2)

result=json.loads(response.read())

if result['status'] == 'green':
    print "OK - elasticsearch is running,status: green. | active_primary=%s;;;;active=%s;;;;relocating=%s;;;;init=%s;;;;" % \
    (result['active_primary_shards'],result['active_shards'],result['relocating_shards'],result['initializing_shards'])
    sys.exit(0)
elif result['status'] == 'yellow':
    print "WARNING - elasticsearch is running,status: yellow. | active_primary=%s;;;;active=%s;;;;relocating=%s;;;;init=%s;;;;" % \
    (result['active_primary_shards'],result['active_shards'],result['relocating_shards'],result['initializing_shards'])
    sys.exit(1)
else:
    print "Critical - elasticsearch is running,status: red. | active_primary=%s;;;;active=%s;;;;relocating=%s;;;;init=%s;;;;" % \
    (result['active_primary_shards'],result['active_shards'],result['relocating_shards'],result['initializing_shards'])
    sys.exit(2)

