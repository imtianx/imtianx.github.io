---
title: PLSQL安装、连接服务器及字符编码更改
date: 2016-04-23 16:16:25
categories: [工具软件,PL/SQL]
tags: [oracle,PL/SQL]
---
在学习时用oracle时，使用PLSQL客户端来操作数据库，这里简单介绍了它安装相关问题。<!--more-->
### 一、下载PLSQL并破解
（看不惯英文的可以安装汉化文件）,下载地址：[PLSQL+instantclient](http://download.csdn.net/detail/txadf/9259051)
### 二、解压开始安装，
如下图介绍；并将instantclient放到自己安装的文件位置，便于之后使用。

![](http://img.blog.csdn.net/20151110212717528?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
### 三、破解软件
填写instantclient文件的位置； 
   （1）、安装完成后运行PLSQL，在弹出的登陆界面直接点击取消，进入；
   （2）、帮助--->注册，运行破解文件，将产品编号、序列和口令（密码）对应的填入；
   （3）、工具--->首选项，如下图，在‘1’处填      入：D:\software_Study\oracle\instantclient_11_2\network\admin；在‘2’处填入：D:\software_Study\oracle\instantclient_11_2\oci.dll
注：如果连接的是服务器端的oracle，需要将‘1’文件夹下的'tnsnames.ora',用记事本打开，更改第二行的host的值为服务器的ip地址。

### 四、配置环境变量（可选操作）
完成上述步骤后，退出登陆，这里使用在服务器端创建的用户名和密码，数据库选择‘XE’，连接为‘Normal’，便可登陆。
如果需要更改字符编码，需配置环境变量，
查看服务器编码：select userenv('language') from dual;
查看PLSQL客户端编码：select * from V$NLS_PARAMETERS; 看NLS_LANGUAGE值与上一语句值是否相等；
我们服务器编码是utf-8，这里不匹配，添加如下环境变量：

变量名：NLS_LANG
值：AMERICAN_AMERICA.AL32UTF8

