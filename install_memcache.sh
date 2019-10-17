#!/bin/bash
#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH
#环境检测
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
function check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
function check_system(){
	if [ -e "/usr/bin/yum" ]
	then
        echo "#################################################################"
        echo "该操作系统为${Green_background_prefix} Centos ${Font_color_suffix}"
        echo "该操作系统为${Green_background_prefix} Centos ${Font_color_suffix}"
        echo "该操作系统为${Green_background_prefix} Centos ${Font_color_suffix}"
        echo "#################################################################"
		sudo yum -y install curl gcc gcc-c++ gcc+ make wget pcre-devel openssl openssl-devel
	else
		echo "#################################################################"
        echo "该操作系统为${Font_color_suffix} Ubuntu/Debian ${Font_color_suffix}"
        echo "该操作系统为${Font_color_suffix} Ubuntu/Debian ${Font_color_suffix}"
        echo "该操作系统为${Font_color_suffix} Ubuntu/Debian ${Font_color_suffix}"
        echo "#################################################################"
        #更新软件，否则可能make命令无法安装
		#sudo apt-get update
		sudo apt-get install -y curl gcc-c++ gcc+ make wget pcre-devel openssl openssl-devel
	fi
    osip=$(curl -4s https://api.ip.sb/ip)
    for ((i=0;i<20;i++))
    do
      echo "本机IP为：[ $i ] ${Green_background_prefix} $osip ${Font_color_suffix}"
    done
}

function install_libevent(){
    echo "#############################安装libevent##########################################"
    cd /usr/local/
    mkdir libevent
    wget --no-check-certificate https://arya.valarx.com/mirrors/libevent-2.0.22-stable.tar.gz
    tar -zxvf libevent-2.0.22-stable.tar.gz
    cd libevent-2.0.22-stable/
    ./configure -prefix=/usr/local/libevent
    make && make install
    echo "#############################Install Libevent Success##########################################"
}
function install_memcache(){
    echo "#############################安装memcache##########################################"
    cd /usr/local/
    mkdir memcached
    wget --no-check-certificate https://arya.valarx.com/mirrors/memcached-1.5.16.tar.gz
    tar -zxvf memcached-1.5.16.tar.gz
    mv memcached-1.5.16/ memcache
    cd memcache
    ./configure -prefix=/usr/local/memcached -with-libevent=/usr/local/libevent/
    make && make install
    cd /usr/local/memcached/bin
    ls -al mem*
    echo "#############################安装memcache完成##########################################"
}
function add_firewall(){
    echo "#############################添加firewall规则##########################################"
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 11211 -j ACCEPT
		service iptables save
		service iptables restart
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --add-port=11211/tcp --permanent
		firewall-cmd --reload
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw allow 11211/tcp

	fi
    echo "#############################firewall规则添加完成##########################################"
}
function clean_up(){
    cd /usr/local/
    rm -f libevent-2.0.22-stable.tar.gz
    rm -f memcached-1.5.16.tar.gz
}
function memcache_port(){
    cd /usr/local/
    wget --no-check-certificate https://arya.valarx.com/mirrors/memcache_21211
}
function show_info(){
    echo "#####memcache安装目录/usr/local/memcached#####"
    echo "#####memcache执行文件路径/usr/local/memcached/bin#####"
    echo "#####默认开放TCP=11211端口#####"
    echo "#########/usr/local/memcache_11211修改为自己想要的端口放入/etc/init.d/中启动"
}
#选择安装方式
echo "################################################"
echo "Centos7 + memcache1.5.16一键安装脚本"
echo "1) 安装memcache"
echo "2) 清理安装包"
echo "3) 退出"
read -p ":" num
case $num in
    1) 
    	check_root
    	check_system && \
        install_libevent && \
    	install_memcache && \
        add_firewall && \
        clean_up && \
        memcache_21211 && \
        show_info
    ;;
    2) 
    	clean_up
    ;;
    3)
        exit
    ;;
    *) echo '输入错误！'
esac