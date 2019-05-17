---
title: Centos 7 web 环境搭建
date: 2017-03-25 16:06:25
categories: [后端,linux]
tags: [服务器,linux,web]
---
方便配置网站和使用数据库，将服务器配置 web 运行环境。

### 1、Xshell 5
为了方便管理操作服务器，这里采用 `xshell 5` 来连接服务器，使用ssh证书，端口号 22，对于购买的与主机需要开放相应的端口。<!--more-->
如下是连接成功的提示：

```
[c:\~]$ open
Connecting to 115.159.200.102:22...
Connection established.
To escape to local shell, press 'Ctrl+Alt+]'.
Last login: Sat Mar 10 18:37:31 2017 from 115.195.220.207
[root@imtianx ~]# 
```
其中 `[root@imtianx ~] `一句，rooot为登陆账号，`imtianx` 为主机名。
默认主机名一般很长，可以进行修改：

```
# 设置主机名为name
hostnamectl set-hostname name   

# 查看是否设置成功
hostnamectl status  

# 重启 
reboot 
```
重启后提示符才会变。

### 2、JDK
安装jdk，这里采用 `rpm` 方式安装，

```
# 下载jdk
curl -O http://download.oracle.com/otn-pub/java/jdk/8u121-b13/jdk-8u121-linux-x64.rpm

# 使用 rpm 安装
rpm -ivh jdk-8u121-linux-x64.rpm
```
然后 可以使用 `java -version` 、`javac` 查看是否安装成功。由于 rpm 的安装方式会把jdk安装到 `/usr/java/jdk1.8.0_121`下，通过三层；链接到 /usr/bin下，环境变量可以不用配置。
环境变量配置方法：

```
vim /etc/profile   //打开 profile 
```
添加下面的配置信息:
```
#set java environment
JAVA_HOME=/usr/java/jdk1.8.0_121
JRE_HOME=$JAVA_HOME/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH
```
若需要立即生效，可执行如下命令：
```
source /etc/profile
```
### 3、Tomcat

```
# 下载 Tomcat
wget  http://download.nextag.com/apache/tomcat/tomcat-8/v8.5.12/bin/apache-tomcat-8.5.12.zip

# 解压,可使用 rm 移动位子
unzip apache-tomcat-8.5.12.zip

# tomcat/bin下执行，授予 .sh 文件执行权限
chomd +x *.sh

# 启动服务，若无法启动 请看后文 使用 systemctl 命令
startup.sh
```
由于防火墙的限制，需要开放相应的端口，这里选择 `iptables` 防火墙。

```
# 安装
yum install iptables-services

#配置防火墙
vim /etc/sysconfig/iptables

# 在 22端口号线面添加 如下端口，然后保存并退出 （：wq）
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT

#重启防火墙
systemctl restart iptables.service

#查看 开放端口
iptables -L -n
```

> 注：这里必须要在 22端口号下面添加，不能添加到最后，为方便将tomcat端口配置为80，mysql 数据库端口为 3306，这里一并开放。

设置Tomcat 为服务，开机自启。
首先在 `/usr/lib/systemd/system/ ` 目录下添加 `tomcat.service` 文件，内容如下：

```
[unit]
Description=Tomcat
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/home/tomcat/tomcat.pid
ExecStart=/home/tomcat/bin/startup.sh
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target

```

然后在 `tomcat/bin/` 下添加 `setenv.ssh`文件，设置pid 及 java内存（可忽略）内容如下：

````
#add tomcat pid
CATALINA_PID="$CATALINA_BASE/tomcat.pid"
#add java opts
JAVA_OPTS="-server -XX:PermSize=256M -XX:MaxPermSize=1024m -Xms512M -Xmx1024M -XX:MaxNewSize=    256m"

```

最后使用 `systemctl` 相关命令，设置服务，如下：

```
# 启动服务，stop停止
systemctl start tomcat
# 查看服务状态
systemctl status name
# 设置开机自启，disable删除
systemctl enable tomcat
# 重启服务
systemctl restart tomcat
```

### 4、Mysql（Mariadb）

这里选择了较为轻量级的 Mariadb 安装，与mysql类似。具体安装命令如下：

```
# 安装
yum -y install mariadb mariadb-server

# 启动
systemctl start mariadb

# 设置开机启动
systemctl enable mariadb

# 接着是对数据库的配置信息
# ...
# 最后授予 权限
grant all privileges on *.* to root@'%' identified by 'password';
```
对于设置编码之类的，更多 Mariadb 的安装配置，请 [点击此处查看](http://www.linuxidc.com/Linux/2016-03/128880.htm)

此外，往往需要文件的上传下载，这里选择 `lrzsz`

```
# 安装
yum install lrzsz
# 上传
rz
# 下载
sz
```








