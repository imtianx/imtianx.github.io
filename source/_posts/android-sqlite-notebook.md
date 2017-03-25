---
title: android SQLite学习手册
date: 2016-04-23 16:06:25
categories: [android,SQLit]
tags: [android,SQLit]
---
 在实际的应用中，SQLite作为目前最为流行的开源嵌入式关系型数据库，在系统的架构设计中正在扮演着越来越为重要的角色。和很多其它嵌入式NoSQL数据库不同的是，SQLite支持很多关系型数据库的基本特征，这在数据移植、程序演示等应用中有着不可替代的优势。<!--more-->从官方文档中我们可以获悉到，SQLite支持的数据量和运行效率都是非常骄人的，因此在海量数据的解决方案中，SQLite可以作为数据预计算的桥头堡，从而显著减少存储在关系型数据库服务器中的数据数量，最终提高系统的查询效率和运行期效率，同时也可以显著的降低数据备份的磁盘开销
#### SQLite学习手册(开篇)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/09/2317603.html
一、简介
二、SQLite的主要优点
三、和RDBMS相比SQLite的一些劣势
四、个性化特征

#### SQLite学习手册(C/C++接口简介)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/13/2321386.html
一、概述
二、核心对象和接口
三、参数绑定

#### SQLite学习手册(数据表和视图)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/13/2321668.html
一、创建数据表
二、表的修改
三、表的删除
四、创建视图
五、删除视图

#### SQLite学习手册(内置函数)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/13/2322027.html
一、聚合函数
二、核心函数
三、日期和时间函数

#### SQLite学习手册(索引和数据分析/清理)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/14/2322335.html
一、创建索引
二、删除索引
三、重建索引
四、数据分析
五、数据清理

#### SQLite学习手册(数据库和事物)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/14/2322575.html
一、Attach数据库
二、Detach数据库
三、事物

#### SQLite学习手册(表达式)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/16/2323907.html
一、常用表达式
二、条件表达式
三、转换表达式

#### SQLite学习手册(数据类型)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/18/2325258.html
一、存储种类和数据类型
二、类型亲缘性
三、比较表达式
四、操作符

#### SQLite学习手册(命令行工具)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/18/2325981.html

#### SQLite学习手册(在线备份)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/19/2326309.html
一、常用备份
二、在线备份APIs简介
三、高级应用技巧

#### SQLite学习手册(内存数据库)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/20/2328348.html
一、内存数据库
二、临时数据库

#### SQLite学习手册(临时文件)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/21/2328483.html
一、简介
二、具体说明
三、相关的编译时参数和指令
四、其它优化策略

#### SQLite学习手册(锁和并发控制)
http://www.cnblogs.com/stephen-liu74/archive/2012/01/22/2328753.html
一、概述
二、文件锁
三、回滚日志
四、数据写入
五、SQL级别的事物控制

#### SQLite学习手册(实例代码<一>)
http://www.cnblogs.com/stephen-liu74/archive/2012/02/07/2340780.html
一、获取表的Schema信息
二、常规数据插入

#### SQLite学习手册(实例代码<二>)
http://www.cnblogs.com/stephen-liu74/archive/2012/02/07/2341480.html
三、高效的批量数据插入
四、数据查询