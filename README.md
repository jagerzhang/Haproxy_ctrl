# Haproxy_ctrl
## Haproxy 服务控制脚本

对比已有的Haproxy脚本，我编写的时候新增了如下实用功能：

- 支持配置文件语法测试
- 支持进程的监控（自拉起）功能
- 重启之前会先检测配置语法，规避因配置错误导致重启后进程挂掉
- 支持多配置文件模式（按照前文约定目录存放拓展配置，脚本将自动识别）

## 使用方法

### 注册服务

保存为 /usr/local/haproxy/sbin/haproxy_ctrl.sh，赋可执行权限，如下注册系统服务：
```
chmod +x /usr/local/haproxy/sbin/haproxy_ctrl.sh
ln -sf /usr/local/haproxy/sbin/haproxy_ctrl.sh  /etc/init.d/haproxy
chkconfig haproxy on
```

服务控制：
```
启动：service haproxy start
停止：service haproxy stop
重载：service haproxy restart
状态：service haproxy status
检查：service haproxy test
监控：service haproxy mon  
```

进程自拉起，如有告警通道可自行加入
```
启动：service haproxy start
停止：service haproxy stop
重载：service haproxy restart
状态：service haproxy status
检查：service haproxy test
监控：service haproxy mon  # 进程自拉起，如有告警通道可自行加入
```

###配置自拉起
```
* * * * * bash /usr/local/haproxy/haproxy_ctrl.sh mon >/dev/null 2>&1
```

详细说明 ：https://zhangge.net/5125.html
