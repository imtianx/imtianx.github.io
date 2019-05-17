---
title: android IPC 机制及进程通信
date: 2016-12-14 16:06:25
categories: [android,学习笔记]
tags: [IPC,AIDL,进程通信]
---

 > 本文为读书笔记： 《Android 开发艺术探索 》——第二章 IPC 机制


android  开发中有时候需要用到多进程，那么了解进程间通信对我们开发就尤为重要。往往多进程分为两种情况： 一是一个应用因某些原因需要多进程（如某些模块需要在单独的进程中，或者是为了加大本应用所能使用的内存空间等）；二是当前应用需要想起他应用获取数据。<!-- more -->

## 一、IPC简介

**IPC** 是 `Inter-Process Communication` 的缩写，含义为进程间通信或者跨进程通信，指两个进程间进行数据交互的过程。
**进程**:是cpu调度的最小单位，是一种有限的系统资源，一般只一个执行单元。在PC或者移动设备上指一个程序或者一个应用。而一个进程可以包含多个进程。

IPC 不是android 中所独有的，任何操作系统都有。Windows上可以通过剪切板、管道和邮槽等来进行进程间通信；Linux 上可以通过命名管道、共享内存、信号量等进行通信;而android 他是一种基于linux 内核的移动操作系统，他的进程间通信方式并不完全继承自linux, 却有着自己独特的方式——`Binder`，此外，还可以使用Socket进行进程间通信。

## 二、android 中的多进程模式

在android 中如果使用多进程，通过给四大组件指定 `android:process` 属性即可开启多进程，此外还可以通过 JNI 在native 层 fork 一个新的进程。
如下activity 配置示例代码：

```
 <activity android:name=".activity.MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>

                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
 </activity>

<activity
    android:name=".activity.SecondActivity"
    android:configChanges="screenLayout"
    android:label="@string/app_name"
    android:process=":remote"/>
<activity android:name=".activity.ThirdActivity"
    android:configChanges="screenLayout"
    android:label="@string/app_name"
    android:process="com.imtianx.ipcdemo.remote"/>

```
通过 MainActivity 启动 SecondActivity ，SecondActivity 启动 ThirdActivity。
这三个activity 分别运行在三个不同的进程中：
```
//在as中打开terminal 输入下面命令
adb shell
//查看进程：ps|grep 包名
ps|grep cn.imtianx.ipcdemo
//三个进程如下
USER      PID   PPID  VSIZE  RSS   WCHAN            PC  NAME
u0_a106   3682  1680  1136428 57512 SyS_epoll_ 00000000 S cn.imtianx.ipcdemo
u0_a106   3808  1680  1134324 57360 SyS_epoll_ 00000000 S cn.imtianx.ipcdemo:remote
u0_a106   3918  1680  1166916 57920 SyS_epoll_ 00000000 S cn.imtianx.ipcdemo.remote
```

或者在monitor界面也可以查看。MainActivity没有指定process属性，则他在应用的包名 `cn.imtianx.ipcdemo` 对应的进程中,其他两个分别 SecondActivity、ThirdActivity 所在的进程。对于SecondActivity ，他的进程是 以 **：** 申明的，是指在当前的进程名前加上包名，为 **私有进程**，其他应用不可与其在同一进程中；而不以 “ ：”开头的进程，属于 **全局进程** ，则可以。

> 对于每个进程，都有一个独立的虚拟机，在内存中都有着不同的地址，这会导致不同虚拟机访问同一对象会产生多个副本，互不影响，若在一个进程中修改了数据，在另一个进程中不会变。即多进程下不能通过内存共享数据。

一般多进程会造成如下几个问题：

- 静态成员和单利失效
- 多线程同步进制失效
- SharedPreference 的可靠性下降
  底层是通过读写XML实现的，并发读写是会出问题的
- Application 会被多次重建
  运行在同一进程中的组件属于同一个虚拟机和同一个Application的


## 三、IPC 基础概念
只有明白了 IPC 中的 **Serializable接口、 Parcelable接口 和 Binder**相关的基础概念  ，才能更好的理解跨进程通信。  Serializable接口和 Parcelable接口 是实现序列化的两种方式。对于Intent 和 Binder 传输数据、对象持久化到本地或者网络传输，都需要使用。

### 3.1 Serializable接口

Serializable接口 是java 中的，是一个空的接口，使用时直接实现，添加如下标识，即可自动实现序列化和反序列化操作。在使用过程中开销较大，需要大量操作io。

```
private static final long serialVersionUID = 1L;
```
对于 `transient` 标识的属性和静态成员变量 ， 不参与序列化。


### 3.2 Parcelable接口
Parcelable接口 是android 特有的序列化方式，使用起来稍微麻烦，但是效率较高，主要用于内存序列化。如下使用示例：

