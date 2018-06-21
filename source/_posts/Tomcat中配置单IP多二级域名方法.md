---
title: Tomcat中配置单IP多二级域名方法
date: 2017-1-11 16:06:25
categories: [后端,域名配置]
tags: [tomcat,域名解析,二级域名]
---

由于一级域名 [imtianx.cn](http://imtianx.cn/) 作为博客主地址了，为了方便使用，通过二级域名来配置网站。这里简介二级域名的配置方式。
<!--more-->
作为学生，为了便宜采用 腾讯云 服务器。在 windows server 2012 服务器上配置网站，使用 toncat。

# 一、设置域名解析

我的域名 imtianx.cn 在阿里的万网购买的。登陆域名管理后台，添加域名解析。这里使用 `A 记录`，它是指向一个 IP 的。为了方便测试，这里有添加如下两条A记录的二级域名解析。

![](http://img.imtianx.cn/domain_jiexi.png)

所对应的是：test2.imtianx.cn 和 test1.imtianx.cn 两个二级域名。

如下是万网的**记录类型**及其说明，**记录值**受他的影响：

1. **A记录**：
将域名指向一个IPv4地址（例如：10.10.10.10），需要增加A记录。
2. **CNAME记录**
如果将域名指向一个域名，实现与被指向域名相同的访问效果，需要增加CNAME记录。
3. **MX记录**
建立电子邮箱服务，将指向邮件服务器地址，需要设置MX记录。
4. **NS记录**
域名解析服务器记录，如果要将子域名指定某个域名服务器来解析，需要设置NS记录。
5. **TXT记录**
可任意填写（可为空），通常用做SPF记录（反垃圾邮件）使用。
6. **AAAA记录**
将主机名（或域名）指向一个IPv6地址（例如：ff03:0:0:0:0:0:0:c1），需要添加AAAA记录。
7. **SRV记录**
记录了哪台计算机提供了哪个服务。格式为：服务的名字.协议的类型（例如：_example-server._tcp）。
8. **显性URL**
将域名指向一个http（s)协议地址，访问域名时，自动跳转至目标地址（例如：将www.net.cn显性转发到www.hichina.com后，访问www.net.cn时，地址栏显示的地址为：www.hichina.com）。
9. **隐性URL**
与显性URL类似，但隐性转发会隐藏真实的目标地址（例如：将www.net.cn隐性转发到www.hichina.com后，访问www.net.cn时，地址栏显示的地址仍然为：www.net.cn）。

对于**主机记录**则是域名的前缀，常见的如下：

- **www** :将域名解析为www.example.com，填写www；
- **@** ：
将域名解析为example.com（不带www），填写@或者不填写；
- **mail** ：
将域名解析为mail.example.com，通常用于解析邮箱服务器；
- **\*** ：
泛解析，所有子域名均被解析到统一地址（除单独设置的子域名解析）；
- **二级域名** ：
如：mail.example.com或abc.example.com，填写mail或abc；
- **手机网站** ：
如：m.example.com，填写m。


# 二、配置tomcat

首先将网站项目导出 war包放入 webapps ，然后修改Tomcat 的配置文件: `conf/server.xml`,在 `Engine`节点下添加host。
如下：

```
<Host name="test1.imtianx.cn" appBase="webapps" unpackWARs="true" autoDeploy="true" xmlValidation="false" xmlNamespaceAware="false">
  <Alias>test1.imtianx.cn</Alias>
  <Context path="" docBase="./Test1" reloadable="false" />
</Host>
<Host name="test2.imtianx.cn" appBase="webapps" unpackWARs="true" autoDeploy="true" xmlValidation="false" xmlNamespaceAware="false">
  <Alias>test2.imtianx.cn</Alias>
  <Context path="" docBase="./Test2" reloadable="false" />
</Host>
```
> 配置说明：
 name ： 指定域名
 appBase : 虚拟目录的路径
 path : 访问时的项目web名
 doBase : 项目的顶级目录
 >

更改Tomcat配置文件后需要将tomcat重启才可生效，然后就可以通过二级域名访问网站了：

![](http://img.imtianx.cn/domain_show.png)

这个只是一种二级域名解析方法，设置完就可以方便的使用二级域名了。

> **本文作者**：[imtianx](http://imtianx.cn/about)
> **本文链接**：http://imtianx.cn/2017/01/11/Tomcat%E4%B8%AD%E9%85%8D%E7%BD%AE%E5%8D%95IP%E5%A4%9A%E4%BA%8C%E7%BA%A7%E5%9F%9F%E5%90%8D%E6%96%B9%E6%B3%95
> **版权申明**:：本站文章均采用 [CC BY-NC-SA 3.0 CN](http://creativecommons.org/licenses/by-nc-sa/3.0/cn/) 许可协议，请勿用于商业，转载请注明出处！

