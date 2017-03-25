---
title: android 打开其他应用
date: 2016-04-23 16:10:25
categories: [android,学习笔记]
tags: [android,打开应用]
---
在开发中，有时需要在自己的应用中打开其他应用，自己写了两个方法来获取手机上安装的所有应用。这里主要以打开支付宝为例。<!--more-->
（1）、获取手机上的所有应用，将其放在一个list中。
```
private List<PackageInfo> getAllApps() {     
	List<PackageInfo> apps = new ArrayList<PackageInfo>();     
	PackageManager packageManager = this.getPackageManager();     
	//获取手机内所有应用     
	List<PackageInfo> paklist = packageManager.getInstalledPackages(0);     
	for (int i = 0; i < paklist.size(); i++) {     
		PackageInfo pak = (PackageInfo) paklist.get(i);     
		//判断是否为非系统预装的应用  (大于0为系统预装应用，小于等于0为非系统应用)   
		if ((pak.applicationInfo.flags & pak.applicationInfo.FLAG_SYSTEM) <= 0) {     
			apps.add(pak);     
		}     
	}     
	return apps;     
}  
```
（2）、打开指定的app(这里打开的是支付宝)。下面的方法是在知道支付宝app的包名的情况下进行判断的，通常情况下不知道包名，可以通过appLabel可以获取应用的名称，以此来匹配。在不存在的情况下，使用手机自带浏览器打开指定的网页。
```
private static final String PAY_PACKAGE_NAME = "com.eg.android.AlipayGphone";
private static final String PAY_WEB_URL = "https://auth.alipay.com/login/index.htm";
	
private void launchApp() {   
	PackageManager packageManager = this.getPackageManager();   
	List<PackageInfo> packages = getAllApps();   
	PackageInfo pa = null;   
	for(int i=0;i<packages.size();i++){   
		pa = packages.get(i);   
		//获得应用名   
		String appLabel = packageManager.getApplicationLabel(pa.applicationInfo).toString();   
		//获得包名   
		String appPackage = pa.packageName; 
		Log.e("test", ""+i+"----"+appLabel+"  "+appPackage);   
		
		//安装支付宝，打开支付宝
		if(appPackage.equals(PAY_PACKAGE_NAME)){
			mIntent = packageManager.getLaunchIntentForPackage(PAY_PACKAGE_NAME);
			startActivity(mIntent); 
			return;
		}
	} 
	//为安装支付宝，打开支付宝登陆的网页
	mIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(PAY_WEB_URL));
	mIntent.setClassName("com.android.browser", "com.android.browser.BrowserActivity");
	startActivity(mIntent);
}   
```
最后，注意添加网络访问的权限。