```
public class User implements Parcelable{

    private String id;
    private String name;
    private String sex;
    private int age;

    protected User(Parcel in) {
        id = in.readString();
        name = in.readString();
        sex = in.readString();
        age = in.readInt();
    }

    //用于反序列化
    public static final Creator<User> CREATOR = new Creator<User>() {
        /**
         * 从序列化对象中创建原始对象
         * @param in
         * @return
         */
        @Override
        public User createFromParcel(Parcel in) {
            return new User(in);
        }

        /**
         * 创建指定长度的原始对象数组
         * @param size
         * @return
         */
        @Override
        public User[] newArray(int size) {
            return new User[size];
        }
    };

    /**
     * 内容功能描述
     * 大多数返回0，仅当当前对象中存在文件描述符时返回1
     * @return
     */
    @Override
    public int describeContents() {
        return 0;
    }

    /**
     * 当前对象写入序列化结构
     * @param dest
     * @param flags
     */
    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(id);
        dest.writeString(name);
        dest.writeString(sex);
        dest.writeInt(age);
    }
}

```

这里虽然看着很复杂，但这些方法全部可以自动生成，不用手动编写。android 中的 Intent 、Bundle、Bitmap等都实现了Parcelable接口，都是可以进行序列化的。

### 3.3 Binder

Binder 实现了 IBinder接口。从ipc角度，binder是一种跨进程通信方式，还可以理解为一种虚拟的物理设备，其驱动是 /dev/binder ;从 android Framework 角度说，Binder 是 ServiceManager 连接各种 Manager（ActivityManager、WindowManger，...）和相应 ManagerServices的桥梁；从 android 应用层来说，Binder是客户端与服务器端进行通信的媒介。

android中 Binder 主要用在Services中，包括 AIDL 和 Messenger , Messenger 底层是 AIDL 实现的。

如下是Binder的工作流程图：

![](/img/article_img/2016/Binder 工作机制.png)

## 四、android 中的IPC 方式

如下各种 IPC 方式的优缺点对比：

|名称 |优点 |缺点|使用场景|
|------|:----:|:----:|:----:|
|Bundle|简单易用|只能传输Bundle支持的数据类型|四大组件间的进程通信|
|文件共享|简单易用|不适合高并发场景，并且无法做到进程间的即时通讯|无并发访问情形，交换简单的数据，实时性不高|
|AIDL|功能强大，支持一对多并发通信，实时通信|使用复杂，需要处理好线程同步|一对多通信且有RPC需求|
|Messenger|功能一般，支持一对多串行通信，实时通信|不能很好处理高并发情形，不支持RPC，数据通过Message进行传输（只能传输Bundle支持的数据类型）|低并发的一对多即时通讯，无RPC需求，或者无需返回结果|
|ContentProvider|在数据源访问方面功能强大，支持一对多并发数据共享，可以通过Call方法扩展其他操作|可以理解为受约束的AIDL，主要提供数据源的CRUD操作|一对多的进程数据共享|
|Socket|功能强大，可以通过网络传输字节流，支持一对多实时通信|实现复杂，不支持直接的RPC|网络数据交换|


## 五、AIDL 的简单使用

只有允许不同应用的客户端用 IPC 方式访问服务，并且想要在服务中处理多线程时，才有必要使用 AIDL。 如果您不需要执行跨越不同应用的并发 IPC，就应该通过实现一个 Binder 创建接口；或者，如果您想执行 IPC，但根本不需要处理多线程，则使用 Messenger 类来实现接口。

使用 AIDL 创建绑定服务的基本步骤如下：

1. 创建 .aidl 文件
在android studio 中 ，可以直接创建 AIDL ，自动创建相关的 aidl 包，这里创建 `IAddAidlInterface.aidl` 文件，具体内容如下：

 
 ```
 // IAddAidlInterface.aidl
 package cn.imtianx.ipcdemo;
 interface IAddAidlInterface {
 //计算两个数的和
 int add(int num1 ,int num2);
 }
 ```
 编译后会自动生成相应的 java 类，这里是在 `build/generated/source/aidl/debug/包名/IAddAidlInterface.java` ,它包含一个内部类：Stub,继承自 `Binder`,实现了我们定义的 AIDL 接口，IAddAidlInterface，是用于定义服务的 RPC 接口。

2. 实现接口
  
 ```
  private IBinder mIBinder = new IAddAidlInterface.Stub(){
       @Override
       public int add(int num1, int num2) throws RemoteException {
        return num1+num2;
       }
   };
 ```

