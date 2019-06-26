#!/bin/bash
#Function:一键生成虚拟机,并配置好IP地址、扩容、安装好mysql相应的包.并启动mysql
read -p "输入虚拟机号码  " clone
read -p "输入要配置的网卡/eth0/eth1/eth2/eth3/  " eth
read -p "输入要配置的ip  " ip 
read -p "要修改的主机名  " hs
function yum{
  rm -rf /etc/yum.repos.d/*
  

#检测真机有没有expect
ex=`rpm -qa expect`
if [ -z $ex ];then
  yum -y install expect*
else
  echo -e "\033[31mexpect已装\033[0m"
fi

#生成新的前端盘和xml配置文件
qemu-img create -f qcow2 -b /var/lib/libvirt/images/.node_tedu.qcow2 /var/lib/libvirt/images/tedu_node${clone}.img 20G
cp /var/lib/libvirt/images/.node_tedu.xml /etc/libvirt/qemu/"$clone".xml
sed -in "2s!.*!<name>${clone}</name>!" /etc/libvirt/qemu/"$clone".xml
sed -in "26s!.*!<source file='/var/lib/libvirt/images/tedu_node${clone}.img'/>!" /etc/libvirt/qemu/"$clone".xml

#virsh管理虚拟机配置ip,主机名
virsh define /etc/libvirt/qemu/"$clone".xml
virsh start ${clone}
sleep 20
expect <<EOF
  spawn virsh console ${clone}
  expect "\n"  {send "\r"}
  expect "*login*"  {send "root\r"}
  expect "*Password*"  {send "123456\r"}
  expect "#"  {send "nmcli connection modify $eth ipv4.method manual ipv4.addresses ${ip}/24 connection.autoconnect yes\r"}
  expect "#"  {send "nmcli connection up ${eth}\r"}
  expect "#"  {send "hostnamectl set-hostname $hs\r"}
  expect "#"  {send "LANG=en growpart /dev/vda 1\r"}
  expect "#"  {send "xfs_growfs /dev/vda1\r"}
  expect eof
EOF

#真机发送mysqld软件包和MHA集群用的软件包
scp /linux-soft/03/mysql/* root@${ip}:/root
scp /root/ssh.sh root@${ip}:/root
scp /linux-soft/03/mysql/mha-soft-student/mha4mysql-manager-0.56.tar.gz root@${ip}:/root
scp /linux-soft/03/mysql/mha-soft-student/mha4mysql-node-0.56-0.el6.noarch.rpm root@${ip}:/root

scp /linux-soft/03/mysql/mha-soft-student/perl-* root@${ip}:/root

#重新管理虚拟机,安装mysql
expect <<EOF
  spawn virsh console ${clone}
  expect "\n"  {send "\r"}
  expect "#"  {send "tar -xf mysql-5.7.17.tar\r"}
  expect "#"  {send "yum -y install mysql-community*.rpm\r"}
  expect "#"  {send "ssh-keygen -f /root/.ssh/id_rsa -N ''\r"}
  expect "#"  {send "systemctl restart mysqld\r"}
  expect "#"  {send "systemctl enable mysqld\r"}
  expect eof
EOF
ssh -X root@"${ip}"
