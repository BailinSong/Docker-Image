#!/bin/sh
for i in `set|awk -F '=' '{print $1}'`
do
	value=$(eval echo '$'$i)
	sed -i "s^\${$i}^$value^g" /usr/local/tomcat/webapps/mmcp/admin/config/init.conf
done
cat /usr/local/tomcat/webapps/mmcp/admin/config/init.conf
catalina.sh run