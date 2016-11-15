#!/usr/bin/env Python
#coding:utf-8

import urllib
import urllib2
import cookielib
import hashlib
import sys
import re

bandinfo_url='http://192.168.188.1:8080/userRpm/Monitor_bandinfo.htm'
index_url='http://192.168.188.1:8080/logon/logon.htm'
login_url='http://192.168.188.1:8080/logon/loginJump.htm'
logout_url='http://192.168.188.1:8080/logon/logout.htm'
loginconfirm_url='http://192.168.188.1:8080/logon/loginConfirm.htm'
username='admin'
password='password'

#监控带宽阀值，单位Mbps
trans_warning=40
trans_critical=50

class MyRequest:
    def __init__(self): 
        self.__agent='My Spider/1.0.0 (admin@sijitao.net)'
        self.__params = {}
        self.__header = {
            'User-Agent':self.__agent,
        }
    
    def add_query_param(self, k, v):
        if self.__params is None:
            self.__params = {}
        self.__params[k] = v
    
    def set_query_param(self,params={}):
        self.__params = params
        
    def add_header(self, k, v):
        if self.__header is None:
            self.__header = dict(k=v)
        else:
            self.__header[k] = v
    def get_headers(self):
        return self.__header
    
    def set_user_agent(self, agent):
        self.add_header('User-Agent', agent)
        
    def do_action(self,url,method=''):
        data=urllib.urlencode(self.__params)
        req=urllib2.Request(url,headers=self.get_headers())
        req.add_data(data)
        if method:
            req.get_method = lambda: method
        try:
            response = urllib2.urlopen(req)
            return response
        except urllib2.URLError as e:
            if hasattr(e, 'code'):
                #print("Request %s code %s") % (url,e.code)
                pass
            elif hasattr(e, 'reason'):
                #print("Request %s reason %s") % (url,e.reason)
                pass
            return False
        except:
            print("Request %s error.") % url
            return False


#cookie
cj = cookielib.LWPCookieJar()
cookie_support = urllib2.HTTPCookieProcessor(cj)
opener = urllib2.build_opener(cookie_support, urllib2.HTTPHandler)
urllib2.install_opener(opener)

#get cookie
try:
    opener.open(index_url)
except:
    print "Critical - Get cookie error."
    sys.exit(2)
for ck in cj:
    cookie = ck.value

#login
request=MyRequest()

value_tmp="%s:%s:%s" % (username,password,cookie)
value_encode="%s:%s" % (username,hashlib.md5(value_tmp).hexdigest())
request.add_query_param('encoded', value_encode)
request.add_query_param('nonce',cookie)
login_response=request.do_action(login_url)

if login_response:
    #不能多人同时登录
    login_html=login_response.read().decode('gb2312')
    pattern=re.compile('loginConfirm')
    result=pattern.findall(login_html)
    if result:
        request.do_action(loginconfirm_url,method='GET')
        
    bandinfo_response=request.do_action(bandinfo_url,method='GET')
    if bandinfo_response:
        bandinfo_html=bandinfo_response.read().decode('gb2312')
        pattern=re.compile(r'WAN1.*,')
        result=pattern.findall(bandinfo_html)
        
        try:
            result=result[0].encode("utf-8")
        except:
            print "Warning - Username or password error."
            sys.exit(1)
        trans_in=int(result.split(",")[1].replace('"',''))/1000000.0
        trans_out=int(result.split(",")[2].replace('"',''))/1000000.0
        trans_total=trans_in+trans_out
        if trans_total<trans_warning:
            print "OK - Traffic in %.2f Mbps, out %.2f Mbps, total %.2f Mbps.|total=%.2f;;;;in=%.2f;;;;out=%.2f;;;;" % (trans_in,trans_out,trans_total,trans_total,trans_in,trans_out)
            sys.exit(0)
        elif trans_total>=trans_warning and trans_total<trans_critical:
            print "Warning - Traffic in %.2f Mbps, out %.2f Mbps, total %.2f Mbps.|total=%.2f;;;;in=%.2f;;;;out=%.2f;;;;" % (trans_in,trans_out,trans_total,trans_total,trans_in,trans_out)
            sys.exit(1)
        elif trans_total>=trans_critical:
            print "Critical - Traffic in %.2f Mbps, out %.2f Mbps, total %.2f Mbps.|total=%.2f;;;;in=%.2f;;;;out=%.2f;;;;" % (trans_in,trans_out,trans_total,trans_total,trans_in,trans_out)
            sys.exit(2)
        
    else:
        print "Critical - Get band info error."
        #logout
        opener.open(logout_url)
        sys.exit(2)
    #logout
    opener.open(logout_url)
else:
    print "Critical - Login error."
    sys.exit(2)

