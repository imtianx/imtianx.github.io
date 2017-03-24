---
title: android  多渠道打包
date: 2016-12-12 16:06:25
categories: [android,学习笔记]
tags: [android,多渠道打包]
---
这里介绍使用友盟进行多渠道打包，[参考慕课视屏](http://www.imooc.com/learn/752)

## 一、 配置环境
使用 `gradle` 添加依赖：

```
//友盟统计
compile 'com.umeng.analytics:analytics:latest.integration'
```
<!-- more -->
> 注：版本号使用 **latest.integration** 替换， 这种依赖方式可以保证每次使用的都是最新的sdk（但这种使用得sdk支持）；或者在具体版本号后添加 **+** 也可以。

在 manifests文件中添加相关的权限、appkey及渠道号：

```
<!--相关权限 -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>

<activity >
    <meta-data
        android:name="UMENG_APPKEY"
        android:value="	564ac7c1e0f55aff0a000569"/> <!-- 友盟统计app id-->
    <meta-data
        android:name="UMENG_CHANNEL"
        android:value="${UMENG_CHANNEL_VALUES}"/> <!--  渠道号-->
</activity>

```
更多配置可参见[官方文档](http://dev.umeng.com/analytics/android-doc/integration?spm=0.0.0.0.RSo52l)。

## 二、编写配置脚本
主要是在model的gradle中编写相关的配置脚本，如下：

```
defaultConfig{
   //...
   multiDexEnabled true //突破方法数65536的限制
   manifestPlaceholders = [UMENG_CHANNEL_VALUES: "umeng"] //默认渠道号
   //...
}
buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'

            //指定签名文件
            signingConfig signingConfigs.release
        }
    }
    //添加签名文件信息
    signingConfigs {
        debug {}
        //release 包添加签名文件
        release {
            storeFile file("D:/workspace_ide_settings/imtianxappkey.jks") //签名文件
            storePassword "123456" //签名文件密码
            keyAlias "imtianx" //别名
            keyPassword "123456" //签名密码
        }
    }
    //配置渠道号
    productFlavors {

        meizu {
            //1.在每个渠道中指定渠道号
           //manifestPlaceholders = [UMENG_CHANNEL_VALUES: "meizu"]
           //指定相应渠道appname,需要将values/string中的 app_name隐藏
            //resValue "string","app_name","testxiaomi"
        }

        xiaomi {
         //manifestPlaceholders = [UMENG_CHANNEL_VALUES: "xiaomi "]
        }
    }
    //2.使用脚本为每个渠道指定渠道号
    productFlavors.all {
        flavor -> flavor.manifestPlaceholders = [UMENG_CHANNEL_VALUES: name]
    }
```

到此，脚本配置已经完成，在 terminal 中使用下面命定打包：

```
//打release 包
gradle assembleRelease
//打debug包
gradle assembleDebug
//打指渠道的release包
gradle assemblemeizuRelease
```
如果是第一次使用，打造包时会下载一些相应的工具包，速度较慢。打包完成后，在 `build/outputs/apk/`文件下下就会看见相应的，这里打的是 releas包，名字为：`app名-渠道名-release.apk`

如果想改变包名，可以配置如下代码进行指定包名：

```
  buildTypes {
        release {
        //...
         //指定release包名 为市场名
         applicationVariants.all {
            variant ->
                variant.outputs.each {
                    output ->
                        def outputFile = output.outputFile
                        if (outputFile != null && outputFile.name.endsWith(".apk")) {
                            def fileName = "${variant.productFlavors[0].name}" + ".apk"
                            output.outputFile = new File(outputFile.parent, fileName);
                        }
                }
        }
    }
}

```

然后在 terminal 中进行执行命令打包。







