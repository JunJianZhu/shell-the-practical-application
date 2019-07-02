#!/bin/bash
#Function:一键配置ip和搭建yum
wd(){
ip01=`echo ${ip:0:3}`
ip02=`echo ${ip:4:3}`
ip03=`echo ${ip:8:1}`
eip=${ip01}.${ip02}.${ip03}.254
sip=`grep baseurl /etc/yum.repos.d/local.repo | awk -F "/" '{print $3}'` &> /dev/null
sed -i "/baseurl/s/${sip}/${eip}/" /etc/yum.repos.d/local.repo
}
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
#配置yum仓库
   wd
