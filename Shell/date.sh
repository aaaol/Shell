#!/bin/bash

enable_autosync() {
    # 设置时区为上海
    timedatectl set-timezone Asia/Shanghai

    # 安装 systemd-timesyncd（如果尚未安装）
    sudo apt-get update
    sudo apt-get install -y systemd-timesyncd

    # 开启自动同步时间
    sudo systemctl enable systemd-timesyncd
    sudo systemctl start systemd-timesyncd

    # 设置定时同步任务，每半个小时一次
    if [ ! -f /etc/systemd/system/autosync.timer ]; then
        cat <<EOL | sudo tee /etc/systemd/system/autosync.timer > /dev/null
[Unit]
Description=Auto Sync Time Timer

[Timer]
OnCalendar=*:0/30
Persistent=true

[Install]
WantedBy=timers.target
EOL
        sudo systemctl enable autosync.timer
        sudo systemctl start autosync.timer
    fi

    echo "自动同步时间已开启，并设置为每半小时一次。"
}

disable_autosync() {
    # 关闭自动同步时间
    sudo systemctl stop systemd-timesyncd
    sudo systemctl disable systemd-timesyncd

    # 禁用定时同步任务
    sudo systemctl stop autosync.timer
    sudo systemctl disable autosync.timer

    echo "自动同步时间已关闭。"
}

# 显示菜单
echo "选择操作:"
echo "1. 开启自动同步时间"
echo "2. 关闭自动同步时间"
read -p "请输入选项 (1 或 2): " choice

case $choice in
    1)
        enable_autosync
        ;;
    2)
        disable_autosync
        ;;
    *)
        echo "无效的选项。"
        ;;
esac
