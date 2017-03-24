---
title: Eventbus 开源库的使用
date: 2016-04-23 16:26:25
categories: [android,学习笔记]
tags: [Eventbus,开源框架]
---
EventBus是一款用用于android上的事件分发/订阅的总线，包含发布者、订阅者、事件和总线。主要用于android中intent,handler等在activity，fragment等组件间传递消息。<!--more-->它极好的将消息的发送者和接收者解耦，方便组件间的通信。
下载地址：
            原地址：https://github.com/greenrobot/EventBus
            涛哥的地址：https://github.com/kymjs/EventBus （包含部分中文注释）

### 1、简单使用

首先下载改开源库，导入项目中。接下来就是具体的使用了。如下几个方法：

 -  EventBus.getDefault().register(this);注册订阅者
 -  EventBus.getDefault().post("点击按钮，发送消息");发送消息，传入的是自己的事件类对象
 -  重写 onEventMainThread(Object object) 方法；接收处理消息，这里参数与发送消息的类型一致。
 -  在 onDestroy()中注销当订阅者。
 
这里仅仅为了说明用法，简单的实现代码如下：
```
package com.tx.eventbusdemo;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import de.greenrobot.event.EventBus;

public class MainActivity extends Activity {

	private Button mbtnSend;
	private TextView mtvShowmsg;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		//当前类注册为事件订阅者
		EventBus.getDefault().register(this);
		mbtnSend = (Button) findViewById(R.id.btn);
		mtvShowmsg = (TextView) findViewById(R.id.show);

		mbtnSend.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				//发送消息
			EventBus.getDefault().post("点击按钮，发送消息");
			}
		});
	}
	//接收处理消息
	public void onEventMainThread(Object object) {  
		mtvShowmsg.setText(object.toString());
	}
	@Override
	protected void onDestroy() {
		super.onDestroy();
		//注销注册
		EventBus.getDefault().unregister(this);
	}
}
```
效果图：
![](http://img.blog.csdn.net/20151230182722984?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

### 2、解析实现过程

首先在oncreate方法中注册订阅者，它就会扫描当前类，把onEvent开头的方法记录到map中（Key为方法的参数类型，Value中包含我们的方法）；
当子线程执行完毕后，调用post方法，根据其参数查找对应的方法，通过反射来执行相关的方法。

EventBus包含4个ThreadMode：PostThread，MainThread，BackgroundThread，Async。
对应的方法及功能为：
**onEventPostThread**   在当前发布事件的线程中执行
**onEventMainThread**   在ui线程中执行
**onEventAsync**   加入后台任务队列，使用线程池调用。
**onEventBackgroundThread**   在非UI线程发布的事件，则直接执行；否则，加入后台任务队列，使用线程池一个接一个调用。
