---
title: 初识widget桌面小组件
date: 2016-04-23 16:20:25
categories: [android,学习笔记]
tags: [android,widget]
---
学习android widget的使用，使用高德地图的定位功能中的天气api来获取天气，做了个简单的demo。<!--more-->widget的开发步骤如下：

 1. 编写widget布局和配置文件；
 2. 编写自己的provider继承自AppWidgetProvider；
 3. 使用服务来更新widget；
 4. 修改配置文件。

开发之前先导入高德定位jar包，修改配置文件添加自己的appkey和相关的权限。（详情请参照：http://lbs.amap.com/api/android-location-sdk/guide/weather/）

### 一、编写widget布局文件和配置文件
这里就添加了一个TextView来显示天气信息；
widget配置文件： src/xml/widgetconfig 
```
<span style="font-size:18px;"><?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/widget"
    android:minHeight="100dp"
    android:minWidth="200dp"
    android:updatePeriodMillis="860000" >

</appwidget-provider></span>
```
### 二、AppWidgetProvider的编写，启动与停止服务。
在AppWidgetProvider中的主要方法有：
onEnabled(Context context)--第一个widget添加时调用
onDeleted(Context context, int[] appWidgetIds)--widget被从屏幕移除时调用
onDisabled(Context context) --widget 最后一个被从屏幕移除
onUpdate(Context context, 
AppWidgetManager appWidgetManager,
int[] appWidgetIds)---刷新widget

代码：
```
package com.tx.weatherwidget;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
public class WeatherProvider extends AppWidgetProvider {
	/**
	 * widget第一个添加到桌面执行
	 */
	@Override
	public void onEnabled(Context context) {
		// TODO Auto-generated method stub
		super.onEnabled(context);
		Intent intent = new Intent(context, WeatherService.class);
		context.startService(intent);
	}
	/**
	 * 最后一个widget移除桌面执行
	 */
	@Override
	public void onDisabled(Context context) {
		// TODO Auto-generated method stub
		super.onDisabled(context);
		Intent intent = new Intent(context, WeatherService.class);
		context.stopService(intent);
	}
	/**
	 * 更新数据
	 */
	@Override
	public void onUpdate(Context context, AppWidgetManager appWidgetManager,
			int[] appWidgetIds) {
		// TODO Auto-generated method stub
		super.onUpdate(context, appWidgetManager, appWidgetIds);
	}
}
```
### 三、service的编写，获取天气，widget更新。
主要代码在updateView中，这里使用RemoteViews，AppWidgetManager的updateAppWidget来通知widget更新。
代码：
```
package com.tx.weatherwidget;
/**
 * 调用高德地图的天气api获取天气
 * 
 */
import android.app.Service;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import android.os.IBinder;
import android.widget.RemoteViews;
import android.widget.Toast;

import com.amap.api.location.AMapLocalWeatherForecast;
import com.amap.api.location.AMapLocalWeatherListener;
import com.amap.api.location.AMapLocalWeatherLive;
import com.amap.api.location.LocationManagerProxy;
import com.tx.weatherwidget.R;

public class WeatherService extends Service implements
AMapLocalWeatherListener{
	private LocationManagerProxy mLocationManagerProxy;
	@Override
	public IBinder onBind(Intent arg0) {
		// TODO Auto-generated method stub
		return null;
	}
	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		init();
	}
	/**
	 * 注册天气监听
	 */
	private void init() {
		mLocationManagerProxy = LocationManagerProxy.getInstance(this);
		mLocationManagerProxy.requestWeatherUpdates(
				LocationManagerProxy.WEATHER_TYPE_LIVE, this);
	}
	@Override
	public void onWeatherForecaseSearched(AMapLocalWeatherForecast arg0) {
		// TODO Auto-generated method stub

	}
	@Override
	public void onWeatherLiveSearched(AMapLocalWeatherLive aMapLocalWeatherLive) {
		// TODO Auto-generated method stub
		if(aMapLocalWeatherLive!=null && aMapLocalWeatherLive.getAMapException().getErrorCode() == 0){
			String city = aMapLocalWeatherLive.getCity();//城市
			String weather = aMapLocalWeatherLive.getWeather();//天气情况
			String windDir = aMapLocalWeatherLive.getWindDir();//风向
			String windPower = aMapLocalWeatherLive.getWindPower();//风力
			String humidity = aMapLocalWeatherLive.getHumidity();//空气湿度
			String reportTime = aMapLocalWeatherLive.getReportTime();//数据发布时间
			updateView("城市： "+city+'\n'+
					"风向： "+windDir+'\n'+
					"风力： "+windPower+'\n'+
					"天气情况： "+weather+'\n'+
					"空气湿度： "+humidity+'\n'+
					"数据发布时间： "+reportTime+'\n');

		}else{
			// 获取天气预报失败
			Toast.makeText(this,"获取天气预报失败:"+ aMapLocalWeatherLive.getAMapException().getErrorMessage(), Toast.LENGTH_SHORT).show();
		}
	}
	private void updateView(String info){
		RemoteViews remoteViews = new RemoteViews(getPackageName(),
				R.layout.widget);
		remoteViews.setTextViewText(R.id.weather, info);
		AppWidgetManager manager = AppWidgetManager.
				getInstance(getApplicationContext());
		ComponentName provider = new ComponentName(
				getApplicationContext(), WeatherProvider.class);
		manager.updateAppWidget(provider, remoteViews);
	}
}
```
### 四、修改配置文件，注册服务。
代码：
```
<receiver android:name="com.tx.weatherwidget.WeatherProvider" >
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>

            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/widgetconfig" />
        </receiver>

        <service android:name="com.tx.weatherwidget.WeatherService" >
        </service>
```
源代码下载：[weatherWidget](http://download.csdn.net/detail/txadf/9267497)







