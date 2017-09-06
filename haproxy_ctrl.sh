#configure haproxy.cfg
global
    log 127.0.0.1   local0
    maxconn 4096              #最大连接数
    chroot /usr/local/haproxy #安装目录
    uid 99                    #用户nobody
    gid 99                    #组nobody
    daemon                    #守护进程运行
    nbproc 1                  #进程数量
    pidfile /usr/local/haproxy/logs/haproxy.pid #haproxy pid

defaults
   log     global
   mode    http               #7层 http;4层tcp  如果要让haproxy支持虚拟主机，mode 必须设为http 
   option  httplog            #http 日志格式
   log 127.0.0.1 local6
   option  httpclose          #主动关闭http通道
   option  redispatch         #serverId对应的服务器挂掉后,强制定向到其他健康的服务器
   retries 1
   option  dontlognull
   maxconn 2000                     #最大连接数
   timeout connect      3600000     #连接超时(毫秒)
   timeout client      3600000      #客户端超时(毫秒)
   timeout server      3600000      #服务器超时(毫秒)

frontend default   
        option  httplog
        option  httpclose
        bind 0.0.0.0:80
        # 状态页面规则
        acl haproxy_stats   path_beg /haproxy
        use_backend haproxy_stats if haproxy_stats
        # 其他
        # default_backend default_server
        # 提升失败的时候的用户体验
        #errorfile 502 /usr/local/haproxy/html/maintain.html
        #errorfile 503 /usr/local/haproxy/html/maintain.html
        #errorfile 504 /usr/local/haproxy/html/maintain.html

# 状态页面
backend haproxy_stats
    stats uri /haproxy
    stats enable
    stats refresh 60s
    #stats auth admin:admin  # 状态页面认证配置
    stats admin if TRUE
