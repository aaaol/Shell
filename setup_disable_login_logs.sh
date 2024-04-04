#!/bin/bash

# 定义函数：禁用登录日志记录
disable_login_logs() {
    echo "禁用登录日志记录..."
    sudo sed -i '/auth\|authpriv/ s/^/#/' /etc/rsyslog.conf
    echo "重启rsyslog服务..."
    sudo systemctl restart rsyslog
    echo "登录日志已禁用。"
}

# 定义函数：清空登录日志文件
clear_log_files() {
    echo "清空登录日志文件..."
    sudo truncate -s 0 /var/log/auth.log
    sudo truncate -s 0 /var/log/secure  # 仅适用于部分系统，可以根据实际情况删除或注释此行
    
    # 使用 journalctl 清空 systemd-journald 日志
    echo "清空 systemd-journald 日志..."
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s
    echo "systemd-journald 日志已清空。"
}

# 主函数
main() {
    disable_login_logs
    clear_log_files
}

# 执行主函数
main

# 创建并配置 systemd 服务
create_systemd_service() {
    echo "创建并配置 systemd 服务..."
    
    # 将服务文件写入 /etc/systemd/system/disable_login_logs.service
    sudo tee /etc/systemd/system/disable_login_logs.service > /dev/null <<EOF
[Unit]
Description=Disable login logs and clear log files

[Service]
Type=oneshot
ExecStart=/bin/bash /root/setup_disable_login_logs.sh

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载 systemd 并启用服务
    sudo systemctl daemon-reload
    sudo systemctl enable disable_login_logs.service
    
    echo "systemd 服务已创建并配置完成。"
}

# 执行创建并配置 systemd 服务
create_systemd_service
