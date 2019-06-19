#!/bin/bash
read -p "输入虚拟机号码  " clone
read -p "输入要配置的网卡/eth0/eth1/eth2/eth3/  " eth
read -p "输入要配置的ip  " ip 
read -p "要修改的主机名  " hs

#生成新的前端盘和xml配置文件
qemu-img create -f qcow2 -b /var/lib/libvirt/images/.node_tedu.qcow2 /var/lib/libvirt/images/tedu_node${clone}.img 20G
cp /var/lib/libvirt/images/.node_tedu.xml /etc/libvirt/qemu/"$clone".xml
sed -in "2s!<name>node_tedu</name>!<name>${clone}</name>!" /etc/libvirt/qemu/"$clone".xml
sed -in "26s!<source file='/var/lib/libvirt/images/node_tedu.img'/>!<source file='/var/lib/libvirt/images/tedu_node${clone}.img'/>!" /etc/libvirt/qemu/"$clone".xml

#virsh管理虚拟机配置ip,主机名
virsh define /etc/libvirt/qemu/"$clone".xml
virsh start ${clone}
sleep 20
expect <<EO
  spawn virsh console ${clone}
  expect "\n" 
  send "\r"
  expect "*login*" 
  send "root\r"
  expect "*Password*" 
  send "123456\r"
  expect "#" 
  send "nmcli connection modify $eth ipv4.method manual ipv4.addresses ${ip}/24 connection.autoconnect yes\r"
  expect "#"
  send "nmcli connection up ${eth}\r"
  expect "#"
  send "hostnamectl set-hostname $hs\r"
  expect eof
EO

#发送mysqld软件包
scp /linux-soft/03/mysql/* root@${ip}:/root
scp /root/ssh.sh root@${ip}:/root
ssh -X root@"${ip}"
