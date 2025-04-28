#!/bin/bash

# 配置 Docker 和相关工具的 HTTP/HTTPS 代理（Clash 端口 7897）
export HTTP_PROXY="http://127.0.0.1:7897/"
export HTTPS_PROXY="http://127.0.0.1:7897/"
export NO_PROXY="127.0.0.1,localhost,192.168.0.0/16"

# 脚本保存路径
SCRIPT_PATH="$HOME/Spheron.sh"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 部署节点"
        echo "2. 查看日志"
        echo "3. 停止节点"
        echo "4. 查看版本"
        echo "5. 退出"

        read -p "请输入选项 [1-5]: " choice

        case $choice in
            1)
                deploy_node
                ;;
            2)
                view_logs
                ;;
            3)
                stop_node
                ;;
            4)
                version
                ;;
            5)
                echo "感谢使用，再见！"
                exit 0
                ;;
            *)
                echo "无效的选项，请重新选择。"
                read -p "按任意键继续..."
                ;;
        esac
    done
}

# 部署节点函数
function deploy_node() {
    echo "正在检查 Docker 是否安装..."
    if ! command -v docker &> /dev/null; then
        echo "Docker未安装，正在安装Docker..."

        # 更新系统
        sudo apt update -y && sudo apt upgrade -y

        # 移除可能存在的Docker相关包
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
            sudo apt-get remove -y $pkg
        done

        # 安装必要的依赖
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg

        # 添加Docker的GPG密钥
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # 添加Docker的APT源
        echo \
          "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # 更新APT源并安装Docker
        sudo apt update -y && sudo apt upgrade -y
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # 确保docker-compose可执行
        sudo chmod +x /usr/local/bin/docker-compose

        # 检查Docker版本
        echo "Docker安装完成，版本为：$(docker --version)"
    else
        echo "Docker已安装，版本为：$(docker --version)"
    fi

    # 创建spheron目录（如果不存在）
    mkdir -p ~/spheron

    # 下载并执行sphnctl.sh脚本到spheron目录
    echo "正在下载并执行sphnctl.sh脚本到 ~/spheron 目录..."
    curl -sL1 https://sphnctl.sh -o ~/spheron/sphnctl.sh

    echo "下载完成：~/spheron/sphnctl.sh"

    # 赋予sphnctl.sh执行权限
    chmod +x /root/spheron/sphnctl.sh
    
    # 删除原有的文件
    sudo rm -rf /usr/local/bin/sphnctl

    # 进入spheron目录并运行脚本
    cd ~/spheron
    echo "正在运行脚本：fizzup.sh"

    # 提示用户输入Token
    read -p "请输入您的Token（例如：0x3a5d08256479bf4d57af8...）: " user_token
    
    # 使用提供的Token启动fizz
    echo "正在使用提供的Token启动fizz，请稍等..."

    # 执行命令
    ~/spheron/sphnctl.sh fizz start --token "$user_token"

    # 再次执行命令
    sphnctl fizz start --token "$user_token"

    read -p "按任意键返回主菜单..."
}

# 查看日志函数
function view_logs() {
    echo "正在查看日志..."
    sphnctl fizz logs
    read -p "按任意键返回主菜单..."
}

# 查看版本
function version() {
    echo "正在查看目前版本..."
    sphnctl fizz version
    read -p "按任意键返回主菜单..."
}

# 添加停止节点函数
function stop_node() {
    echo "正在停止节点..."
    if [ -f ~/.spheron/fizz/docker-compose.yml ]; then
        docker compose -f ~/.spheron/fizz/docker-compose.yml down
        sphnctl fizz stop
        echo "节点已成功停止"
    else
        echo "未找到节点配置文件，请确认节点是否已部署"
    fi
    read -p "按任意键返回主菜单..."
}

# 启动主菜单
main_menu
