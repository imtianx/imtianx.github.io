---
title: Git常用命令及团队协作
date: 2017-08-22 16:06:25
categories: [版本控制,Git]
tags: [版本控制,Git]
---


对于版本控制，之前常用的基本都是SVN和CVS之类的，他们都是集中式的版本控制系统，而Git是分布式的。
<!--more-->
## 一、Git 简介
Git 是一款免费、开源的分布式版本控制系统，他是著名的 Linux 发明者 Linus Torvalds 开发的。

所谓的**集中式版本将控制系统**，版本库放在中央服务器上，实际使用的时候充更改电脑上检出最新版，开发后再提交搞服务器上。这个必须的有网，对于局域网还好，公网上的速度较慢。而**分布式版本控制系统**，没有所谓的中央服务器，每个人电脑上都是一个完整的版本，如果自己或者同事修改了，就会推送给对方，这样就可以协作开发了。为了方便所有的人的修改都可以及时交换，通常有一台作为为"中央服务器"，这个更为安全，每个人都是一个完整的仓库。

## 二、Git 常用命令

首先从 Git 官网下载对应系统的版本，安装。然后可使用如下命令在本地使用：

 ![](/img/article_img/2017/git_cmd_teamwork_1.png)

(注：该图片来自网络)

## 三、Git 协作开发

在实际的开发中，使用命令协作过程如下（注： develop为项目的主分支，在各自分支上开发，然后合并到主分支）：

```
cd 项目文件夹/项目名
git add .
git commit -m "本地修改信息"
git push
git pull origin develop
#本地解决冲突

#切换到develop分支，合并自己的代码到develop分支
git checkout develop
git merage develop_自己分支名
git commit 
git push
#将代码提交并push

#切换回自己的分支
git checkout develop_自己分支名
```


如果不习惯使用命令，可以使用 [SourceTree](https://www.sourcetreeapp.com/)——一个可视化的git管理软件，不过安装必须注册，注册需要翻墙。

对于 AS，IDEA等都可以方便的在编辑器中使用使用Git，使用时，注意要commit 和 push 才能提交到远程仓库。如果不方便自己搭建 Gitlab服务，可以使用Github或者码云来为项目使用Git。






















