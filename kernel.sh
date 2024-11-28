#!/bin/bash

# 检查是否为 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户运行此脚本。"
    exit 1
fi

# 内核下载地址
KERNEL_URL="http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/"

# 内核包名称
KERNEL_LT_DEVEL="kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64.rpm"
KERNEL_LT="kernel-lt-5.4.278-1.el7.elrepo.x86_64.rpm"

# 临时目录
TEMP_DIR="/tmp/kernel-update"

# 创建临时目录
mkdir -p $TEMP_DIR
cd $TEMP_DIR || exit 1

# 下载内核包和开发工具包
echo "正在下载内核包和开发工具包..."
curl -O ${KERNEL_URL}${KERNEL_LT_DEVEL}
curl -O ${KERNEL_URL}${KERNEL_LT}

# 检查文件是否下载成功
if [ ! -f $KERNEL_LT ] || [ ! -f $KERNEL_LT_DEVEL ]; then
    echo "内核包或开发工具包下载失败，请检查网络连接或 URL 是否正确。"
    exit 1
fi

# 安装内核及开发工具包
echo "安装内核开发工具包：$KERNEL_LT_DEVEL"
rpm -ivh $KERNEL_LT_DEVEL
if [ $? -ne 0 ]; then
    echo "开发工具包安装失败。"
    exit 1
fi

echo "安装内核包：$KERNEL_LT"
rpm -ivh $KERNEL_LT
if [ $? -ne 0 ]; then
    echo "内核安装失败。"
    exit 1
fi

# 查看已安装的内核
echo "查看已安装的内核："
rpm -qa | grep kernel

# 设置启动项
echo "配置启动项..."
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
grub2-set-default 0

# 生成 GRUB 配置文件
echo "生成 GRUB 配置文件..."
grub2-mkconfig -o /boot/grub2/grub.cfg

# 重启系统提示
echo "内核安装完成，系统将立即重启。"
echo "如果需要查看当前内核，请重启后执行：uname -r"
reboot -h now
