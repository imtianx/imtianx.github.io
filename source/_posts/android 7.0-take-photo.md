---
title: android 7.0相机拍照适配
date: 2017-03-05 16:06:25
categories: [android,学习笔记]
tags: [android7.0,拍照适配,相册]
---

最近，之前一个项目的用户反馈APP拍照崩溃，查看了线上Crash日志，发现是  `EVA-AL10` 和 `ZUK Z2131` 两款手机，android 版本都是7.0的<!--more-->，看了下具体的错误消息，如下：
```
//...
Caused by: android.os.FileUriExposedException: file:///storage/emulated/0/1489548204216.jpg exposed beyond app through ClipData.Item.getUri()
at android.os.StrictMode.onFileUriExposed(StrictMode.java:1816)
//...
```
在 Stackoverflow 查了下，发现是google 在 android N 之后，提高了私有文件的安全性，应用私有目录将被限制访问，无法通过  ` file:// URI 类型的Uri` 进行应用间文件共享，必须使用 `content:// URI类型的Ur,并授予 URI 临时访问权限。`

下面是官方对7.0权限和文件共享的说明：

![](http://img.imtianx.cn/android-7.0-permission-file-change.png)

具体内容请查看[  官方说明-7.0行为变更](https://developer.android.google.cn/about/versions/nougat/android-7.0-changes.html#perm)(无需翻墙)

如下是 android N 相机的适配过程：

一、 **在manifest清单文件中注册provider**

 添加如下代码：

```
<provider
    android:name="android.support.v4.content.FileProvider"
    android:authorities="com.puyue.www.moneysteward.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths"/>
</provider>
```
 > 说明：
exported:要求必须为false，为true则会报安全异，
grantUriPermissions:true，表示授予 URI 临时访问权限
authorities：**包名.provider**，准确的说应该是 applicationId。

二、 **指定共享的目录**

在 `res` 下新建 `xml` 目录，然后新建 `file_paths.xml`文件，该文件名无限制，但须和上面 provider 中的 resource 指定的一致，内容如下：

```
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path
        name="temp_photo"
        path="."/>
</paths>
```
> 说明：
**path=""**：它代码根目录，也就是说你可以向其它的应用共享根目录及其子目录下任何一个文件了，如果你将path设为**path="pictures"**， 
那么它代表着根目录下的pictures目录(/storage/emulated/0/pictures)，如果你向其它应用分享pictures目录范围之外的文件是不行的。

三、**使用 FileProvider**

如下具体的拍照做法：

```
tempCameraFilePath = Environment
                     .getExternalStorageDirectory() +
                     "/takePic/" +
                     System.currentTimeMillis() + ".jpg";
File file = new File (tempCameraFilePath);
if (!file.exists() )
{
    file.getParentFile().mkdirs();
}
Intent intent = new Intent (MediaStore.ACTION_IMAGE_CAPTURE);
Uri uri = Uri.fromFile (new File (tempCameraFilePath) );

//适配7.0
if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M)
{
    uri = FileProvider
          .getUriForFile (this,
                          BuildConfig.APPLICATION_ID +
                          ".provider", file);
}
intent.putExtra (MediaStore.EXTRA_OUTPUT, uri);
startActivityForResult (intent, REQUEST_CODE_CAMERA);
}
```

需要对手机版本进行判断，否则直接用 `FileProvider` 在低版本手机上会导致相机 停止运行。注意需要申明下面两个权限：

```
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

此外，由于拍照指定了 uri ,在 `onActivityResult`返回的 data 往往是 空的。

在开发中，除了拍照，经常还会遇见 打开相册选取图片，下面是最近遇到的坑。

对于大多手机，都可以通过 `ACTION_PICK` 来打开相册，选取图片，如下：

```
Intent intent = new Intent(Intent.ACTION_PICK, null);
intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
startActivityForResult(intent, REQUEST_CODE_ALBUM);
```

然而对于小米手机，却无法获取返回的路径，以下是对返回的 URI 的处理办法(来自网络)：

```
/**
 * 解决小米手机 相册 返回 null
 *
 * @param intent
 * @return
 */
public Uri getPictureUri (android.content.Intent intent)
{
    Uri uri = intent.getData();
    String type = intent.getType();
    if (uri.getScheme().equals ("file") && (type.contains ("image/") ) )
    {
        String path = uri.getEncodedPath();
        if (path != null)
        {
            path = Uri.decode (path);
            ContentResolver cr = this.getContentResolver();
            StringBuffer buff = new StringBuffer();
            buff.append ("(").append (MediaStore.Images.ImageColumns.DATA).append ("=")
            .append ("'" + path + "'").append (")");
            Cursor cur = cr.query (MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                                   new String[] {MediaStore.Images.ImageColumns._ID},
                                   buff.toString(), null, null);
            int index = 0;
            for (cur.moveToFirst(); !cur.isAfterLast(); cur.moveToNext() )
            {
                index = cur.getColumnIndex (MediaStore.Images.ImageColumns._ID);
                // set _id value
                index = cur.getInt (index);
            }
            if (index == 0)
            {
                // do nothing
            }
            else
            {
                Uri uri_temp = Uri
                               .parse ("content://media/external/images/media/"
                                       + index);
                if (uri_temp != null)
                {
                    uri = uri_temp;
                }
            }
        }
    }
    return uri;
}
```

然后在 `onActivityResult`进行处理返回的uri:

```
@Override
protected void onActivityResult (int requestCode, int resultCode, Intent data)
{
    super.onActivityResult (requestCode, resultCode, data);
    switch (requestCode)
    {
    case REQUEST_CODE_ALBUM:   //相册
    {
        if (resultCode == RESULT_OK)
        {
            if (data != null)
            {
                Uri uri = getPictureUri (data); //处理返回的uri
                String path = "";
                String[] proj = {MediaStore.Images.Media.DATA};
                Cursor cursor = getContentResolver().query (uri, proj, null, null, null);
                if (cursor != null)
                {
                    int index = cursor.getColumnIndexOrThrow (
                                    MediaStore.Images.Media.DATA);
                    cursor.moveToFirst();
                    path = cursor.getString (index);
                    cursor.close();
                    //do something
                }
            }
        }
        break;
    }

    }
}
```
自己开发 用nexus6 测试毫无问题，却被测试妹子发现了，国内的手机厂商对room的阉割，导致 android 的适配变得很难，最近在做权限的处理时，又一次遇到了各种坑。

