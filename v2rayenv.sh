#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
yum install python3 python3-devel gcc gcc-c++ mariadb mariadb-devel lrzsz -y 
pip3 install pymysql mysqlclient 
