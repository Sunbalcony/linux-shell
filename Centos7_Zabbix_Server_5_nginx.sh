yum install epel-release -y
yum install openssl* -y
yum install mariadb-server -y
yum install fping OpenIPMI unixODBC libtool-ltdl libevent python3 python3-devel gcc gcc-c++ mariadb mariadb-devel lrzsz -y
systemctl start mariadb
systemctl enable mariadb
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all
yum makecache
# yum install zabbix-server-mysql zabbix-agent
rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/5.0/rhel/7/x86_64/zabbix-server-mysql-5.0.0-1.el7.x86_64.rpm
rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/5.0/rhel/7/x86_64/zabbix-agent-5.0.0-1.el7.x86_64.rpm
yum install centos-release-scl -y
# yum install rh-nginx116-nginx -y
# rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/5.0/rhel/7/x86_64/frontend/zabbix-nginx-conf-scl-5.0.0-1.el7.noarch.rpm
# rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/5.0/rhel/7/x86_64/frontend/zabbix-web-mysql-scl-5.0.0-1.el7.noarch.rpm
vim /etc/yum.repos.d/zabbix.repo and enable zabbix-frontend repository.
```
[zabbix-frontend]

enabled=1

```
yum install zabbix-web-mysql-scl zabbix-nginx-conf-scl -y

 mysql -uroot -p 

 create database zabbix character set utf8 collate utf8_bin; 
 //创建zabbix数据库
 grant all privileges on zabbix.* to zabbix@'%' identified by 'zabbix';
//授权所有主机访问数据库实例zabbix，用户名/密码：zabbix/zabbix
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';   
//授权localhost主机名访问数据库实例zabbix，用户名/密码：zabbix/zabbix
quit
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
sed -i 's/# DBPassword=zabbix/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf
vim /etc/zabbix/zabbix_server.conf
 ```
 DBPassword=zabbix
 ```
vim /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf
```
# listen 80;
# server_name example.com;
```
vim /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
```
listen.acl_users = nginx
; php_value[date.timezone] = Europe/Riga(Asia/shanghai) #修改为自己的去掉注释
```

systemctl restart zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm


此处用nginx需要解析域名
http://域名+端口   访问
