#!/bin/bash
#监控脚本
echo "CPU负载:$(uptime  | awk '{print $8,$9,$10}')"
echo "网卡流量:$(ifconfig eth0 | awk '/RX p/{print $3}')"
echo "内存剩余容量:$(free -m | awk '/M/{print $4}')"
echo -e "磁盘剩余容量:\n$(df -h | awk '{print $4}')"
echo "计算机账户数量:$(cat /etc/passwd | awk -F: 'BEGIN{x=0}{$1;x++}END{print x}')"
echo "当前登录账户数量:$(who | wc -l)"
echo "计算机当前开启的进程数:$(ps aux | awk 'BEGIN{a=0}{$1 a++}END{print a}')"
echo "本机已安装的软件包数量:$(rpm -qa | wc -l)"


