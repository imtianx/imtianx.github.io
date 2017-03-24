---
title: android自动获取短信验证码
date: 2016-04-23 16:08:25
categories: [android,学习笔记]
tags: [android,验证码]
---
这里主要使用了**ContentObserver**类（观察者模式类）来监听短信的变化，然后通过**正则表达式**，提取出短信，然后在子线程中更新UI，显示验证码。<!--more-->
所谓的观察者模式，它是软件设计模式的一种，在此种模式中，一个目标物件管理所有相依于它的观察者物件，并且在它本身的状态改变时主动发出通知。这通常透过呼叫各观察者所提供的方法来实现。此种模式通常被用来实现事件处理系统。观察者模式（Observer）完美的将观察者和被观察的对象分离开，在模块之间划定了清晰的界限，提高了应用程序的可维护性和重用性。观察者设计模式定义了对象间的一种一对多的依赖关系，以便一个对象的状态发生变化时，所有依赖于它的对象都得到通知并自动刷新。
ContentObserver,内容观察者，目的是观察(捕捉)特定Uri引起的数据库的变化，继而做一些相应的处理，它类似于数据库技术中的触发器(Trigger)，当 ContentObserver 所观察的Uri发生变化时，便会触发它。
观察特定Uri的步骤如下：

 1. 、创建我们特定的 ContentObserver 派生类，必须重载父类构造方法，必须重载 onChange() 方法去处理回调后的功能实现。
 2. 利用 context.getContentResolover() 获得 ContentResolove 对象，接着调用 registerContentObserver() 方法去注册内容观察者。
 3. 由于 ContentObserver 的生命周期不同步于 Activity 和 Service 等，因此，在不需要时，需要手动的调用 unregisterContentObserver() 去取消注册。

*具体使用：*
### 1、继承ContentObserver，重写onChange方法
```
package com.tx.testsms;
/**
 * 自动读取短信验证码
 */
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;
import android.database.ContentObserver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;

public class SmsObserver extends ContentObserver {

	private Context mContext;
	private Handler mHandler;
	private String tel_phone = "";

	private String code;

	public void setTel_phone(String tel_phone) {
		this.tel_phone = tel_phone;
	}

	public SmsObserver(Context mContext, Handler handler) {
		super(handler);
		this.mContext = mContext;
		this.mHandler = handler;
	}

	@Override
	public void onChange(boolean selfChange, Uri uri) {
		// TODO Auto-generated method stub
		super.onChange(selfChange, uri);

		if(uri.toString().equals("content:://sms//raw")){
			return;
		}

		Uri inboxUri = Uri.parse("content://sms//inbox");

		Cursor cursor = mContext.getContentResolver().
				query(inboxUri, null, null, null, "date desc");

		if(cursor!=null){
			if(cursor.moveToFirst()){
				String address = cursor.getString(cursor.getColumnIndex("address"));
				Log.i("test", "短信验证码为：--------"+address);

				String body = cursor.getString(cursor.getColumnIndex("body"));
				Log.i("test", "uri---------"+inboxUri);

				if(address.equals(tel_phone)){

					Pattern pattern = Pattern.compile("(\\d{4})");
					Matcher matcher = pattern.matcher(body);

					if(matcher.find()){
						code = matcher.group(0);
						Log.i("test", "短信验证码为：--------"+code);
						mHandler.obtainMessage(
								MainActivity.MSG_RECEIVED_CODE,code).sendToTarget();
					}

				}

			}
			cursor.close();
		}
	}
}
```

### 2、在MainActivity中注册监听，在子线程中更更新显示UI，并复写onDestroy，取消注册
```
package com.tx.testsms;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {

	public static final int MSG_RECEIVED_CODE = 1;

	private SmsObserver mSmsObserver;
	private Handler mHandler;

	private EditText metPhone;
	private TextView mtvCode;
	private Button mbtnButton;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_main);

		metPhone = (EditText) findViewById(R.id.phone);
		mbtnButton = (Button) findViewById(R.id.btn);
		mtvCode = (TextView) findViewById(R.id.code);

		/**
		 * 设置手机号，拦截固定的手机号
		 */

		mbtnButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				mSmsObserver.setTel_phone(metPhone.getText().toString());
			}
		});

		/**
		 * 在子线程中更新UI
		 */
		mHandler = new Handler(){
			@Override
			public void handleMessage(Message msg) {
				// TODO Auto-generated method stub
				super.handleMessage(msg);
				if(msg.what == MSG_RECEIVED_CODE){
					mtvCode.setText("四位短信验证码为："+msg.obj.toString());
					Toast.makeText(getApplicationContext(), msg.obj.toString(), Toast.LENGTH_SHORT).show();
				}
			}
		};

		<span style="color:#ff0000;">/**
		 * 实例化ContentObserver,注册短信监听
		 */
		mSmsObserver = new SmsObserver(getApplicationContext(), mHandler);
		Uri  uri = Uri.parse("content://sms");
		getContentResolver().registerContentObserver(uri, true, mSmsObserver);</span>

	}

	/**
	 * 由于 ContentObserver 的生命周期不同步于 Activity 和 Service ，
	 * 因此需要手动取消注册
	 * 
	 */

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		<span style="color:#ff0000;">getContentResolver().unregisterContentObserver(mSmsObserver);</span>
	}
}
```
### 3、注意在配置文件中添加读取短信的权限：
```
 <uses-permission android:name="android.permission.READ_SMS" />
 ```
**注意：最小sdk为16.**
###  4、如下运行截图：
![](http://img.blog.csdn.net/20151017130345615?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
控制台打印出的Log：
![](http://img.blog.csdn.net/20151017130527628?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

例子源代码：http://download.csdn.net/detail/txadf/9188791
