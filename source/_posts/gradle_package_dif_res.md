---
title: gradle 打包不同资源
comments: true
date: 2017-06-25 12:22:25
categories: [android,学习笔记]
cover: true
tags: [android,gradle]
---

由于 android 中以 `applicationId` 作为应用唯一标识，所以不能在手机上安装两个相同 `applicationId` 的app。在 AS 中，默认创建的项目其 `applicationId`就是项目的包名。可以在gradle 中配置更改 改 applicationid。
<!--more-->
最近，维护的一个项目是一个导流的，一套代码每次打包成5个APP。每个APP除名字、icon、部分资源文件不同外，其他的基本一样。由于是维护项目，之前的同事是将其分成5个项目，那样每次迭代，都要在一个项目中写完测试通过后，拷贝到其他四个项目中，最后一个个项目打包。这样，既麻烦又浪费时间。因此，打算通过配置 gradle，打包时更换不同的 applicationeId、资源文件以及友盟的appkey，从而简化每次迭代的过程。

###  一、配置资源文件

为了方便测试，这里将 [DifPackage](https://github.com/imtianx/DifPackage) 项目打包为 `one`、`two`、`three`三个apk, `applicationId` 分别为：cn.imtianx.one、cn.imtianx.two 、cn.imtianx.three 。
其中，每个apk有不同的icon、不同的名字及界面上显示的文字也不同。

**在 `src` 下分别建立 one、two、three三个目录存放对应的资源文件，这里主要存放 apk icon、资源文件以及兼容7.0拍照用的 provider配置文件。**(更多7.0拍照适配,请[点击此处查看](http://imtianx.cn/2017/03/05/android%207.0-take-photo/))
具体项目结构如下图所示：

![](/img/article_img/2017/grale_dif_package_1.png)


>说明： 上图中，one、two、three三个问价夹在 src下，与 main 同级。one 中 res 下的文件目录和 main/src/res相同。

### 二、配置签名文件
对于签名文件的配置，有两种方式：一是直接写 `build.gradle` 中，而是写 在 `local.properties`文件中。后者想丢安全些，local.properties 通常为忽略文件不会提交。如下配置：
**方法一：在 build.gradle 文件中的 android 下添加如下代码**
```
signingConfigs{
    one {
        storeFile file("E\:\\workspace\\android_temp\\DifPackage\\app\\imtianx_one.jks")
        storePassword 123456
        keyAlias imtianx
        keyPassword 123456
    }
  /* two，three配置类似 */
}
```

**方法二：首先在 local.properties 下添加密钥信息，然后在 build.gradle 中读取使用**
```
/*local.properties */
## one keystore file
keystroe_storeFile_1 =E\:\\workspace\\android_temp\\DifPackage\\app\\imtianx_one.jks
keystroe_storePassword_1 =123456
keystroe_keyAlias_1 =imtianx
keystroe_keyPassword_1 =123456

/* build.gradle */
Properties properties = new Properties()
properties.load(project.rootProject.file('local.properties').newDataInputStream())

signingConfigs{
    one {
        storeFile file(properties.getProperty("keystroe_storeFile_1"))
        storePassword properties.getProperty("keystroe_storePassword_1")
        keyAlias properties.getProperty("keystroe_keyAlias_1")
        keyPassword properties.getProperty("keystroe_keyPassword_1")
    }

```
以 one 的配置为例，对于 two和three的配置与此类似。个人通常喜欢第二中配置方式。

### 三、配置 AndroidManifest文件

由于不同的app使用的友盟统计也不同，这里需要设置占位符在gradle中进行动态的替换。此外，对于7.0以后的拍照，provider 的配置要与 applicationId 一样。如下部分代码：
```
<application>

    <!-- 友盟统计 appkey-->
    <meta-data
        android:name="UMENG_APP_KEY"
        android:value="${UMENG_APP_KEY_VALUE}"/>
        
    <!-- 友盟统计 渠道-->
    <meta-data
        android:name="UMENG_CHANNEL"
        android:value="${UMENG_CHANNEL_VALUE}"/>

    <!-- 7.0 camera provider -->
    <provider
        android:name="android.support.v4.content.FileProvider"
        android:authorities="${applicationId}.provider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/provider_paths"/>
    </provider>
</application>
```
> 说明：开始两个 meta中的 value，在 gradle进行设置值，provider 中 的 applicationId 直接可以取到 gradle中配置的值。

### 四、配置 applicationId

这里主要是利用了多渠道打包的原理，在 productFlavors 中进行配置：

```
productFlavors{
    one{
        applicationId "cn.imtianx.one"
        manifestPlaceholders = [UMENG_APP_KEY_VALUE:"111111",UMENG_CHANNEL_VALUE:"one"]
        signingConfig signingConfigs.one
    }
    two{
        applicationId "cn.imtianx.two"
        manifestPlaceholders = [UMENG_APP_KEY_VALUE:"222222",UMENG_CHANNEL_VALUE:"two"]
        signingConfig signingConfigs.two
    }
    three{
        applicationId "cn.imtianx.three"
        manifestPlaceholders = [UMENG_APP_KEY_VALUE:"333333",UMENG_CHANNEL_VALUE:"three"]
        signingConfig signingConfigs.three
    }
}
```
> 说明：`productFlavors` 下的 one、two、three这里代表三个渠道。`applicationId` 用于配置应用 id,`manifestPlaceholders` 用于给 AndroidManifest 中配置的占位符设置值，这里仅仅为了测试随便写的值。`signingConfig signingConfigs.one`指定不同app的签名文件。此外，指定签名文件还可以按照下面的方式：
```
 buildTypes {
    productFlavors.one.signingConfig signingConfigs.one
    productFlavors.two.signingConfig signingConfigs.two
    productFlavors.three.signingConfig signingConfigs.three
 }
```

到此整个 配置已经结束。完整 gradle 的配置，请查看 [build.gradle](https://github.com/imtianx/DifPackage/blob/master/app/build.gradle)

### 五、打包测试
在 terminal 下输入 `gradle assembleRelease`进行打包，然后安装测试，可以成功的替换app的icon、名字及其他资源，能够同时安装。
如果需要查看 apk的签名信息，可以将其解压后，使用如下命令查看：
```
keytool -printcert -file META-INF/CERT.RSA
```
为了能够区别，前面创建 key store 时尽量用不同的信息。
至此，改打包方式介绍完毕，但是如果用这种方式，则不能进行 [多渠道打包](http://imtianx.cn/2016/12/12/android%20%20%E5%A4%9A%E6%B8%A0%E9%81%93%E6%89%93%E5%8C%85/)，这里多的 one、two、three类似于三个渠道。

项目源代码地址：[DifPackage](https://github.com/imtianx/DifPackage)



