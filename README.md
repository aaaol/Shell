
### Shell脚本

每半个小时同步一次时间
~~~
curl -fsSL -o date.sh https://raw.githubusercontent.com/aaaol/Shell_Docker/main/Shell/date.sh && chmod +x date.sh &&./date.sh
~~~

Ubuntu/Debian 删除登录日记 开机自启
~~~
curl -fsSL -o date.sh https://raw.githubusercontent.com/aaaol/Shell_Docker/main/Shell/setup_disable_login_logs.sh && chmod +x date.sh &&./date.sh
~~~ 

一键配置iptables转发 并开机运行脚本
~~~
curl -fsSL -o date.sh https://raw.githubusercontent.com/aaaol/Shell_Docker/main/Shell/iptables_port_forwarding.sh && chmod +x iptables_port_forwarding.sh &&./iptables_port_forwarding.sh
~~~

### Docker脚本

RustDesk 自建Docker中继服务
~~~
curl -fsSL -o docker-compose.yaml https://raw.githubusercontent.com/aaaol/Shell_Docker/main/Docker/docker-compose.yaml && chmod +x docker-compose.yaml &&docker-compose up -d
~~~