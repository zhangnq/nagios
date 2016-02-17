#nagios 微信通知脚本

使用前需要去微信公众平台申请一个企业号。

##使用

###配置
config.py

内容类似如下：

CorpID='your corpid'

Secret='your secret'

DEBUG=0

ToUser='xxx'  //系统管理员，默认用户

AgentId=1

###运行
python NotifyByWeixin.py 通知内容

其中通知内容格式分别为：

主机通知："host-@@-111-@@-222-@@-333-@@-444-@@-555-@@-666"

111：通知类型

222：主机名称

333：主机状态

444：主机地址

555：主机详细信息

666：通知联系人

服务通知："service-@@-111-@@-222-@@-333-@@-444-@@-555-@@-666-@@-777"

111：通知类型

222：服务描述

333：主机名称

444：主机地址

555：服务状态

666：服务详细信息

777：通知联系人

###配置

下载脚本到nagios目录，例如/usr/local/nagios/python/weixin，修改config.py配置文件。

nagios配置

commands。cfg文件中添加如下配置：

<
#notify by weixin
define command{
        command_name    notify-host-by-weixin
        command_line    /usr/local/nagios/python/NotifyByWeixin.py "host-@@-$NOTIFICATIONTYPE$-@@-$HOSTNAME$-@@-$HOSTSTATE$-@@-$HOSTADDRESS$-@@-$HOSTOUTPUT$-@@-$CONTACTALIAS$"
}
define command{
        command_name    notify-service-by-weixin
        command_line    /usr/local/nagios/python/NotifyByWeixin.py "service-@@-$NOTIFICATIONTYPE$-@@-$SERVICEDESC$-@@-$HOSTALIAS$-@@-$HOSTADDRESS$-@@-$SERVICESTATE$-@@-$SERVICEOUTPUT$-@@-$CONTACTALIAS$"
}
>