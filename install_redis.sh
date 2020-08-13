#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
RDSPID=$(cat /var/run/redis_6379.pid)
function check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用 sudo -i来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
function check_env(){
sudo yum -y install epel-release
sudo yum -y install wget pcre-devel openssl openssl-devel gcc gcc-c++ tcl make vim
}
function check_port(){
        CHKPO=$(netstat -ntlp |grep 6379|awk '{print $4}'|awk -F : '{print $2}')
        if [[ $CHKPO == 6379 ]]
        then
            echo -e "6379端口被占用" && exit 1
        else
            echo -e "6379未被占用,进行安装"
        fi
}
function install_redis(){
sudo mkdir -p /usr/local/redis
sudo mkdir -p /usr/local/redis/conf
sudo mkdir -p /usr/local/redis/log
sudo chmod 755 /usr/local/redis
sudo chmod 755 /usr/local/redis/log
sudo chmod 755 /usr/local/redis/conf
sudo https://mirrors.valarx.com/redis-4.0.11.tar.gz
sudo tar -zxvf redis-4.0.11.tar.gz
cd redis-4.0.11/
sudo make MALLOC=libc
cd src
sudo make test
sudo make PREFIX=/usr/local/redis install
}
function check_config(){
sudo cp /root/redis-4.0.11/redis.conf /usr/local/redis/conf
sed -i "68,70s/bind 127.0.0.1/bind 0.0.0.0/g" /usr/local/redis/conf/redis.conf
sed -i "87,89s/protected-mode yes/protected-mode no/g" /usr/local/redis/conf/redis.conf
sed -i "135,137s/daemonize no/daemonize yes/g" /usr/local/redis/conf/redis.conf
sed -i '171c\logfile "\/usr\/local\/redis\/log\/redis.log"' /usr/local/redis/conf/redis.conf
}
function check_firewall(){
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 6379 -j ACCEPT
		#iptables -I INPUT -p tcp --dport 27017 -j ACCEPT
		#iptables -I INPUT -p tcp --dport 9200 -j ACCEPT
		#iptables -I INPUT -p tcp --dport 9300 -j ACCEPT
		service iptables save
		service iptables restart
		echo "##############################iptables配置完成##############################"
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --add-port=6379/tcp --permanent
		# firewall-cmd --zone=public --add-port=27017/tcp --permanent
		# firewall-cmd --zone=public --add-port=9200/tcp --permanent
		# firewall-cmd --zone=public --add-port=9300/tcp --permanent
        # firewall-cmd --zone=public --add-port=12201/tcp --permanent
		firewall-cmd --reload
		echo "##############################firewall配置完成##############################"
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw allow 6379/tcp
		# sudo ufw allow 9200/tcp
		# sudo ufw allow 9300/tcp
		# sudo ufw allow 27017/tcp
		echo "##############################ufw配置完成##############################"
	fi
}
function start_redis(){
	if [ -e "/var/run/redis_6379.pid" ]
	then
		echo "Redis_6379已启动，请勿重复启动"
	else
		/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf
		echo "启动Redis-server"
	fi
}
function stop_redis(){
	kill -9 ${RDSPID}
	echo "已结束Redis进程"
}
function restart_redis(){
	RDSPID=$(cat /var/run/redis_6379.pid)
	kill -9 ${RDSPID}
	/usr/local/redis/bin/redis-server /usr/local/redis/conf/redis.conf
	echo "Redis-server重启完成"
}
function check_success(){
	echo "##########################################"
	echo "Redis 4.0.11安装完成"
	echo "Redis已启动成功，默认端口6379"
	echo "安装目录在/usr/local/redis"
	echo "配置文件在/usr/local/redis/conf"
	echo "日志在/usr/local/redis/log/redis.log"
	echo "##########################################"
}
echo "Centos7 Redis 4.0.11一键安装脚本(默认6379)"
echo "1) 安装Redis"
echo "2) 启动Redis_6379"
echo "3) 停止Redis_6379"
echo "4) 重启Redis_6379"
echo "5) 退出"
read -p "请输入选项:" num
case $num in
	1)
		check_root 
		check_env && \
		check_port && \
		install_redis && \
		check_config && \
		check_firewall && \
		start_redis && \
		check_success
	;;
	2)
		start_redis
	;;
	3)
		stop_redis
	;;
	4) 	restart_redis
	;;
	5)
		exit
	;;
	*) 
		echo "输入错误"
esac



