---
title: android studio 生成aar和jar
date: 2016-10-20 16:06:25
categories: [android,学习笔记]
tags: [android,aar,jar]
---


### 1. aar包
**aar**包是android studio 下打包android 工程中的src、res、lib后生成的aar文件，以便导入到其他的as工程中使用。
在as中它的生成方式较为简单，主要步骤如下：
> 1.新建model，选择 android Library；
> 2.编写好自己的代码后，将gradle中的 **minifyEnabled**属性 设置成**true**<!--more-->，重新build下项目（**Build->Rebuild Project**,或者使用gradle中的build 命令）
> 3.将as的项目调节为project,进入model下，在**build/outputs/aar/**文件夹下会生成相应的aar文件，如下图：

![](/img/article_img/2016/show_aar.png)

### 2. jar包
在as中，不像ec那样可以直接导出jar,需要在gradle 中编写task,主要步骤：
>1.新建model 选择 Java Library，
>2.先写自己的代码
>3.在当前model 的gradle 中添写如下代码，**rebuid后便会在build/libs下生成相应的jar**
```
//Copy类型
task makeJar(type: Copy) {
    //删除存在的
    delete 'build/libs/javajarlib.jar'
    //设置拷贝的文件
    from('build/intermediates/bundles/release/')
    //打进jar包后的文件目录
    into('build/libs/')
    //include ,exclude参数来设置过滤
    include('classes.jar')
    //重命名
    rename('classes.jar', 'javajarlib.jar')
}
makeJar.dependsOn(build)
```
但是这种方法，生成的jar是和改model 的名字一样的，即使在上面指定了名字。

### 3. 具体使用
在具体的model中使用时，将生成的相应的包拷贝到libs文件夹中，对于jar可以右键 添加到library中，或者手动在 gradle 中添加。而，对于aar,则只能在gradle中手动添加，如下配置代码：

```
repositories{
    flatDir{
        dirs 'libs'
    }
}
//在dependencies 中添加，androidlibrary-release值aar包的名字
compile(name:'androidlibrary-release', ext:'aar')
```
通过上面的配置就可以直接在代码中使用了。



