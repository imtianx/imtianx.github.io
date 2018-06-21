---
title: Retrofit2链式调用及文件下载
date: 2017-11-02 16:06:25
categories: [android,学习笔记]
tags: [retrofit2,flatMap,文件下载]
---

Retrofit2+Rxjava 是当下较为流行的网络请求方式，这里将其结合进行网络请求的链式调用以及文件下载，来解决项目中开屏广告页的设计。
<!--more-->
目前，很多APP中启动都有开屏广告，其中广告有静态图片、Gif图片或者短视频等，通常为了更好的用户体验，很多都是采用预下载的形式，即本此下载，下次打开生效。

## 一、开屏广告的设计
近期维护的一个项目中，刚好也有开屏广告，其做法如下图所示，打开app首先进入主页，获取广告路径，然后跳转广告页显示，结束后再跳转回主页。这种做法，可以保证每次打开都是最新的广告，但在显示广告页前会有短暂的几秒显示首页，体验不好。

![](/img/article_img/2017/Retrofit2_flatmap_download_1.png)

经过改造，采用预加载的方式，大致流程如下图所示，在首页中获取图片路径并下载到本地，下次打开时显示。

![](/img/article_img/2017/Retrofit2_flatmap_download_2.png)

通过上面的方式可以让广告也显示的更加自然，提高用户体验。

## 二、Retrofit2 文件下载
这里，为了开屏广告显示的更加流畅，节省流量，广告图片下载到本地。这里结合Rxjava 和 Rxandroid进行使用，如下代码：

```
public class DownloadPicAPI {
    public interface DownloadPicService {
        @Streaming
        @GET
        Observable<ResponseBody> downloadPic(@Url String fileUrl);
    }
    public static Observable<ResponseBody> downloadPic(Context context, String fileUrl) {
        DownloadPicService service = RestHelper.getBaseRetrofit(context)
		.create(DownloadPicService.class);
        return service.downloadPic(fileUrl);
    }
}
```
其中 `RestHelper ` 是对Retrofit和Rxjava进行封装的工具类，避免文件过大下载出错，添加 `@Streaming` 注解，请求完成将返回的 ` ResponseBody ` 保存到文件中。如下代码：

```
/**
 * 保存到本地
 *
 * @param body     
 * @param dir      目录
 * @param fileName 文件名
 * @return
 */
private boolean writeResponseBodyToDisk(ResponseBody body, String dir, String fileName) {
    try {
        File dirFile = new File(dir);
        if (!dirFile.exists()) {
            dirFile.mkdirs();
        }
        File saveFile = new File(dir + "/" + fileName);
        InputStream inputStream = null;
        OutputStream outputStream = null;
        try {
            byte[] fileReader = new byte[4096];
            inputStream = body.byteStream();
            outputStream = new FileOutputStream(saveFile);
            while (true) {
                int read = inputStream.read(fileReader);
                if (read == -1) {
                    break;
                }
                outputStream.write(fileReader, 0, read);
            }
            outputStream.flush();
            return true;
        } catch (IOException e) {
            return false;
        } finally {
            if (inputStream != null) {
                inputStream.close();
            }
            if (outputStream != null) {
                outputStream.close();
            }
        }
    } catch (IOException e) {
        return false;
    }
}
```

## 三、flatMap组合网络请求

这里，首先要获取广告信息，然后需要下载图片，两次网络请求，会出现嵌套调用，但是 **Rxjava** 的出现，可以让程序链式的调用，采用 **flatMap**操作符，如下代码：

```
 SplashAdAPI.requestSplashAd (getActivity() )
.flatMap (new Func1 < SplashAdModel, Observable<? >> ()
{
    @Override
    public Observable<ResponseBody> call (SplashAdModel splashAdModel)
    {
        if (splashAdModel.bizSucc)
        {

            String fileName = getActivity().getCacheDir().getAbsolutePath()
                              + "/splash_ad_pic.png";
            File file = new File (fileName);
            if (file.exists() )
            {
                /*存在缓存图片*/
                if (splashAdModel.url.equals (UserInfoHelper
                                              .getSplashAdUrl (getActivity() ) ) )
                {
                    /*无新url，则不下载图片*/
                    return null;
                }
                else
                {
                    /*有新url,删除缓存文件，更新本地url,下载图片*/
                    file.delete();
                    UserInfoHelper.saveSplashAdUrl (getActivity(), splashAdModel.url);
                    return DownloadPicAPI.downloadPic (getActivity(), splashAdModel.url);
                }
            }
            else
            {
                /*不存在缓存问价则下载*/
                UserInfoHelper.saveSplashAdUrl (getActivity(), splashAdModel.url);
                return DownloadPicAPI.downloadPic (getActivity(), splashAdModel.url);
            }
        }
        return null;
    }
})
.subscribeOn (Schedulers.io() )
.observeOn (AndroidSchedulers.mainThread() )
.subscribe (new Observer<Object>()
{
    @Override
    public void onCompleted() { }
    @Override
    public void onError (Throwable e)
    {
        Log.e ("imtianx", "onError: ----------", e);
    }
    @Override
    public void onNext (Object responseBody)
    {
        /*写入文件*/
        writeResponseBodyToDisk ( (ResponseBody) responseBody,
                                  getActivity().getCacheDir().getAbsolutePath(),
                                  "splash_ad_pic.png");
    }
});
```


上述代码中，`SplashAdAPI` 是获取图片url接口，`DownloadPicAPI` 是步骤二中的下载文件的接口。

> 使用 `getCacheDir()` 而非 `getExternalCacheDir()` 可以避免SD卡权限的问题和部分手机无外部存储而出现的空指针异常。或者，判断SD卡是否可用来选择存放位置。此外，将文件放在该缓存目录下，便于app卸载后清除数据。

使用 flatMap 操作符，轻松的将两次请求链接。这种开屏广告的设计仅是自己的看法，有更好做法的欢迎留言，交流。


> **本文作者**：[imtianx](http://imtianx.cn/about)
> **本文链接**：http://imtianx.cn/2017/11/02/Retrofit2_flatmap_download
> **版权申明**:：本站文章均采用 [CC BY-NC-SA 3.0 CN](http://creativecommons.org/licenses/by-nc-sa/3.0/cn/) 许可协议，请勿用于商业，转载请注明出处！







