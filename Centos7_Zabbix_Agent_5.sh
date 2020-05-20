#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
function check_root(){
	[[ $EUID != 0 ]] && echo -e "当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用 sudo -i来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
function check_env(){
    sudo yum -y install epel-release
    sudo yum -y install wget pcre-devel openssl openssl-devel gcc gcc-c++ tcl make vim lrzsz net-tools
}
function install_agent(){
    rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/5.0/rhel/7/x86_64/zabbix-agent-5.0.0-1.el7.x86_64.rpm
    systemctl enable zabbix-agent
    echo "Zabbix-Agent已加入开机启动"
    read -p "请输入ZBX Server地址：" ZBXS
    while [ -z "${ZBXS}" ]
    do
        read -p "请输入ZBX Server地址：" ZBXS
    done
    #sed -i "97c\Server=${ZBXS}" /etc/zabbix/zabbix_agentd.conf
    #sed -i "138c\ServerActive=${ZBXS}" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/Server=127.0.0.1/Server=${ZBXS}/g" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZBXS}/g" /etc/zabbix/zabbix_agentd.conf
    
    read -p "请输入Agent Hostname：" ZBXC
    while [ -z "${ZBXC}" ]
    do
        read -p "请输入Agent Hostname：" ZBXC
    done
    sed -i "149c\Hostname=${ZBXC}" /etc/zabbix/zabbix_agentd.conf
}
check_process(){
    echo "正在启动Zabbix-Agent"
    systemctl start zabbix-agent
    sleep 8
    ZBXP=$(netstat -ntlp |grep tcp |grep -v tcp6| grep 10050|awk '{print $4}'|awk -F : '{print $2}')
    if [[ ${ZBXP} == 10050 ]]
    then
            echo -e "zabbix-agent启动成功"
    else
            echo -e "zabbix-agent启动失败，请检查"
    fi
}
echo "Centos7 Zabbix-Agent 一键安装脚本 by Sunbalcony"
echo "1) 安装Zabbix-Agent"
echo "2) 重启Zabbix-Agent"
read -p "请输入选项：" emmm
case $emmm in
        1)
            check_env
            check_env && \
            install_agent && \
            check_process
	;;
        2)
            systemctl restart zabbix-agent
            echo "Zabbix-Agent重启完成"
	;;
	*)  echo -e "输入错误"
esac
