#nagios 微信通知脚本

使用前需要去微信公众平台申请一个企业号。

##使用

###配置
config.py

内容类似如下：

>CorpID='your corpid'  
>Secret='your secret'  
>DEBUG=0  
>ToUser='xxx'  //系统管理员，默认用户  
>AgentId=1  

###运行

>python NotifyByWeixin.py 通知内容

其中通知内容格式分别为：

主机通知："host-@@-111-@@-222-@@-333-@@-444-@@-555-@@-666"

>111：通知类型  
>222：主机名称  
>333：主机状态  
>444：主机地址  
>555：主机详细信息  
>666：通知联系人  

服务通知："service-@@-111-@@-222-@@-333-@@-444-@@-555-@@-666-@@-777"

>111：通知类型  
>222：服务描述  
>333：主机名称  
>444：主机地址  
>555：服务状态  
>666：服务详细信息  
>777：通知联系人  

###配置

下载脚本到nagios目录，例如/usr/local/nagios/python/weixin，修改config.py配置文件。

nagios配置

commands.cfg命令文件中添加weixin命令：

>#notify by weixin  
>define command{  
>        command_name    notify-host-by-weixin  
>        command_line    /usr/local/nagios/python/NotifyByWeixin.py "host-@@-$NOTIFICATIONTYPE$-@@-$HOSTNAME$-@@-$HOSTSTATE$-@@-$HOSTADDRESS$-@@-$HOSTOUTPUT$-@@-$CONTACTALIAS$"  
>}  
>define command{  
>        command_name    notify-service-by-weixin  
>        command_line    /usr/local/nagios/python/NotifyByWeixin.py "service-@@-$NOTIFICATIONTYPE$-@@-$SERVICEDESC$-@@-$HOSTALIAS$-@@-$HOSTADDRESS$-@@-$SERVICESTATE$-@@-$SERVICEOUTPUT$-@@-$CONTACTALIAS$"  
>}  

templates.cfg模板文件中添加联系人模板：

>define contact{  
>        name                            weixin-contact  
>        service_notification_period     24x7  
>        host_notification_period        24x7  
>        service_notification_options    w,u,c,r,f,s  
>        host_notification_options       d,u,r,f,s  
>        service_notification_commands   notify-service-by-weixin  
>        host_notification_commands      notify-host-by-weixin  
>        register                        0  
>}  

contacts.cfg联系人中添加微信通知联系人，例如：

>define contact{  
>        contact_name                    zhangnq-weixin  
>        use                             weixin-contact  
>        alias                           zhangnq  
>        email                           admin@nbhao.org  
>}  

最后在配置service的时候添加zhangnq-weixin这个联系人后就可以通过微信发送报警邮件了。

