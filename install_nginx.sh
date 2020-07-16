#!/bin/bash
#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH
#环境检测
function check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
function check_system(){
	if [ -e "/usr/bin/yum" ]
	then
        echo "-----------------------------------------------------------------"
        echo "该操作系统为${Green_background_prefix} Centos ${Font_color_suffix}"
        echo "该操作系统为${Green_background_prefix} Centos ${Font_color_suffix}"
        echo "该操作系统为${Green_background_prefix} Centos ${Font_color_suffix}"
        echo "-----------------------------------------------------------------"
		sudo yum -y install curl gcc gcc-c++ gcc+ make wget pcre-devel openssl openssl-devel
	else
		echo "-----------------------------------------------------------------"
        echo "该操作系统为${Font_color_suffix} Ubuntu/Debian ${Font_color_suffix}"
        echo "该操作系统为${Font_color_suffix} Ubuntu/Debian ${Font_color_suffix}"
        echo "该操作系统为${Font_color_suffix} Ubuntu/Debian ${Font_color_suffix}"
        echo "-----------------------------------------------------------------"
        #更新软件，否则可能make命令无法安装
		#sudo apt-get update
		sudo apt-get install -y curl gcc-c++ gcc+ make wget pcre-devel openssl openssl-devel
	fi
    osip=$(curl -4s https://api.ip.sb/ip)
    for ((i=0;i<20;i++))
    do
      echo "本机IP为：$i: $osip "
    done
}

function install_cpan(){
    echo "-----------------------------安装cpan-------------------------------------"
    cd /usr/local/
    if [ -e perl-5.24.1.tar.gz]
    then
        echo "cpan存在准备解压编译"
        tar zxvf perl-5.24.1.tar.gz 
        cd perl-5.24.1
        ./Configure -des -Dprefix=/usr/local/perl
        make && make install
        cd /usr/bin/
        mv -f perl perl.old
        ln -s /usr/local/perl/bin/perl /usr/bin/perl
    else
        echo "cpan不存在准备下载"
        wget http://mirrors.valarx.com/perl-5.24.1.tar.gz
        tar zxvf perl-5.24.1.tar.gz 
        cd perl-5.24.1
        ./Configure -des -Dprefix=/usr/local/perl
        make && make install
        cd /usr/bin/
        mv -f perl perl.old
        ln -s /usr/local/perl/bin/perl /usr/bin/perl
    fi
    echo "-----------------------------cpan安装完成-------------------------------------"
}
###安装openssl###
function install_openssl(){
    echo "-----------------------------安装openssl-------------------------------------"
    cd /usr/local/
    wget http://mirrors.valarx.com/openssl-1.0.1q.tar.gz
    tar zxvf openssl-1.0.1q.tar.gz
    cd openssl-1.0.1q
    ./config -Wl,--enable-new-dtags,-rpath,'$(LIBRPATH)' --prefix=/usr/local/ssl shared zlib-dynamic
    make && make install 
    cd /usr/bin/
    mv -f openssl openssl.old
    ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
    echo "-----------------------------openssl安装完成-------------------------------------"
}
function install_tengine(){
#####安装tengine#####
    echo "-----------------------------安装tengine-----------------------------------------------------------------"
    cd /usr/local
    wget http://mirrors.valarx.com/tengine-2.1.2.tar.gz
    tar zxvf tengine-2.1.2.tar.gz
    cd tengine-2.1.2
    ./configure --prefix=/usr/local/nginx --with-http_stub_status_module  --with-pcre --with-http_upstream_check_module --with-http_spdy_module --dso-path=/usr/local/nginx/dso/module/ --with-http_ssl_module --with-openssl=/usr/local/openssl-1.0.1q
    make && make install
    echo "-----------------------------tengine安装完成-----------------------------------------------------------------"
}
function cleanup(){
    #####删除下载包####
    cd /usr/local
    rm -rf tengine-2.1.2.tar.gz
    rm -rf openssl-1.0.1q.tar.gz
    rm -rf perl-5.24.1.tar.gz
    #rm -rf tengine-2.1.2
    #rm -rf openssl-1.0.1q
    #rm -rf perl-5.24.1
    /usr/bin/find /usr/local -name "*.gz" |/usr/bin/xargs -r /bin/rm -f
    echo "------------下载包清理完成-----------------"
}
function add_firewall(){
######添加防火墙规则###########
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 80 -j ACCEPT
		service iptables save
		service iptables restart
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --add-port=80/tcp --permanent
		firewall-cmd --reload
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw allow 80/tcp

	fi
}
function info(){
    echo "##############Nginx安装完成###############"
    echo "##############当前开放tcp=80端口###############"
    echo "##############tengine：/usr/local/nginx###############"

}

#选择安装方式
echo "------------------------------------------------"
echo "Linux + tengine2.1.2一键安装脚本(beta 1.0 by Sunbalcony)"
echo "1) 安装tengine"
echo "2) 清理安装包"
echo "3) 退出"
read -p ":" num
case $num in
    1) 
    	check_root
        check_system && \
    	install_cpan && \
    	install_openssl && \
    	install_tengine && \
        info && \
	add_firewall 
    ;;
    2) 
    	cleanup
    ;;
    3)
        exit
    ;;
    *) echo '参数错误！'
esac
