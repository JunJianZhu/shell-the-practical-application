#!/bin/bash
read -p "请输入要配置的网卡(eth0/eth1/eth2/eth3):"  et
read -p "请输入要配置的IP地址:"  ip
read -p "请输入网关(可不填):" w
if [ -z $w ];then
#配置网卡ip
  nmcli connection modify "$et" ipv4.method manual ipv4.addresses "${ip}/24" connection.autoconnect yes
#激活网卡
  nmcli connection up "${et}"
else
#配置网卡ip
  nmcli connection modify "$et" ipv4.method manual ipv4.addresses "${ip}/24" ipv4.gateway "${w}" connection.autoconnect yes
#激活网卡
  nmcli connection up "${et}"
fi
#清空yum仓库,以免影响正确配置
rm -rf /etc/yum.repos.d/*
read -p "yum库ftp的ip地址(例:192.168.4.254)(可不填):" i
if [ -z $i ];then
  echo "不设置，yum可能会有点问题哦，建议yum repolist查看"
else
#配置yum仓库
echo -e "[redhat]\nname=redhat\nbaseurl=ftp://192.168.4.254/centos-1804\nenabled=1\ngpgcheck=0\n[mon]\name=mon\nbaseurl=ftp://${i}/ceph/MON\ngpgcheck=0\n[osd]\nname=osd\nbaseurl=ftp://${i}/ceph/OSD\ngpgcheck=0\n[tools]\nname=tools\nbaseurl=ftp://${i}/ceph/Tools\ngpgcheck=0" > /etc/yum.repos.d/linux.repo
fi
