---
title: AS3.2 和 androidx 爬坑
date: 2018-06-04 22:06:25
categories: [android,学习笔记]
tags: [android,androidx,kotlin]
---


## 一、背景
前不久的 `Googel IO` 大会上亮相的 [JetPack](https://developer.android.com/jetpack/) ,他为android 开发带来了极大地便利，于是开启了尝（爬）鲜（坑）之旅。<!--more-->
自从接手了一个 `MVVM` 架构的项目，就喜欢上了这种模式的开发，使用 `Kotlin` 开发，里面用到了 [Databinding](https://developer.android.com/topic/libraries/data-binding/)，[LiveData](https://developer.android.com/topic/libraries/architecture/livedata)、[Lifecycler](https://developer.android.com/topic/libraries/architecture/lifecycle) 和 [viewmodel](https://developer.android.com/topic/libraries/architecture/viewmodel) 等架构组件，代码简洁，流程清晰，整个开发是十分愉快的，慢慢的习惯了用这些东西。
这些组件都是吸引人的，如果还没有了解的可以上手试试。


## 二、Jetpack 简介

> 官网介绍：Jetpack 是一套库、工具和架构指南，可以帮助我们快速轻松的构建优秀的Android应用，它提供了公共基础代码，因此我们可以专注于让自己应用独一无二的东西。

主要有三个有点：

- **加速开发**
 组件可以单独使用或者组合是使用，同时利用 Kotlin 语言功能，可以使开发效率更高。
- **消除样板代码**
 Android Jetpack管理诸如后台任务，导航和生命周期管理等繁琐的活动，因此您可以专注于什么使您的应用更棒
- **构建搞质量健全的应用**
 以现代设计实践为基础，Android Jetpack组件可降低崩溃次数并减少内存泄漏，并向后兼容

其中包含组件如下图所示：

![](http://img.imtianx.cn/2018/0602/0001.png?imageView2/0/q/75|watermark/2/text/aHR0cDovL2ltdGlhbnguY24v/font/5b6u6L2v6ZuF6buR/fontsize/1200/fill/I0Y4MEIwQg==/dissolve/100/gravity/SouthEast/dx/20/dy/20)

以下是官方博客中的图，更加直白：

![](http://img.imtianx.cn/2018/0602/003.png)



以上内容来自 Google [官方jetpack文档](https://developer.android.com/jetpack/)，更多 jetpack 使用及介绍相关内容请参考官方文档。

## 三、AS 3.2 爬坑

### 3.1 转换过项目为 androidx

将项目转换成了 `androidx` 的，具体转换步骤如下：

 - 将项目编译的sdk 版本调成 `android-P`
 - 从AS 菜单栏选择 `Refactor` -> `Refactor to AndroidX ..`
 
如下为转换前gradle文件：

![](http://img.imtianx.cn/2018/0602/004.png?imageView2/0/q/75|watermark/2/text/aHR0cDovL2ltdGlhbnguY24v/font/5b6u6L2v6ZuF6buR/fontsize/1200/fill/I0Y4MEIwQg==/dissolve/100/gravity/SouthEast/dx/20/dy/20)

如下为转换后gradle文件：

![](http://img.imtianx.cn/2018/0602/005.png?imageView2/0/q/75|watermark/2/text/aHR0cDovL2ltdGlhbnguY24v/font/5b6u6L2v6ZuF6buR/fontsize/1200/fill/I0Y4MEIwQg==/dissolve/100/gravity/SouthEast/dx/20/dy/20)

官方博客介绍：[Hello World, AndroidX](https://android-developers.googleblog.com/2018/05/hello-world-androidx.html)

更多转换库依赖可参考 [Google maven repo](https://dl.google.com/dl/android/maven2/index.html)

### 3.2 databinding + kotlin 
习惯使用 kotlin 开发，配合 databinding 进行数据绑定，但是两者生成的 `BR`会冲突，解决办法是 使用 `kapt` 依赖 databinding, 如果 项目的是这样的：

```
dependencies {
        classpath 'com.android.tools.build:gradle:3.1.1'
}
```

那么 model 中的依赖应该是下面的：

```
// ...
apply plugin: "kotlin-kapt"

android {
   // ...
   databinding {
       enabled = true
   }
   kapt {
       generateStubs = true
   }
}

dependencies {
    // ...
    kapt "com.android.databinding:compiler:3.1.1"
}

```

$\color{red}{注意： 两者依赖的版本要一致，否者编译时就会抛出异常}$

然后我的 金丝雀 中 使用的 `android plugin version ` 是 `3.2.0-alpha16`,但是 ` databinding compile ` 的版本却没有与之对应的，导致无法依赖使用，折腾了很久没有解决就只好将其移除，放弃使用。还天真的以为是 AS 的 bug ，然后傻傻的去 [Issue Tracker ](https://issuetracker.google.com/issues) 给 Google 提了个 bug 。

最近在 看官方文档时，发现了 $\color{red}{androidx}$,而且在访问 [Google maven repo](https://dl.google.com/dl/android/maven2/index.html) 时 也看到了很多 `androidx` 的身影，如下图：

![](http://img.imtianx.cn/2018/0602/002.png?imageView2/0/q/75|watermark/2/text/aHR0cDovL2ltdGlhbnguY24v/font/5b6u6L2v6ZuF6buR/fontsize/1200/fill/I0Y4MEIwQg==/dissolve/100/gravity/SouthEast/dx/20/dy/20)

### 3.3 navigation 使用

由于上面将项目转换成 `androidx` ,而使用 `navigation` 时，需要在xml 中使用 `fragment` 标签，但在运行时会抛出找不到 ` android.support.v4.app.Fragment`的问题，

在 [stackoverflow](https://stackoverflow.com/search?q=androidx) 上有类似的问题，在 google 的 issuetracker 上有相关bug的反馈，[点击查看](https://issuetracker.google.com/issues/79667498)，官方回复下个版本修复，如下图：

![](http://img.imtianx.cn/2018/0602/006.png?imageView2/0/q/75|watermark/2/text/aHR0cDovL2ltdGlhbnguY24v/font/5b6u6L2v6ZuF6buR/fontsize/1200/fill/I0Y4MEIwQg==/dissolve/100/gravity/SouthEast/dx/20/dy/20)

$\color{red}{所以： 玩 navigation 的不要用 androidx,或者等下个版本修复}$


上述项目地址：[https://github.com/imtianx/JetpackLearning](https://github.com/imtianx/JetpackLearning)

这里简记最近体验AS3.2经历的坑！



> **本文作者**：[imtianx](http://imtianx.cn/about)
> **本文链接**：http://imtianx.cn/2018/06/04/as3_2_pre_androix_bug
> **版权申明**:：本站文章均采用 [CC BY-NC-SA 3.0 CN](http://creativecommons.org/licenses/by-nc-sa/3.0/cn/) 许可协议，请勿用于商业，转载请注明出处！


