yum groupinstall "X Window System"
yum groupinstall "GNOME Desktop"

yum -y install tigervnc-server
vncserver :1
输入密码
开放5901端口


wget https://arya.valarx.com/bag/opera-10.60-6386.x86_64.rpm
sudo rpm -ivh opera-10.60-6386.x86_64.rpm

https://arya.valarx.com/bag/jre-6u27-linux-x64.bin
chmod +x jre-6u27-linux-x64.bin
sudo ./jre-6u27-linux-x64.bin


rm -rf /usr/lib64/mozila/plugins/libnpjp2.so

ln -s /usr/java/jre1.6.0_27/lib64/i386/libnpjp2.so /usr/lib64/mozila/plugins/


通过VNC连接到服务器打开opera 登录esayconnect地址

opera浏览器解禁jre插件
