#!/usr/bin/env python
#coding:utf-8

import urllib2
import urllib
import json
from config import *
import pickle
import datetime,time
import argparse

def url_request(url,values={},method='GET'):
    if method == 'GET':
        if len(values) != 0:
            url_values=urllib.urlencode(values)
            furl=url+'?'+url_values
        else:
            furl=url
        req=urllib2.Request(furl)
    elif method == 'POST':
        #data=urllib.urlencode(values)
        data=json.dumps(values,ensure_ascii=True)
        req=urllib2.Request(url,data)
        req.add_header('Content-Type','application/json')
        req.get_method=lambda: 'POST'
    else:
        pass
    
    try:
        req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36')
        response = urllib2.urlopen(req)
        result=json.loads(response.read())
    except urllib2.URLError as e:
        if hasattr(e, 'code'):
            print 'Error code:',e.code
        elif hasattr(e, 'reason'):
            print 'Reason:',e.reason
        
        result={}
    except:
        result={}

    return result

def get_token():
    data_pkl='token_data.pkl'
    try:
        f=file(data_pkl,'rb')
        data_dict=pickle.load(f)
        f.close()
    except:
        data_dict={}
    try:
        expires_time=data_dict['expires_time']
    except:
        expires_time=0
    now_time=int(time.mktime(datetime.datetime.now().timetuple()))
    if now_time >= expires_time:
        url='https://qyapi.weixin.qq.com/cgi-bin/gettoken'
        values={
                'corpid':CorpID,
                'corpsecret':Secret,
                }
        result=url_request(url, values, method='GET')
        if len(result) != 0:
            now_time=int(time.mktime(datetime.datetime.now().timetuple()))
            expires_time=now_time+7200-10
            result['expires_time']=expires_time
            f=file(data_pkl,'wb')
            pickle.dump(result,f)
            f.close()
            access_token=result['access_token']
        else:
            print "Get token error,exit!"
            access_token=''
    else:
        access_token=data_dict['access_token']
    
    
    return access_token

def send_text_message(token,content):
    url='https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token='+token+'&debug='+str(DEBUG)
    content_data=content.split('-@@-')
    notify_type=content_data[0]
    if notify_type == 'host':
        type1=content_data[1]
        host_name=content_data[2]
        host_state=content_data[3]
        host_address=content_data[4]
        host_info=content_data[5]
        notify_contact=content_data[6]
        notify_content="** Nagios **\n\nNotification Type: "+ type1 + \
                        "\nHost: " + host_name + \
                        "\nState: " + host_state + \
                        "\nAddress: " + host_address + \
                        "\nInfo: " + host_info + "\n"
    elif notify_type == 'service':
        type1=content_data[1]
        service_desc=content_data[2]
        host_name=content_data[3]
        host_address=content_data[4]
        service_state=content_data[5]
        service_info=content_data[6]
        notify_contact=content_data[7]
        notify_content="** Nagios **\n\nNotification Type: "+ type1 + \
                        "\nService: " + service_desc + \
                        "\nHost: " + host_name + \
                        "\nAddress: " + host_address + \
                        "\nState: " + service_state + \
                        "\nInfo: " + service_info + "\n"
    else:
        notify_content="Get nagios message notify info error.\n\nContent: %s" % content
        notify_contact=ToUser
    
    values={
            "touser":notify_contact,
            #"toparty":ToParty,
            "msgtype": "text",
            "agentid": AgentId,
            "text": {
                    "content": notify_content
                    },
            }
    return url_request(url, values, method='POST')

def main():
    token=get_token()
    parser=argparse.ArgumentParser(description="Nagios notify by weixin")
    parser.add_argument("content",default=None,help="notify content,split with -@@-")
    args = parser.parse_args()
    
    content=args.content
    send_text_message(token, content)
    
if __name__ == "__main__":
    #token = get_token()
    #content=u"host-@@-111-@@-222-@@-333-@@-444-@@-测试-@@-zhangnq"
    #send_text_message(token, content)
    main()
    
