---
title: android 中webview的屏幕适配问题
date: 2016-04-23 15:18:40
categories: [android,学习笔记]
tags: [android,webview,屏幕适配]
---
两行代码解决WebView的屏幕适配问题
<!--more-->
一个简单的方法，让网页快速适应手机屏幕，代码如下
```
WebSettings webSettings= webView.getSettings();
webSettings.setLayoutAlgorithm(LayoutAlgorithm.SINGLE_COLUMN);
```


说明：
*LayoutAlgorithm*  是一个枚举，用来控制html的布局，总共有三种类型：<br> **NORMAL**：正常显示，没有渲染变化。<br> **SINGLE_COLUMN**：把所有内容放到WebView组件等宽的一列中。<br> **NARROW_COLUMNS**：可能的话，使所有列的宽度不超过屏幕宽度。