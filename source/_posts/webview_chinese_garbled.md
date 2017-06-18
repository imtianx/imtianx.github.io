---
title: WebView 中文乱码
date: 2017-06-17 15:18:40
categories: [android,学习笔记]
tags: [android,webview,中文乱码]
---


这里主要记录关于`WebView`加载含中文的`url`和`cookie`中设置中文显示乱码的解决方法。
<!--more-->
目前，在android 开发中，为了方便程序进行扩展，很多 APP中都采用了  `WebView` 来加载 H5 页面，这样通过后台更换一个H5地址，程序中就有相应的变化，不用重新打包发布。我参与的项目中，使用 `WebView` 的场景主要有下面几种：商城类APP中的商品详情、签到、帮助中心、积分抽奖、邀请好友，banner详情等。


### 一、简单使用
在布局文件中添加 `WebView`  控件，然后在 `Activity` 总绑定控件，进行相关设置，部分代码如下；

```
mWebView = (WebView) findViewById (R.id.wv);
WebSettings webSettings = mWebView.getSettings();

/*支持JavaScript*/
webSettings.setJavaScriptEnabled (true);

/*支持缩放*/
webSettings.setSupportZoom (true);

/*启用内置缩放装置*/
webSettings.setBuiltInZoomControls (true);

/*设置不缓存*/
webSettings.setCacheMode (WebSettings.LOAD_NO_CACHE);

/*设置加载网页的url*/
mWebView.loadUrl ("http://192.168.0.101/WebViewDemo/index.html");
```
如果希望网页中的连接仍然是用`WebView`打开，需要进行如下设置：

```
mWebView.setWebViewClient (new WebViewClient()
{
    @Override
    public boolean shouldOverrideUrlLoading (WebView view, String url)
    {
        /*拦截网页中的链接，使其在WebView 中打开*/
        view.loadUrl (url);
        return true;
    }
});
```

如果打开多个网页，以免按返回键结束当前 Activity，需要监听返回键，具体有如下两种做法:

```
/*方法一*/
mWebView.setOnKeyListener (new View.OnKeyListener()
{
    @Override
    public boolean onKey (View v, int keyCode, KeyEvent event)
    {
        if (event.getAction() == KeyEvent.ACTION_DOWN)
        {
            if (keyCode == KeyEvent.KEYCODE_BACK && mWebView.canGoBack() )
            {
                /*后退*/
                mWebView.goBack();
                return true;
            }
        }
        return false;
    }
});

/*方法二*/
@Override
public boolean onKeyDown (int keyCode, KeyEvent event)
{
    if (keyCode == KeyEvent.KEYCODE_BACK)
    {
        if (mWebView.canGoBack() )
        {
            /*后退*/
            mWebView.goBack();
            return true;
        }
    }
    return super.onKeyDown (keyCode, event);
}
```


### 二、加载含中文url乱码
由于加载的网也上需要相关数据，所以后台返回时将其拼接在url中，然后在 H5页面中用js获取。如下样式的url,其中shopName 的值为中文，导致加载该页面时显示一直为乱码。
```
http://192.168.0.101/WebViewDemo/index.html?shopName=免单购平台&cell=123456789&qq=2360633699
```
由于url的限制，对于中文必须转码后可以使用。这里便将中文部分转码后使用，将中文转成 `unicode` ，并将其中的 `\` 换成 `%`,具体做法如下：
```
private String cnToUnicode (String cn)
{
    char[] chars = cn.toCharArray();
    String resultStr = "";
    for (int i = 0; i < chars.length; i++)
    {
        resultStr += "%u" + Integer.toString (chars[i], 16);
    }
    return resultStr;
}
```
使用方法可以将 上述 url中shopName 对应的值 “免单购平台” 转为如下：
```
%u514d%u5355%u591f%u5e73%u53f0
```
将替换出现的中文，即可解决乱码问题。可以通过后台进行处理。然而这种做法，在`android` 端可以，浏览器也可以，导致 `ios` 端无法显示网页，最终放弃，换用 `cookie`的方式。

关于更多url的资料，可以查看阮一峰的 [关于URL编码](http://www.ruanyifeng.com/blog/2010/02/url_encoding.html)这篇文章。

### 三、设置cookie 乱码
由于之前的项目在使用 H5 时，不管 android 还是 ios 都有用过cookie 来传递参数，于是我们换用中这种方式。然而，发现给cookie中设置的中文，在android 上会出现乱码，ios则不会。之前的用法中没有在cookie 中设置中文，便尝试了各种编码，最终使用 **` URLEncoder 的 encode() 发发进行编码`**。
如下是设置 cookie 的相关代码：

```
/**
 * 设置 cookie
 * @param url
 */
 private void setCookie(String url) {
    CookieSyncManager.createInstance(this);
    CookieManager cookieManager = CookieManager.getInstance();
    cookieManager.setAcceptCookie(true);
    try {
        /*对中文编码*/
        cookieManager.setCookie(url, "shopName=" + URLEncoder.encode(shopName, "utf-8"));
    } catch (UnsupportedEncodingException e) {
        e.printStackTrace();
    }
    cookieManager.setCookie(url, "cell=" + cell);
    cookieManager.setCookie(url, "qq=" + qq);
    if (Build.VERSION.SDK_INT < 21) {
        CookieSyncManager.getInstance().sync();
    } else {
        CookieManager.getInstance().flush();
    }
}

@Override
protected void onDestroy() {
    CookieSyncManager.createInstance(this);
    CookieManager cookieManager = CookieManager.getInstance();
    cookieManager.removeSessionCookie();
    if (Build.VERSION.SDK_INT < 21) {
        CookieSyncManager.getInstance().sync();
    } else {
        CookieManager.getInstance().flush();
    }
    super.onDestroy();
}
```

> 注：需要在设置 webview 之前调用 setCookie()方法。

最后只要在 H5 页面中使用js来获取即可。

此外，对于 WebView ,可以加载本地 html文件，可以加载 html 标签 ，可以与js互相调用等。
```
/*加载部分片段*/
mWebView .loadDataWithBaseURL("",data,"text/html","utf-8","");
```
美团关于 webview 的文章：
[WebView性能、体验分析与优化](http://tech.meituan.com/WebViewPerf.html)



 

