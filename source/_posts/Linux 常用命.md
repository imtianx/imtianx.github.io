---
title: Linux 常用命令
date: 2017-03-18 16:06:25
categories: [后端,linux]
tags: [服务器,linux,vim]
---

之前，服务器 一直都是 window server 系统，主要是桌面的，方便操作，但是同样的配置 ，Centos要比他好很多，就把服务器换成了 `Centos 7` ，开始学习使用 linux，并在简短记下。
<!--more-->

### 1 常用命令
```
ls　　          显示文件或目录

     -l         列出文件详细信息l(list)

     -a         列出当前目录下所有文件及目录，包括隐藏的a(all)

mkdir           创建目录

     -p         创建目录，若无父目录，则创建p(parent)

cd              切换目录

touch           创建空文件

echo            创建带有内容的文件。

cat             查看文件内容

cp              拷贝

mv              移动或重命名

rm              删除文件

     -r         递归删除，可删除子目录及文件

     -f         强制删除

find            在文件系统中搜索某文件

wc              统计文本中行数、字数、字符数

grep            在文本文件中查找某个字符串

rmdir           删除空目录

tree            树形结构显示目录，需要安装tree包

pwd             显示当前目录

ln              创建链接文件

more、less      分页显示文本文件内容

head、tail      显示文件头、尾内容

ctrl+alt+F1     命令行全屏模式
```

### 2 系统管理命令

```
stat           显示指定文件的详细信息，比ls更详细

who            显示在线登陆用户

whoami         显示当前操作用户

hostname       显示主机名

uname          显示系统信息

top            动态显示当前耗费资源最多进程信息

ps             显示瞬间进程状态 ps -aux

du             查看目录大小 du -h /home带有单位显示目录信息

df             查看磁盘大小 df -h 带有单位显示磁盘信息

ifconfig       查看网络情况

ping           测试网络连通

netstat        显示网络状态信息

man            命令不会用了，找男人  如：man ls

clear          清屏

alias          对命令重命名 如：alias showmeit="ps -aux" ，另外解除使用unaliax showmeit

kill           杀死进程，可以先用ps 或 top命令查看进程的id，然后再用kill命令杀死进程。

reboot         重启
```
这里仅仅是记录了一些常用的，对于不熟悉的 命令可以 使用 `man` 来查看。

### 3 vim 使用

**vim**三种模式：命令模式、插入模式、编辑模式。使用**ESC**或**i**或：来切换模式。

**命令模式**下：
```
:q             退出

:q!            强制退出

:wq            保存并退出

:set number    显示行号

:set nonumber  隐藏行号

/apache        在文档中查找apache 按n跳到下一个，shift+n上一个

yyp            复制光标所在行，并粘贴

h(左移一个字符←)、j(下一行↓)、k(上一行↑)、l(右移一个字符→)
```






