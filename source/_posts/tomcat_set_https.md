---
title: Tomcat 配置https证书
date: 2017-09-22 16:06:25
categories: [后端,linux]
tags: [tomcat,https,linux]
---

HTTPS 是安全套接字层超文本传输协议，在http 的基础上加入了 SSL协议，需要使用证书来校验身份。<!--more--> HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络协议，比http协议安全。其默认端口为：443。越来越多的网站使用了https，这里简介其相关配置。

### 一、使用jdk创建证书

这里在安装有 `JDK` 环境的情况下进行，利用 `keytool` 工具生成 tomcat 证书，可使用 `--help` 命令查看相关残数据说明：，具体如下：

     C:\Users\admin_tx>keytool --help
    密钥和证书管理工具
    
    命令:
    
     -certreq            生成证书请求
     -changealias        更改条目的别名
     -delete             删除条目
     -exportcert         导出证书
     -genkeypair         生成密钥对
     -genseckey          生成密钥
     -gencert            根据证书请求生成证书
     -importcert         导入证书或证书链
     -importpass         导入口令
     -importkeystore     从其他密钥库导入一个或所有条目
     -keypasswd          更改条目的密钥口令
     -list               列出密钥库中的条目
     -printcert          打印证书内容
     -printcertreq       打印证书请求的内容
     -printcrl           打印 CRL 文件的内容
     -storepasswd        更改密钥库的存储口令
    
    使用 "keytool -command_name -help" 获取 command_name 的用法
     
    
     C:\Users\admin_tx>keytool -genkeypair --help
    keytool -genkeypair [OPTION]...
    
    生成密钥对
    
    选项:
    
     -alias <alias>                  要处理的条目的别名
     -keyalg <keyalg>                密钥算法名称
     -keysize <keysize>              密钥位大小
     -sigalg <sigalg>                签名算法名称
     -destalias <destalias>          目标别名
     -dname <dname>                  唯一判别名
     -startdate <startdate>          证书有效期开始日期/时间
     -ext <value>                    X.509 扩展
     -validity <valDays>             有效天数
     -keypass <arg>                  密钥口令
     -keystore <keystore>            密钥库名称
     -storepass <arg>                密钥库口令
     -storetype <storetype>          密钥库类型
     -providername <providername>    提供方名称
     -providerclass <providerclass>  提供方类名
     -providerarg <arg>              提供方参数
     -providerpath <pathlist>        提供方类路径
     -v                              详细输出
     -protected                      通过受保护的机制的口令
    
    使用 "keytool -help" 获取所有可用命令


 这里使用如下命令生成证书：

```
keytool -genkeypair -alias "tomcat" -keyalg "RSA" -keystore "E:\tomcat.keystore"  
```
>*参数说明*：
 -genkeypair  表示生成密钥对，
 -alias  表示别名
 -keyalg 表示密钥算法名称
 -keystore 表示密钥保存的名称
 
 然后安装提示输入，但需要注意的是 <span  style="color:red;"><strong>名字与姓氏 那个是填写域名的。</strong></span> 此外，尽量前后密码一致，避免后面出现密码错误的问题。
 
 如下图：
 
 ![](/img/article_img/2017/tomcat_set_https_1.png)
 
 这里随便写了个域名，是一个不存在的二级域名，为了能够访问，需要在 `C:\Windows\System32\drivers\etc` 路径下的 `hosts` 文件添加：
  
```
127.0.0.1     test.imtianx.cn 
```
 
### 二、tomcat 配置 https 证书

通过上面的步骤，生成了密钥，修改tomcat配置文件：`/conf/server.xml`, 添加如下设置：

```
 <Connector port="443" protocol="org.apache.coyote.http11.Http11Protocol"
               maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
               clientAuth="false" sslProtocol="TLS"
               keystoreFile="D:\keystore\tomcat.keystore"  
       		   keystorePass="imtianx" />
```
其中，`keystoreFile` 指明密钥位置，`keystorePass` 指明密钥密码。
在该配置文件中有 https的 Connector 配置，被注释掉了。**https 默认端口为 443**。