3. 向客户端公开接口
 自定义服务，便于客户端调用。

 ```
 public class IAddService extends Service {
        public IAddService() {
        }
    
        @Override
        public IBinder onBind(Intent intent) {
            // TODO: Return the communication channel to the service.
            return mIBinder;
        }
        private IBinder mIBinder = new IAddAidlInterface.Stub(){
            @Override
            public int add(int num1, int num2) throws RemoteException {
                return num1+num2;
            }
        };
}
 ```

 具体的调用(部分代码)：
 
 ```
 private IAddAidlInterface mIAddAidlInterface;
    private ServiceConnection mConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            //获取远程服务对象
            mIAddAidlInterface = IAddAidlInterface.Stub.asInterface(service);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mIAddAidlInterface = null;
        }
    };
    
    //绑定服务
    Intent intent = new Intent(AIDLActivity.this,IAddService.class);
    intent.setAction(IAddService.class.getName());
    bindService(intent,mConnection, Context.BIND_AUTO_CREATE);
    
    //调用远程服务方法
    int result  = mIAddAidlInterface.add(num1,num2);
     
    //解绑服务
    @Override
    protected void onDestroy() {
        super.onDestroy();
        unbindService(mConnection);
    }
 ```
 
 上述是一个简单的 AIDL 的使用，通过调用远程服务获取 计算结果。
 
接下来，分析下as 建立aidl文件编译后自动生成的java 类：
 
```
package cn.imtianx.ipcdemo;
public interface IAddAidlInterface extends android.os.IInterface
{
    public static abstract class Stub extends android.os.Binder implements cn.imtianx.ipcdemo.IAddAidlInterface
    {
        //binder 的唯一标示，一般是binder的类名
        private static final java.lang.String DESCRIPTOR = "cn.imtianx.ipcdemo.IAddAidlInterface";
        /** Construct the stub at attach it to the interface. */
        public Stub()
        {
            this.attachInterface (this, DESCRIPTOR);
        }

        /**
         * 用于将服务器端的binder 转换成客户端所需要的AIDL 的接口类型
         * @param obj
         * @return 如果客户端和服务器端在同一进程，则返回服务端的stub对象，否则返回 Stub.proxy对象
        */
        public static cn.imtianx.ipcdemo.IAddAidlInterface asInterface (android.os.IBinder obj)
        {
            if ( (obj == null) )
            {
                return null;
            }
            android.os.IInterface iin = obj.queryLocalInterface (DESCRIPTOR);
            if ( ( (iin != null) && (iin instanceof cn.imtianx.ipcdemo.IAddAidlInterface) ) )
            {
                return ( (cn.imtianx.ipcdemo.IAddAidlInterface) iin);
            }
            return new cn.imtianx.ipcdemo.IAddAidlInterface.Stub.Proxy (obj);
        }
        /**
         * 返回当前binder对象
         * @return
         */
        @Override public android.os.IBinder asBinder()
        {
            return this;
        }
        /**
        * 运行在服务端的Binder线程池中
        * @param code 确定请求的方法
        * @param data 获取目标方法所需参数
        * @param reply 写入返回值
        * @param flags
        * @return 若返回false，则为失败，可以此做权限验证
        * @throws android.os.RemoteException
        */
        @Override public boolean onTransact (int code, android.os.Parcel data, android.os.Parcel reply, int flags) throws android.os.RemoteException
        {
            switch (code)
            {
            case INTERFACE_TRANSACTION:
            {
                reply.writeString (DESCRIPTOR);
                return true;
            }

            case TRANSACTION_add:
            {
                data.enforceInterface (DESCRIPTOR);
                int _arg0;
                _arg0 = data.readInt();
                int _arg1;
                _arg1 = data.readInt();
                int _result = this.add (_arg0, _arg1);
                reply.writeNoException();
                reply.writeInt (_result);
                return true;
            }
            }
            return super.onTransact (code, data, reply, flags);
        }
        //代理对象
        private static class Proxy implements cn.imtianx.ipcdemo.IAddAidlInterface
        {
            private android.os.IBinder mRemote;
            Proxy (android.os.IBinder remote)
            {
                mRemote = remote;
            }
            @Override public android.os.IBinder asBinder()
            {
                return mRemote;
            }
            public java.lang.String getInterfaceDescriptor()
            {
                return DESCRIPTOR;
            }
            @Override public int add (int num1, int num2) throws android.os.RemoteException
            {
                android.os.Parcel _data = android.os.Parcel.obtain();
                android.os.Parcel _reply = android.os.Parcel.obtain();
                int _result;
                try {
                    _data.writeInterfaceToken (DESCRIPTOR);
                    _data.writeInt (num1);
                    _data.writeInt (num2);
                    mRemote.transact (Stub.TRANSACTION_add, _data, _reply, 0);
                    _reply.readException();
                    _result = _reply.readInt();
                }
                finally {
                    _reply.recycle();
                    _data.recycle();
                }
                return _result;
            }
        }

        /**
        * 方法标示符
        * 格式：TRANSACTION_方法名 = (android.os.IBinder.FIRST_CALL_TRANSACTION + 
        *       i);其中i按方法数自增
        */
        static final int TRANSACTION_add = (android.os.IBinder.FIRST_CALL_TRANSACTION + 0);

    }
    public int add (int num1, int num2) throws android.os.RemoteException;
}

```

更多AIDL 的资料，可参见[官方文档](https://developer.android.google.cn/guide/components/aidl.html#Defining)，对于Socket、ContentProvider等方式，之前接触过，这里不做介绍。


 


