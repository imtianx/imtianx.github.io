---
title: OpenGrok 源码阅读环境搭建
date: 2019-05-18 16:06:25
img: http://img.imtianx.cn/2019/opengrok_home.png
categories: [工具软件,源码阅读]
tags: [源码阅读,OpenGrok]
summary: 开发过程中，往往需要阅读源码，挑选一个合适的源码阅读方式十分重要。这里简记使用 [OpenGrok](https://oracle.github.io/opengrok/)搭建源码阅读环境
---


开发过程中，往往需要阅读源码，挑选一个合适的源码阅读方式十分重要。这里简记使用 [OpenGrok](https://oracle.github.io/opengrok/)搭建源码阅读环境。<!--more-->

## 背景
 作为一个 `Android` 开发者，最方便的在线 `AOSP` 源码阅读环境就是 ：[androidxref.com](http://androidxref.com) 。它使用 **[OpenGrok]()** 搭建而成，可以进行快速的检索，如下为 [Pie 9.0.0_r3](http://androidxref.com/9.0.0_r3/) 源码查找页面：
 ![](http://img.imtianx.cn/2019/androidxref_900r3.png)
 除此之外，如下网站也是使用 `OpenGrok` 搭建而成：
 
 1. illumos,Linux - [http://src.illumos.org/source](http://src.illumos.org/source)
 2. libreoffice - [https://opengrok.libreoffice.org](https://opengrok.libreoffice.org)

## 安装
> 由于个人喜欢将此类型的软件部署到 `docker` 中，这里以 `docker` 中安装部署为例说明。

如下具体步骤：
1. 获取镜像,若需其他版本，可[访问此处](https://hub.docker.com/r/opengrok/docker/tags)查看：

 ```
 docker pull opengrok/docker
 ```
1. 设置源码目录;
 
  创建一个存放源码的目录，如 `/home/source`,使用 git clone 所需源码。
  > 注意使用 Git 仓库，手动创建的目录目前无法显示，但是可以进行搜索。
1. 启动 `OpenGrok` ，挂载上述步骤中创建的源码目录，这里为 `/home/source`：
  
  ```
  docker run -d -v /home/source:/opengrok/src  --privileged=true -p 8080:8080 opengrok/docker
  ```
  
  > 注意 **--privileged=true** 参数设置，否则挂载的目录在镜像内无法访问，导致索引失败;
  > **容器内部端口必须是: 8080**
1. 通过浏览器访问：[http://ip:8080]() 进行访问，如下图：

 ![](http://img.imtianx.cn/2019/opengrok_home.png)
 如果访问显示 error, 可能是源码索引未完成，可以稍后访问，或者手动进行索引:
 
 ```
 docker exec <container_id> /scripts/index.sh
 ```
 其中 `container_id` 为上面启动的容器 id 。
 
 > 如果以 `ip:port` 形式访问不方便，可以通过 `nginx` 配置反向代理，设置域名。
 
 具体的代码查找结果如下图,可以访问 [code.imtianx.cn](code.imtianx.cn) 测试:
 ![](http://img.imtianx.cn/2019/opengrok_code.png)
 
## 其他工具

![](http://img.imtianx.cn/2019/other_software_source.png)
对于大部分人而言，使用本地软件比较多，如 `idea`，`sublime`、`Unserstand`/ `source insight`等都可以，其中 **Unserstand** 的体验相对很好。

 
 