然后启动tomcat,即可在浏览器中输入：https://test.imtianx.cn/ 访问，由于是自己生成的，浏览器会提示不安全，在高级中选择 继续访问即可，如下：

![](/img/article_img/2017/tomcat_set_https_2.png)


### 三、域名绑定 第三方https证书

上面介绍了自己生成密钥配置https的方法，只适合本地测试，对于真实的域名无法使用。这里，选择第三方 https 证书提供商，在真实的环境中使用。

这里选择 阿里云 的 [云盾证书服务](https://common-buy.aliyun.com/?spm=5176.2020520163.cas.1.22f653b7qIs2De&commodityCode=cas#/buy) ,在其官网购买免费版——证书类型为 ：免费型DV SSL，然后根据要求补全信息。待审核通过后在控制台下载对应环境的证书，这里提前申请了 `mvvm.tech` 这个域名。 由于个人习惯使用tomcat作为web服务器，下载 tomcat 的证书，包含如下内容：

- 证书文件：214248632560457.pem
- 证书私钥文件：214248632560457.key
- PFX格式证书文件：214248632560457.pfx
- PFX格式证书密码文件：pfx-password.txt
 
这里采用的是tomcat8.0，支持pfx格式的证书，无需格式转换。
将上述文件全部放到 tomcat 目录下的 `cert` 中，然后按照步骤二中的方式配置，其中 **keystoreFilep指定为 cert 中 pfx 格式证书路径及名称，keystorePass 为 pfx-password.txt 中的密码。**

```
keystoreFile="/home/apache-tomcat-8.0.46/cert/214248632560457.pfx"  
 keystorePass="214248632560457"
```

这里为了简单，建立个空项目，并将其导出 war ,放入 `womcat/webapps` 中,修改 `/conf/server.xml`,在 `host` 节点下添加如下映射文件：

```
<Host name="mvvm.tech" appBase="webapps" unpackWARs="true"
      autoDeploy="true" xmlValidation="false"  xmlNamespaceAware="false">
  	<Alias>mvvm.tech</Alias>
  	<Context path="" docBase="./TestHttps" reloadable="false" />
</Host>
```
此外，需要在域名管理的后台添加与域名解析： 类型为 A 记录，值为 服务器 ip.

然后，开放 443端口，重启tomcat,在浏览器中输入：https://mvvm.tech 即可访问。如下图:

![](/img/article_img/2017/tomcat_set_https_3.png)

这里是在 CentOS中配置的，对于web环境配置不了解的，可[点击此处](http://imtianx.cn/2017/03/25/Centos%207%20web%20%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA/)查看。

如果在浏览器输入 mvvm.tech， 依然可以访问，以http的形式，可修改tomcat配置将其转发到 https 。
这里 对 https 使用 其默认的 443端口，对80及8009的端口 转发到 443,修改 redirectPort 参数，如下：

```
 <Connector port="80" protocol="HTTP/1.1" connectionTimeout="20000"  redirectPort="443" />
 
 <Connector port="8009" protocol="AJP/1.3" redirectPort="443" />

```

此外，需要对 web.xml进行修改，末尾添加如下内容：

```
<security-constraint> 
   <web-resource-collection > 
          <web-resource-name >SSL</web-resource-name> 
          <url-pattern>/*</url-pattern> 
   </web-resource-collection>
                         
   <user-data-constraint> 
          <transport-guarantee>CONFIDENTIAL</transport-guarantee> 
   </user-data-constraint> 
</security-constraint>

```

然后重启tomcat即可。至此，https 配置结束。

> **本文作者**：[imtianx](http://imtianx.cn/about)
> **本文链接**：http://imtianx.cn/2017/09/22/tomcat_set_https
> **版权申明**:：本站文章均采用 [CC BY-NC-SA 3.0 CN](http://creativecommons.org/licenses/by-nc-sa/3.0/cn/) 许可协议，请勿用于商业，转载请注明出处！

















