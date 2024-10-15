#!/bin/bash

# 设置颜色
Green="\033[32m"
Red="\033[31m"
Font="\033[0m"

# 检测操作系统
check_os() {
    if grep -q -E "CentOS" /etc/issue || grep -q -E "CentOS" /etc/*-release; then
        OS="CentOS"
    elif grep -q -E "Ubuntu" /etc/issue || grep -q -E "Ubuntu" /etc/*-release; then
        OS="Ubuntu"
    elif grep -q -E "Debian" /etc/issue || grep -q -E "Debian" /etc/*-release; then
        OS="Debian"
    else
        echo -e "${Red}不支持的操作系统${Font}"
        exit 1
    fi
}

# 检测是否为 root 用户
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${Red}请以 root 用户运行此脚本${Font}"
        exit 1
    fi
}

# 获取公网 IP
get_public_ip() {
    PUBLIC_IP=$(curl -s http://whatismyip.akamai.com)
    echo "检测到的公网 IP 为: ${Green}${PUBLIC_IP}${Font}"
    read -p "如果这不是你的公网 IP，请按回车跳过，否则请输入 'y' 确认: " confirm
    if [[ $confirm == "y" ]]; then
        PUBLIC_IP=${PUBLIC_IP}
    else
        read -p "请输入你的公网 IP: " PUBLIC_IP
    fi
}

# 配置 iptables 规则
configure_iptables() {
    read -p "请输入你想要转发的端口（默认为 3389）: " PORT
    PORT=${PORT:-3389}
    echo "配置 iptables 规则..."
    iptables -t nat -A PREROUTING -p tcp --dport ${PORT} -j DNAT --to-destination ${PUBLIC_IP}:3389
    iptables -t nat -A POSTROUTING -d ${PUBLIC_IP} -p tcp --dport 3389 -j SNAT --to-source ${LOCAL_IP}
    echo "iptables 规则配置完成。"
}

# 保存 iptables 规则
save_iptables() {
    if [[ $OS == "CentOS" ]]; then
        service iptables save
    elif [[ $OS == "Ubuntu" ]] || [[ $OS == "Debian" ]]; then
        iptables-save > /etc/iptables/rules.v4
    fi
}

# 卸载脚本
uninstall() {
    iptables -t nat -D PREROUTING -p tcp --dport ${PORT} -j DNAT
    iptables -t nat -D POSTROUTING -d ${PUBLIC_IP} -p tcp --dport 3389 -j SNAT
    echo "iptables 规则已卸载。"
}

# 开机自启动
auto_start() {
    if [[ $OS == "CentOS" ]]; then
        echo "iptables-restore < /etc/sysconfig/iptables" >> /etc/rc.d/rc.local
    elif [[ $OS == "Ubuntu" ]] || [[ $OS == "Debian" ]]; then
        echo "iptables-restore < /etc/iptables/rules.v4" >> /etc/rc.local
    fi
    echo "开机自启动已设置。"
}

# 主函数
main() {
    check_root
    check_os
    get_public_ip
    configure_iptables
    save_iptables
    auto_start
    echo -e "${Green}脚本安装完成，端口转发已设置。${Font}"
}

# 卸载函数
uninstall_script() {
    check_root
    check_os
    uninstall
    echo -e "${Green}脚本已卸载。${Font}"
}

# 显示菜单
show_menu() {
    echo "============= 端口转发脚本 ============="
    echo "1. 安装脚本"
    echo "2. 卸载脚本"
    echo "0. 退出"
    echo "======================================"
    read -p "请选择一个选项: " option
    case $option in
        1) main ;;
        2) uninstall_script ;;
        0) exit 0 ;;
        *) echo "无效的选项，请重新选择。" ;;
    esac
}

# 执行
show_menu
