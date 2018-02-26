#!/bin/sh
local_lan_ip=$(ifconfig |grep Bcast:|awk '{print $2}'|awk -F":" '{print $2}')
echo "java -server -DUser_home=/var/log/csmp/$1/$local_lan_ip/ -jar csmp.jar -f:./conf/ProcessNode/Null.xml -c:$1"
java -server -DUser_home=/var/log/csmp/$1/$local_lan_ip/ -jar csmp.jar -f:./conf/ProcessNode/Null.xml -c:$1
