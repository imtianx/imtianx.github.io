---
title: 收集的Android开源框架及其地址
date: 2016-04-23 16:01:25
categories: [android,学习笔记]
tags: [android,开源框架]
---
### 1、volley 
项目地址 https://github.com/smanikandan14/Volley-demo
JSON，图像等的异步下载；
网络请求的排序（scheduling）
网络请求的优先级处理
缓存
多级别取消请求和Activity和生命周期的联动（Activity结束时同时取消所有网络请求）
<!--more-->
### 2、android-async-http

项目地址：https://github.com/loopj/android-async-http，文档介绍：http://loopj.com/android-async-http/ 

在匿名回调中处理请求结果
在UI线程外进行http请求
文件断点上传
智能重试
默认gzip压缩
支持解析成Json格式
可将Cookies持久化到SharedPreferences
### 3、Afinal框架

项目地址：https://github.com/yangfuhai/afinal

主要有四大模块：

数据库模块：Android中的orm框架，使用了线程池对sqlite进行操作。
注解模块：Android中的ioc框架，完全注解方式就可以进行UI绑定和事件绑定。无需findViewById和setClickListener等。
网络模块：通过httpclient进行封装http数据请求，支持Ajax方式加载，支持下载、上传文件功能。
图片缓存模块：通过FinalBitmap，imageview加载bitmap的时候无需考虑bitmap加载过程中出现的oom和Android容器快速滑动时候出现的图片错位等现象。
　　FinalBitmap可以配置线程加载线程数量，缓存大小，缓存路径，加载显示动画等。FinalBitmap的内存管理使用lru算法，没有使用弱引用（Android2.3以后Google已经不建议使用弱引用，Android2.3后强行回收软引用和弱引用，详情查看Android官方文档），更好的管理bitmap内存。FinalBitmap可以自定义下载器，用来扩展其他协议显示网络图片，比如ftp等。同时可以自定义bitmap显示器，

　　在imageview显示图片的时候播放动画等（默认是渐变动画显示）。

### 4、xUtils框架

项目地址：https://github.com/wyouflf/xUtils，主要有四大模块：
**数据库模块：**
Android 中的 orm 框架，一行代码就可以进行增删改查；
支持事务，默认关闭；
可通过注解自定义表名，列名，外键，唯一性约束，NOT NULL约束，CHECK约束等（需要混淆的时候请注解表名和列名）；
支持绑定外键，保存实体时外键关联实体自动保存或更新；
自动加载外键关联实体，支持延时加载；
支持链式表达查询，更直观的查询语义，参考下面的介绍或sample中的例子。          
**注解模块：**

Android中的 ioc 框架，完全注解方式就可以进行 UI，资源和事件绑定；
新的事件绑定方式，使用混淆工具混淆后仍可正常工作；
目前支持常用的20种事件绑定，参见 View Common Event Listener 类和包com.lidroid.xutils.view.annotation.event。
**网络模块：**

支持同步，异步方式的请求；
支持大文件上传，上传大文件不会oom；
支持GET，POST，PUT，MOVE，COPY，DELETE，HEAD，OPTIONS，TRACE，CONNECT请求；
下载支持301/302重定向，支持设置是否根据Content-Disposition重命名下载的文件；
返回文本内容的请求（默认只启用了GET请求）支持缓存，可设置默认过期时间和针对当前请求的过期时间。
**图片缓存模块：**

加载bitmap的时候无需考虑bitmap加载过程中出现的oom和Android容器快速滑动时候出现的图片错位等现象；
支持加载网络图片和本地图片；
内存管理使用lru算法，更好的管理bitmap内存；
可配置线程加载线程数量，缓存大小，缓存路径，加载显示动画等。
### 5、ThinkAndroid

项目地址：https://github.com/white-cat/ThinkAndroid

主要有以下模块：

**MVC模块：**实现视图与模型的分离。
**ioc模块：** Android中的ioc模块，完全注解方式就可以进行UI绑定、res中的资源的读取、以及对象的初始化。 
**数据库模块：** Android中的orm框架，使用了线程池对sqlite进行操作。  
**http模块：** 通过httpclient进行封装http数据请求，支持异步及同步方式加载。
**缓存模块：** 通过简单的配置及设计可以很好的实现缓存，对缓存可以随意的配置
**图片缓存模块：** i mageview加载图片的时候无需考虑图片加载过程中出现的oom和Android容器快速滑动时候出现的图片错位等现象。
**配置器模块：** 可以对简易的实现配对配置的操作，目前配置文件可以支持Preference、Properties对配置进行存取。
**日志打印模块**：可以较快的轻易的是实现日志打印，支持日志打印的扩展，目前支持对sdcard写入本地打印、以及控制台打印
**下载器模块**：可以简单的实现多线程下载、后台下载、断点续传、对下载进行控制、如开始、暂停、删除等等。
**网络状态检测模块**：当网络状态改变时，对其进行检。
### 6、LoonAndroid

项目地址：https://github.com/gdpancheng/LoonAndroid

主要有以下模块：
自动注入框架（只需要继承框架内的APP既可）
图片加载框架（多重缓存，自动回收，最大限度保证内存的安全性）
网络请求模块（继承了基本上现在所有的http请求）
eventbus（集成一个开源的框架）
验证框架（集成开源框架）
Json解析（支持解析成集合或者对象）
数据库（不知道是哪位写的 忘记了）
多线程断点下载（自动判断是否支持多线程，判断是否是重定向）
自动更新模块
一系列工具类

### 7、图片加载：
 Universal Image Loader - https://github.com/onlyTan/Android-Universal-Image-Loader

用法参考 -http://blog.csdn.net/xiaanming/article/details/26810303


### 8、动画框架：
  nineoldandroids -  https://github.com/JakeWharton/NineOldAndroids
用法参考 -http://blog.csdn.net/lmj623565791/article/details/38067475


### 9、进程间通信框架：
   eventBus -  https://github.com/greenrobot/EventBus
用法参考 - http://blog.csdn.net/lmj623565791/article/details/40794879


### 10、SQLite数据库：
LitePal - 

https://github.com/LitePalFramework/LitePal



### 11、百分比布局：
android-percent-support-extend  -  

https://github.com/hongyangAndroid/android-percent-support-extend

百分比布局：
android-percent-support-extend  -  

https://github.com/hongyangAndroid/android-percent-support-extend