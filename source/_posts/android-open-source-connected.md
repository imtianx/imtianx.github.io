---
title: android 开源库（字体图标，MD控件等）
date: 2016-06-12 15:00:25
categories: [android,开源库]
tags: [android,开源框架]
---
记录自己最近在开发中使用的开源库及部分使用方法，链接地址为个人fork后的地址，可以参见原作者仓库。本文将持续更新，大家有什么好用的可以留言，一起交流学习下。
<!--more-->

### 1. android 开发常用工具类
地址：https://github.com/txadf/Lazy

### 2. 字体图标
地址：https://github.com/txadf/material-icon-lib
用法：
2.1.添加依赖
```
compile 'net.steamcrafted:materialiconlib:1.0.9'
```
2.2.xml中使用
注:需要添加命名空间
```
<net.steamcrafted.materialiconlib.MaterialIconView
        xmlns:app="http://schemas.android.com/apk/res-auto"
        android:id="@+id/icon"
        android:layout_width="24dp"
        android:layout_height="24dp"
        android:scaleType="center"
        app:materialIcon="account"
        app:materialIconColor="@color/mainColor"
        app:materialIconSize="24dp"/>
```
示例效果：
![](https://camo.githubusercontent.com/802f5408fb1caeae9647d6e72c5905225b24220d/687474703a2f2f692e696d6775722e636f6d2f4b584866586f382e676966)

### 3. UI Model
地址：http://genius.qiujuer.net/module/ui.html
按原作者网上站上的配置。
具体使用，按钮的使用：
```
<net.qiujuer.genius.ui.widget.Button
            xmlns:app="http://schemas.android.com/apk/res-auto"
            android:id="@+id/gbtn_login"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="25dp"
            android:background="@color/mainColor"
            android:onClick="LoginClickEvent"
            android:text="@string/login_btn"
            android:textColor="@color/white"
            app:gFont="roboto.ttf"
            app:gTouchColor="@color/black_alpha_32"
            app:gTouchDurationRate="0.7"
            app:gTouchEffect="ripple"/>
```
同样需要注意添加命名空间。
### 4. xutils3
地址：https://github.com/txadf/xUtils3
### 5.进度条
地址：https://github.com/txadf/spots-dialog
效果：
![](https://camo.githubusercontent.com/d8108413298d70047f52cff9ac05603a5fd51988/687474703a2f2f332e62702e626c6f6773706f742e636f6d2f2d6c3155765657694d5341672f564c61355a6657346444492f41414141414141414e54632f7273576f755f71623042632f733332302f593648615453772e676966)

### 6.对话框
地址:https://github.com/txadf/sweet-alert-dialog
示例效果：
![](https://github.com/pedant/sweet-alert-dialog/raw/master/change_type.gif)

### 7. EventBus
地址：https://github.com/txadf/EventBus
注意：在使用，进行注册订阅时，使用下面的方式，其中“XXX”表示需要订阅的Activity或者Fragment名，避免直接使用“this”：
```
EventBus.getDefault().register(XXX.this);
```
