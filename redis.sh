#!/bin/bash
#Function:接xn+mysql.sh脚本,实现安装redis
read -p "请指定redis的端口:" rd
read -p "请指定redis的IP:" ip
read -p "是否要修改redis密码[y/n]" y
if [ ${y} == y ];then
  read -p "请输入密码:" mi 
fi

#安装gcc编译工具,并对redis进行编译
yum -y install gcc
cd redis
tar -zxvf redis-4.0.8.tar.gz
cd redis-4.0.8
make&&make install

#初始化配置
#检测有无expect
ex=`rpm -qa expect`
if [ -z $ex ];then
  yum -y install expect*
else
  echo -e "\033[31mexpect已装\033[0m"
fi
expect <<EOF
  spawn ./utils/install_server.sh
  expect "" {send "${rd}\r"}
  expect "" {send "\r"}
  expect "" {send "\r"}
  expect "" {send "\r"}
  expect "" {send "\r"}
  expect "" {send "\r"}
  expect "#" {send "/etc/init.d/redis_${rd} stop\r"}
EOF

#修改配置文件
sed -i "70s/.*/bind ${ip}/" /etc/redis/${rd}.conf
sed -i "93s/.*/port ${rd}/" /etc/redis/${rd}.conf
if [ ${y} == y ];then
  sed -i "501s/.*/requirepass ${mi}/" /etc/redis/${rd}.conf
fi
sed -i  '43s/.*/            $CLIEXEC -h '${ip}' -p '${rd}'  shutdown/' /etc/init.d/redis_${rd}
#集群配置
#rm -rf /var/lib/redis/${rd}/*
#sed -i  '815s/.*/cluster-enabled yes/' /etc/redis/${rd}.conf
#sed -i  '823s/.*/cluster-config-file nodes-'${rd}'.conf/' /etc/redis/${rd}.conf
#sed -i  '829s/.*/cluster-node-timeout 5000/' /etc/redis/${rd}.conf
rm -rf /var/run/redis_${rd}.pid
/etc/init.d/redis_${rd} start

