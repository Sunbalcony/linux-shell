#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
function check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用 sudo -i来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
function check_env(){
	if [ -e "/usr/bin/yum" ]
	then
		sudo yum -y install epel-release
                sudo yum -y install wget pcre-devel openssl openssl-devel gcc gcc-c++ tcl make vim net-tools
                yum -y install erlang
	else
		exit 1
		
	fi
}
function check_port(){
        CHKPO=$(netstat -ntlp |grep 4369|awk '{print $4}'|awk -F : '{print $2}')
        if [[ $CHKPO == 4369 ]]
        then
            echo -e "4369端口被占用" && exit 1
        else
            echo -e "#######4369未被占用,10S后将进行安装############"
            sleep 10
        fi
}
###cat /var/lib/rabbitmq/.erlang.cookie
function install_rbq(){
        rpm --import http://mirrors.valarx.com/rabbitmq-release-signing-key.asc
        #yum -y install https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
        yum -y install http://mirrors.valarx.com/rabbitmq-server-3.6.10-1.el7.noarch.rpm
        echo "启动Rabbitmq-server"
        systemctl enable rabbitmq-server
        systemctl start rabbitmq-server
        echo "启用Rabbitmq-web插件"
        rabbitmq-plugins enable rabbitmq_management
}
function check_admin(){
        read -p "请输入管理员账号:" acc
        while [ -z "${acc}" ]
        do
                read -p "请输入管理员账号:" acc
        done
        echo 
        read -p "请输入管理员账号密码" accpwd
        while [ -z "${accpwd}" ]
        do
                read -p "请输入管理员账号密码" accpwd
        done
        rabbitmqctl add_user ${acc} ${accpwd}
        rabbitmqctl set_user_tags ${acc} administrator
        rabbitmqctl set_permissions -p / ${acc} ".*" ".*" ".*"
        echo "设置管理员账号${acc},密码${accpwd}完成"
        sleep 5
}
function check_firewall(){
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 5672 -j ACCEPT
		iptables -I INPUT -p tcp --dport 15672 -j ACCEPT
		iptables -I INPUT -p tcp --dport 25672 -j ACCEPT
		service iptables save
		service iptables restart
		echo "##############################iptables配置完成##############################"
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --add-port=5672/tcp --permanent
		firewall-cmd --zone=public --add-port=15672/tcp --permanent
		firewall-cmd --zone=public --add-port=25672/tcp --permanent
		firewall-cmd --reload
		echo "##############################firewall配置完成##############################"
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw allow 5672/tcp
		sudo ufw allow 15672/tcp
		sudo ufw allow 25672/tcp
		echo "##############################ufw配置完成##############################"
	fi
}
function check_start(){
        CHKPO=$(netstat -ntlp |grep 4369|awk '{print $4}'|awk -F : '{print $2}')
        if [[ $CHKPO == 4369 ]]
        then
                echo -e "Rabbitmq已启动，无需重启启动" && exit 1
        else
                echo -e "启动Rabbitmq"
                systemctl start rabbitmq-server
                sleep 5
        fi
}
function check_success(){
        elcok=$(cat /var/lib/rabbitmq/.erlang.cookie)
        echo "Rabbitmq安装完成"
        echo "Rabbitmq已启动"
        echo "erlang.cookie位置为/var/lib/rabbitmq/.erlang.cookie"
        echo "本机的erlang.cookie为：${elcok}"
}
echo "Centos7 Rabbitmq 3.6.10 一键安装脚本"
echo "1) 安装rabbbitmq"
echo "2) 启动rabbbitmq"
echo "3) 停止rabbbitmq"
echo "4) 重启rabbbitmq"
read -p "请输入选项:" num
case $num in
        1)
                check_root
                check_env && \
                check_port && \
                install_rbq && \
                check_admin && \
                check_firewall && \
                check_success
        ;;
        2)
                check_start
        ;;
        3)
                systemctl stop rabbitmq-server
        ;;
        *)
                echo "输入错误" && exit
esac



