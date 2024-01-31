#!/bin/bash

RESTIC_VERSION="0.16.3"

# 安装所需软件
install_soft(){
    apt-get update
    # 安装mydumper和定时任务
    apt-get install -y mydumper cron ca-certificates wget

    wget https://soft.xiaoz.org/linux/restic_${RESTIC_VERSION}_linux_amd64
    mv restic_${RESTIC_VERSION}_linux_amd64 /usr/bin/restic
    chmod +x /usr/bin/restic
    chmod +x *.sh
    # 创建数据目录
    mkdir -p ./data
}



# 清理
clean(){
    # 移除wget
    apt-get remove -y wget
    rm -rf /var/lib/apt/lists/*
    rm -rf /var/cache/apt/archives/*.deb
    rm -rf /var/cache/apt/archives/partial/*.deb
}

# 运行
install_soft && install_restic && clean