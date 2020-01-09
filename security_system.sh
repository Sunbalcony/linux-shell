#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
function check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无法继续操作，请使用 sudo -i来获取临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}
function check_user(){
    read -p "请输入已经添加的用户名:" UUU
    qwe=$(cat /etc/passwd |grep ${UUU} |awk -F ":" '{print$1}')
    if [[ ${qwe} = ${UUU} ]]
    then
        echo "当前系统存在该用户，OK!"
    else
        echo -e "当前系统不存在该用户，退出。"
        exit 1
    fi
}
function pass_max_days(){
    read -p "请输入密码最大可用天数：" Q
    sed -i '/^PASS_MAX_DAYS/c\PASS_MAX_DAYS   '${Q}'' /etc/login.defs
    echo "密码最大可用天数已设置为'${Q}'天"
    #通配^因该字符在该文件只存在一处
    sleep 1
}
function pass_min_days(){
    read -p "请输入密码修改最小的天数：" W
    sed -i '/^PASS_MIN_DAYS/c\PASS_MIN_DAYS   '${W}'' /etc/login.defs
    echo "密码修改最小天数已设置为'${W}'天"
    sleep 1
}
function pass_min_len(){
    read -p "请输入密码最小长度：" E
    sed -i '/^PASS_MIN_LEN/c\PASS_MIN_LEN   '${E}'' /etc/login.defs
    echo "密码最小长度已设置为'${E}'天"
    sleep 1
}
function pass_warn_age(){
    read -p "请输入密码失效前多少天前进行通知：" R
    sed -i '/^PASS_WARN_AGE/c\PASS_WARN_AGE   '${R}'' /etc/login.defs
    echo "密码将在失效'${R}'天前通知"
    sleep 1
}
function history_command(){
    read -p "请输入历史命令保留条数：" T
    sed -i '/^HISTSIZE/c\HISTSIZE='${T}'' /etc/profile
    echo "历史命令保留'${T}'天"
    sleep 1
}
function auto_logout(){
    read -p "请输入账户自动注销时间(s)：" U
    sed -i '/^HISTSIZE/a\TMOUT='${U}'' /etc/profile
    echo "账户自动注销时间'${U}'秒"
    sleep 1
}
function login_lock(){
    n=$(cat /etc/pam.d/sshd | grep "auth required pam_tally2.so "|wc -l)
    if [[ ${n} == 0 ]]
    then
        echo "设置登录锁定，用户失败登录三次，锁定5分钟"
        sed -i '/%PAM-1.0/a\auth required pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=300' /etc/pam.d/sshd
        #添加auth required pam_tally2.so来做登录错误锁定
        #/a\ 在%PAM-1.0行后追加一行
        sleep 1
    else
        echo "auth required pam_tally2.so 已经设定过"
    fi
}
function root_login(){
    echo  "设置禁止root用户远程登录！！"
    sed -i '/PermitRootLogin/c\PermitRootLogin no'  /etc/ssh/sshd_config
    systemctl restart sshd
    sleep 1
}
echo -e "Centos7安全加固脚本"
echo -e "-----------------------------------"
echo -e "警告：请先添加其他用户，并给予适当权限"
echo -e "警告：请先添加其他用户，并给予适当权限"
echo -e "警告：请先添加其他用户，并给予适当权限"
echo -e "-----------------------------------"
echo -e "脚本包含功能有:"
echo -e "！禁止ROOT账户远程登录！"
echo -e "密码过期时间"
echo -e "密码修改最小时间"
echo -e "密码最小长度"
echo -e "密码过期前通知"
echo -e "历史命令保留条数"
echo -e "账户自动注销"
echo -e "1) 进行安全加固设置"
echo -e "2) 退出"
read -p "请输入选项:" emmm
case $emmm in
        1)
            check_root
            check_user && \
            pass_max_days && \
            pass_min_days && \
            pass_min_len && \
            pass_warn_age && \
            history_command && \
            auto_logout && \
            login_lock && \
            root_login
        ;;
        2)
            exit
        ;;
        *)
            echo -e "输入错误"
esac

