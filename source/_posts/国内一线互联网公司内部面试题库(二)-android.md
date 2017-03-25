---
title: 【转】国内一线互联网公司内部面试题库(二)——android 篇
date: 2016-11-06 16:06:25
categories: [面试]
tags: [android,面试]
---
本文转自：[国内一线互联网公司内部面试题库](https://github.com/imtianx/AndroidInterview-Q-A/blob/master/README-CN.md)
国内一线互联网公司内部面试题库,以下面试题来自于百度、小米、乐视、美团、58、猎豹、360、新浪、搜狐内部题库

熟悉本文中列出的知识点会大大增加通过前两轮技术面试的几率。
下面是 android 部分
<!--more-->

#### **1.数据库的操作类型有哪些，如何导入外部数据库？**

把原数据库包括在项目源码的 res/raw 

android系统下数据库应该存放在 /data/data/com.*.*（package name）/ 目录下，所以我们需要做的是把已有的数据库传入那个目录下.操作方法是用FileInputStream读取原数据库，再用FileOutputStream把读取到的东西写入到那个目录.

#### **2.是否使用过本地广播，和全局广播有什么差别？**

因广播数据在本应用范围内传播，不用担心隐私数据泄露的问题。
不用担心别的应用伪造广播，造成安全隐患。
相比在系统内发送全局广播，它更高效。

#### **3.是否使用过intentService，作用是什么，AIDL解决了什么问题？**(小米)


生成一个默认的且与主线程互相独立的工作者线程来执行所有传送至onStartCommand() 方法的Intetnt。

生成一个工作队列来传送Intent对象给你的onHandleIntent()方法，同一时刻只传送一个Intent对象，这样一来，你就不必担心多线程的问题。在所有的请求(Intent)都被执行完以后会自动停止服务，所以，你不需要自己去调用stopSelf()方法来停止。

该服务提供了一个onBind()方法的默认实现，它返回null

提供了一个onStartCommand()方法的默认实现，它将Intent先传送至工作队列，然后从工作队列中每次取出一个传送至onHandleIntent()方法，在该方法中对Intent对相应的处理。

AIDL (Android Interface Definition Language) 是一种IDL 语言，用于生成可以在Android设备上两个进程之间进行进程间通信(interprocess communication, IPC)的代码。如果在一个进程中（例如Activity）要调用另一个进程中（例如Service）对象的操作，就可以使用AIDL生成可序列化的参数。
AIDL IPC机制是面向接口的，像COM或Corba一样，但是更加轻量级。它是使用代理类在客户端和实现端传递数据。

#### **4.Activity、Window、View三者的差别，fragment的特点？**（360）

Activity像一个工匠（控制单元），Window像窗户（承载模型），View像窗花（显示视图）
LayoutInflater像剪刀，Xml配置像窗花图纸。

1. 在Activity中调用attach，创建了一个Window
2. 创建的window是其子类PhoneWindow，在attach中创建PhoneWindow
3. 在Activity中调用setContentView(R.layout.xxx)
4. 其中实际上是调用的getWindow().setContentView()
5. 调用PhoneWindow中的setContentView方法
6. 创建ParentView：作为ViewGroup的子类，实际是创建的DecorView(作为FramLayout的子类）
7. 将指定的R.layout.xxx进行填充通过布局填充器进行填充【其中的parent指的就是DecorView】
8. 调用到ViewGroup
9. 调用ViewGroup的removeAllView()，先将所有的view移除掉
10. 添加新的view：addView()

**fragment 特点**

* Fragment可以作为Activity界面的一部分组成出现；
* 可以在一个Activity中同时出现多个Fragment，并且一个Fragment也可以在多个Activity中使用；
* 在Activity运行过程中，可以添加、移除或者替换Fragment；
* Fragment可以响应自己的输入事件，并且有自己的生命周期，它们的生命周期会受宿主Activity的生命周期影响。

#### **5.描述一次网络请求的流程**（新浪）

![](/img/article_img/2016/http.png)

#### **6.Handler、Thread和HandlerThread的差别**（小米）

http://blog.csdn.net/guolin_blog/article/details/9991569

http://droidyue.com/blog/2015/11/08/make-use-of-handlerthread/

从Android中Thread（java.lang.Thread -> java.lang.Object）描述可以看出，Android的Thread没有对Java的Thread做任何封装，但是Android提供了一个继承自Thread的类HandlerThread（android.os.HandlerThread -> java.lang.Thread），这个类对Java的Thread做了很多便利Android系统的封装。

android.os.Handler可以通过Looper对象实例化，并运行于另外的线程中，Android提供了让Handler运行于其它线程的线程实现，也是就HandlerThread。HandlerThread对象start后可以获得其Looper对象，并且使用这个Looper对象实例Handler。

#### **7.低版本SDK实现高版本api**（小米）

自己实现或@TargetApi annotation

#### **8.Ubuntu编译安卓系统**（百度）

1. 进入源码根目录
2. . build/envsetup.sh
3. lunch
4. full(编译全部)
5. userdebug(选择编译版本)
6. make -j8(开启8个线程编译)

#### **9.launch mode应用场景**（百度、小米、乐视）

standard，创建一个新的Activity。

singleTop，栈顶不是该类型的Activity，创建一个新的Activity。否则，onNewIntent。

singleTask，回退栈中没有该类型的Activity，创建Activity，否则，onNewIntent+ClearTop。

注意:

 1. 设置了"singleTask"启动模式的Activity，它在启动的时候，会先在系统中查找属性值affinity等于它的属性值taskAffinity的Task存在； 如果存在这样的Task，它就会在这个Task中启动，否则就会在新的任务栈中启动。因此， 如果我们想要设置了"singleTask"启动模式的Activity在新的任务中启动，就要为它设置一个独立的taskAffinity属性值。
 2. 如果设置了"singleTask"启动模式的Activity不是在新的任务中启动时，它会在已有的任务中查看是否已经存在相应的Activity实例， 如果存在，就会把位于这个Activity实例上面的Activity全部结束掉，即最终这个Activity 实例会位于任务的Stack顶端中。
 3. 在一个任务栈中只有一个”singleTask”启动模式的Activity存在。他的上面可以有其他的Activity。这点与singleInstance是有区别的。

singleInstance，回退栈中，只有这一个Activity，没有其他Activity。

singleTop适合接收通知启动的内容显示页面。

例如，某个新闻客户端的新闻内容页面，如果收到10个新闻推送，每次都打开一个新闻内容页面是很烦人的。

singleTask适合作为程序入口点。

例如浏览器的主界面。不管从多少个应用启动浏览器，只会启动主界面一次，其余情况都会走onNewIntent，并且会清空主界面上面的其他页面。

singleInstance应用场景：

闹铃的响铃界面。 你以前设置了一个闹铃：上午6点。在上午5点58分，你启动了闹铃设置界面，并按 Home 键回桌面；在上午5点59分时，你在微信和朋友聊天；在6点时，闹铃响了，并且弹出了一个对话框形式的 Activity(名为 AlarmAlertActivity) 提示你到6点了(这个 Activity 就是以 SingleInstance 加载模式打开的)，你按返回键，回到的是微信的聊天界面，这是因为 AlarmAlertActivity 所在的 Task 的栈只有他一个元素， 因此退出之后这个 Task 的栈空了。如果是以 SingleTask 打开 AlarmAlertActivity，那么当闹铃响了的时候，按返回键应该进入闹铃设置界面。

#### **10.touch 事件传递流程**（小米）

http://hanhailong.com/2015/09/24/Android-%E4%B8%89%E5%BC%A0%E5%9B%BE%E6%90%9E%E5%AE%9ATouch%E4%BA%8B%E4%BB%B6%E4%BC%A0%E9%80%92%E6%9C%BA%E5%88%B6/

#### **11.view绘制流程**（百度）

http://www.codekk.com/blogs/detail/54cfab086c4761e5001b253f

#### **12.多线程**（360）

* Activity.runOnUiThread(Runnable)
* View.post(Runnable),View.postDelay(Runnable,long)
* Handler
* AsyncTask

#### **13.线程同步**（百度）

http://www.itzhai.com/java-based-notebook-thread-synchronization-problem-solving-synchronization-problems-synchronized-block-synchronized-methods.html#read-more

http://www.juwends.com/tech/android/android-inter-thread-comm.html

单例

```
public class Singleton{
private volatile static Singleton mSingleton;
private Singleton(){
}
public static Singleton getInstance(){
  if(mSingleton == null){\\A
    synchronized(Singleton.class){\\C
     if(mSingleton == null)
      mSingleton = new Singleton();\\B
      }
    }
    return mSingleton;
  }
}
```
#### **14.什么情况导致内存泄漏**（美团）

1.资源对象没关闭造成的内存泄漏

描述：
资源性对象比如(Cursor，File文件等)往往都用了一些缓冲，我们在不使用的时候，应该及时关闭它们，以便它们的缓冲及时回收内存。它们的缓冲不仅存在于 java虚拟机内，还存在于java虚拟机外。如果我们仅仅是把它的引用设置为null,而不关闭它们，往往会造成内存泄漏。因为有些资源性对象，比如 SQLiteCursor(在析构函数finalize(),如果我们没有关闭它，它自己会调close()关闭)，如果我们没有关闭它，系统在回收它时也会关闭它，但是这样的效率太低了。因此对于资源性对象在不使用的时候，应该调用它的close()函数，将其关闭掉，然后才置为null.在我们的程序退出时一定要确保我们的资源性对象已经关闭。
程序中经常会进行查询数据库的操作，但是经常会有使用完毕Cursor后没有关闭的情况。如果我们的查询结果集比较小，对内存的消耗不容易被发现，只有在常时间大量操作的情况下才会复现内存问题，这样就会给以后的测试和问题排查带来困难和风险。

2.构造Adapter时，没有使用缓存的convertView

描述：
以构造ListView的BaseAdapter为例，在BaseAdapter中提供了方法：
public View getView(int position, ViewconvertView, ViewGroup parent)
来向ListView提供每一个item所需要的view对象。初始时ListView会从BaseAdapter中根据当前的屏幕布局实例化一定数量的 view对象，同时ListView会将这些view对象缓存起来。当向上滚动ListView时，原先位于最上面的list item的view对象会被回收，然后被用来构造新出现的最下面的list item。这个构造过程就是由getView()方法完成的，getView()的第二个形参View convertView就是被缓存起来的list item的view对象(初始化时缓存中没有view对象则convertView是null)。由此可以看出，如果我们不去使用 convertView，而是每次都在getView()中重新实例化一个View对象的话，即浪费资源也浪费时间，也会使得内存占用越来越大。 ListView回收list item的view对象的过程可以查看:
android.widget.AbsListView.java --> voidaddScrapView(View scrap) 方法。
示例代码：

```
public View getView(int position, ViewconvertView, ViewGroup parent) {
View view = new Xxx(...); 
... ... 
return view; 
} 
```

修正示例代码：

```
public View getView(int position, ViewconvertView, ViewGroup parent) {
View view = null; 
if (convertView != null) { 
view = convertView; 
populate(view, getItem(position)); 
... 
} else { 
view = new Xxx(...); 
... 
} 
return view; 
} 
```

3.Bitmap对象不在使用时调用recycle()释放内存

描述：
有时我们会手工的操作Bitmap对象，如果一个Bitmap对象比较占内存，当它不在被使用的时候，可以调用Bitmap.recycle()方法回收此对象的像素所占用的内存，但这不是必须的，视情况而定。可以看一下代码中的注释：
```
/** 
Free up the memory associated with thisbitmap's pixels, and mark the bitmap as "dead", meaning itwill throw an exception if getPixels() or setPixels() is called, and will drawnothing. This operation cannot be reversed, so it should only be called ifyou are sure there are no further uses for the bitmap. This is anadvanced call, and normally need not be called, since the normal GCprocess will free up this memory when there are no more references to thisbitmap. 
*/ 
```

4.试着使用关于application的context来替代和activity相关的context

这是一个很隐晦的内存泄漏的情况。有一种简单的方法来避免context相关的内存泄漏。最显著地一个是避免context逃出他自己的范围之外。使用Application context。这个context的生存周期和你的应用的生存周期一样长，而不是取决于activity的生存周期。如果你想保持一个长期生存的对象，并且这个对象需要一个context,记得使用application对象。你可以通过调用 Context.getApplicationContext() or Activity.getApplication()来获得。更多的请看这篇文章如何避免
Android内存泄漏。

5.注册没取消造成的内存泄漏

一些Android程序可能引用我们的Anroid程序的对象(比如注册机制)。即使我们的Android程序已经结束了，但是别的引用程序仍然还有对我们的Android程序的某个对象的引用，泄漏的内存依然不能被垃圾回收。调用registerReceiver后未调用unregisterReceiver。
比如:假设我们希望在锁屏界面(LockScreen)中，监听系统中的电话服务以获取一些信息(如信号强度等)，则可以在LockScreen中定义一个 PhoneStateListener的对象，同时将它注册到TelephonyManager服务中。对于LockScreen对象，当需要显示锁屏界面的时候就会创建一个LockScreen对象，而当锁屏界面消失的时候LockScreen对象就会被释放掉。
但是如果在释放 LockScreen对象的时候忘记取消我们之前注册的PhoneStateListener对象，则会导致LockScreen无法被垃圾回收。如果不断的使锁屏界面显示和消失，则最终会由于大量的LockScreen对象没有办法被回收而引起OutOfMemory,使得system_process 进程挂掉。
虽然有些系统程序，它本身好像是可以自动取消注册的(当然不及时)，但是我们还是应该在我们的程序中明确的取消注册，程序结束时应该把所有的注册都取消掉。

6.集合中对象没清理造成的内存泄漏

我们通常把一些对象的引用加入到了集合中，当我们不需要该对象时，并没有把它的引用从集合中清理掉，这样这个集合就会越来越大。如果这个集合是static的话，那情况就更严重了。

#### **15.ANR定位和修正**

如果开发机器上出现问题，我们可以通过查看/data/anr/traces.txt即可，最新的ANR信息在最开始部分。

* 主线程被IO操作（从4.0之后网络IO不允许在主线程中）阻塞。
* 主线程中存在耗时的计算
* 主线程中错误的操作，比如Thread.wait或者Thread.sleep等
Android系统会监控程序的响应状况，一旦出现下面两种情况，则弹出ANR对话框
* 应用在5秒内未响应用户的输入事件（如按键或者触摸）
* BroadcastReceiver未在10秒内完成相关的处理
* Service在特定的时间内无法处理完成 20秒

* 使用AsyncTask处理耗时IO操作。
* 使用Thread或者HandlerThread时，调用Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)设置优先级，否则仍然会降低程序响应，因为默认Thread的优先级和主线程相同。
* 使用Handler处理工作线程结果，而不是使用Thread.wait()或者Thread.sleep()来阻塞主线程。
* Activity的onCreate和onResume回调中尽量避免耗时的代码
* BroadcastReceiver中onReceive代码也要尽量减少耗时，建议使用IntentService处理。


#### **16.什么情况导致oom**（乐视、美团）

http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2015/0920/3478.html

1）使用更加轻量的数据结构
2）Android里面使用Enum
3）Bitmap对象的内存占用
4）更大的图片
5）onDraw方法里面执行对象的创建
6）StringBuilder

#### **17.Android Service与Activity之间通信的几种方式**

* 通过Binder对象
* 通过broadcast(广播)的形式

#### **18.Android各个版本API的区别**

http://blog.csdn.net/lijun952048910/article/details/7980562

#### **19. Android代码中实现WAP方式联网**（360）

http://blog.csdn.net/asce1885/article/details/7844159

#### **20.如何保证service在后台不被kill**

一、onStartCommand方法，返回START_STICKY

1. START_STICKY
在运行onStartCommand后service进程被kill后，那将保留在开始状态，但是不保留那些传入的intent。不久后service就会再次尝试重新创建，因为保留在开始状态，在创建     service后将保证调用onstartCommand。如果没有传递任何开始命令给service，那将获取到null的intent。

2. START_NOT_STICKY
在运行onStartCommand后service进程被kill后，并且没有新的intent传递给它。Service将移出开始状态，并且直到新的明显的方法（startService）调用才重新创建。因为如果没有传递任何未决定的intent那么service是不会启动，也就是期间onstartCommand不会接收到任何null的intent。

3. START_REDELIVER_INTENT
在运行onStartCommand后service进程被kill后，系统将会再次启动service，并传入最后一个intent给onstartCommand。直到调用stopSelf(int)才停止传递intent。如果在被kill后还有未处理好的intent，那被kill后服务还是会自动启动。因此onstartCommand不会接收到任何null的intent。

二、提升service优先级

在AndroidManifest.xml文件中对于intent-filter可以通过android:priority = "1000"这个属性设置最高优先级，1000是最高值，如果数字越小则优先级越低，同时适用于广播。

三、提升service进程优先级

Android中的进程是托管的，当系统进程空间紧张的时候，会依照优先级自动进行进程的回收。Android将进程分为6个等级,它们按优先级顺序由高到低依次是:

1. 前台进程( FOREGROUND_APP)
2. 可视进程(VISIBLE_APP )
3. 次要服务进程(SECONDARY_SERVER )
4. 后台进程 (HIDDEN_APP)
5. 内容供应节点(CONTENT_PROVIDER)
6. 空进程(EMPTY_APP)

当service运行在低内存的环境时，将会kill掉一些存在的进程。因此进程的优先级将会很重要，可以使用startForeground 将service放到前台状态。这样在低内存时被kill的几率会低一些。

四、onDestroy方法里重启service

service +broadcast  方式，就是当service走ondestory的时候，发送一个自定义的广播，当收到广播的时候，重新启动service；

五、Application加上Persistent属性

六、监听系统广播判断Service状态

通过系统的一些广播，比如：手机重启、界面唤醒、应用状态改变等等监听并捕获到，然后判断我们的Service是否还存活，别忘记加权限啊。

#### **21.Requestlayout，onlayout，onDraw，DrawChild区别与联系**（猎豹）

requestLayout()方法 ：会导致调用measure()过程 和 layout()过程 。
说明：只是对View树重新布局layout过程包括measure()和layout()过程，不会调用draw()过程，但不会重新绘制
任何视图包括该调用者本身。

onLayout()方法(如果该View是ViewGroup对象，需要实现该方法，对每个子视图进行布局)

调用onDraw()方法绘制视图本身   (每个View都需要重载该方法，ViewGroup不需要实现该方法)

drawChild()去重新回调每个子视图的draw()方法

#### **22.invalidate()和postInvalidate() 的区别及使用**（百度）

http://blog.csdn.net/mars2639/article/details/6650876

#### **23.Android动画框架实现原理**

Animation框架定义了透明度，旋转，缩放和位移几种常见的动画，而且控制的是整个View，实现原理是每次绘制视图时View所在的ViewGroup中的drawChild函数获取该View的Animation的Transformation值，然后调用canvas.concat(transformToApply.getMatrix())，通过矩阵运算完成动画帧，如果动画没有完成，继续调用invalidate()函数，启动下次绘制来驱动动画，动画过程中的帧之间间隙时间是绘制函数所消耗的时间，可能会导致动画消耗比较多的CPU资源，最重要的是，动画改变的只是显示，并不能相应事件。

#### **24.Android为每个应用程序分配的内存大小是多少？**（美团）

android程序内存一般限制在16M，也有的是24M

#### **25.Android View刷新机制**（百度、美团）

由ViewRoot对象的performTraversals()方法调用draw()方法发起绘制该View树，值得注意的是每次发起绘图时，并不会重新绘制每个View树的视图，而只会重新绘制那些“需要重绘”的视图，View类内部变量包含了一个标志位DRAWN，当该视图需要重绘时，就会为该View添加该标志位。

调用流程 ：

mView.draw()开始绘制，draw()方法实现的功能如下：

1. 绘制该View的背景
2. 为显示渐变框做一些准备操作(见5，大多数情况下，不需要改渐变框)          
3. 调用onDraw()方法绘制视图本身   (每个View都需要重载该方法，ViewGroup不需要实现该方法)
4. 调用dispatchDraw ()方法绘制子视图(如果该View类型不为ViewGroup，即不包含子视图，不需要重载该方法)值得说明的是，ViewGroup类已经为我们重写了dispatchDraw ()的功能实现，应用程序一般不需要重写该方法，但可以重载父类函数实现具体的功能。

#### **26.LinearLayout对比RelativeLayout**（百度）

1. RelativeLayout会让子View调用2次onMeasure，LinearLayout 在有weight时，也会调用子View2次onMeasure
2. RelativeLayout的子View如果高度和RelativeLayout不同，则会引发效率问题，当子View很复杂时，这个问题会更加严重。如果可以，尽量使用padding代替margin。
3. 在不影响层级深度的情况下,使用LinearLayout和FrameLayout而不是RelativeLayout。

最后再思考一下文章开头那个矛盾的问题，为什么Google给开发者默认新建了个RelativeLayout，而自己却在DecorView中用了个LinearLayout。因为DecorView的层级深度是已知而且固定的，上面一个标题栏，下面一个内容栏。采用RelativeLayout并不会降低层级深度，所以此时在根节点上用LinearLayout是效率最高的。而之所以给开发者默认新建了个RelativeLayout是希望开发者能采用尽量少的View层级来表达布局以实现性能最优，因为复杂的View嵌套对性能的影响会更大一些。

#### **27.优化自定义view**（百度、乐视、小米）

为了加速你的view，对于频繁调用的方法，需要尽量减少不必要的代码。先从onDraw开始，需要特别注意不应该在这里做内存分配的事情，因为它会导致GC，从而导致卡顿。在初始化或者动画间隙期间做分配内存的动作。不要在动画正在执行的时候做内存分配的事情。

你还需要尽可能的减少onDraw被调用的次数，大多数时候导致onDraw都是因为调用了invalidate().因此请尽量减少调用invaildate()的次数。如果可能的话，尽量调用含有4个参数的invalidate()方法而不是没有参数的invalidate()。没有参数的invalidate会强制重绘整个view。

另外一个非常耗时的操作是请求layout。任何时候执行requestLayout()，会使得Android UI系统去遍历整个View的层级来计算出每一个view的大小。如果找到有冲突的值，它会需要重新计算好几次。另外需要尽量保持View的层级是扁平化的，这样对提高效率很有帮助。

如果你有一个复杂的UI，你应该考虑写一个自定义的ViewGroup来执行他的layout操作。与内置的view不同，自定义的view可以使得程序仅仅测量这一部分，这避免了遍历整个view的层级结构来计算大小。这个PieChart 例子展示了如何继承ViewGroup作为自定义view的一部分。PieChart 有子views，但是它从来不测量它们。而是根据他自身的layout法则，直接设置它们的大小。

#### **28.ContentProvider**（乐视）

http://blog.csdn.net/coder_pig/article/details/47858489

#### **29.fragment生命周期**

![](/img/article_img/2016/fragment-life.png)

#### **30.volley解析**（美团、乐视）

http://a.codekk.com/detail/Android/grumoon/Volley%20%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90

#### **31.Android Glide源码解析**

http://www.lightskystreet.com/2015/10/12/glide_source_analysis/
http://frodoking.github.io/2015/10/10/android-glide/

#### **32.Android 设计模式**

http://blog.csdn.net/bboyfeiyu/article/details/44563871

#### **33.架构设计**（搜狐）

![](/img/article_img/2016/architucture.png)

http://www.tianmaying.com/tutorial/AndroidMVC

#### **34.Android属性动画特性**（乐视、小米）

如果你的需求中只需要对View进行移动、缩放、旋转和淡入淡出操作，那么补间动画确实已经足够健全了。但是很显然，这些功能是不足以覆盖所有的场景的，一旦我们的需求超出了移动、缩放、旋转和淡入淡出这四种对View的操作，那么补间动画就不能再帮我们忙了，也就是说它在功能和可扩展方面都有相当大的局限性，那么下面我们就来看看补间动画所不能胜任的场景。

注意上面我在介绍补间动画的时候都有使用“对View进行操作”这样的描述，没错，补间动画是只能够作用在View上的。也就是说，我们可以对一个Button、TextView、甚至是LinearLayout、或者其它任何继承自View的组件进行动画操作，但是如果我们想要对一个非View的对象进行动画操作，抱歉，补间动画就帮不上忙了。可能有的朋友会感到不能理解，我怎么会需要对一个非View的对象进行动画操作呢？这里我举一个简单的例子，比如说我们有一个自定义的View，在这个View当中有一个Point对象用于管理坐标，然后在onDraw()方法当中就是根据这个Point对象的坐标值来进行绘制的。也就是说，如果我们可以对Point对象进行动画操作，那么整个自定义View的动画效果就有了。显然，补间动画是不具备这个功能的，这是它的第一个缺陷。

然后补间动画还有一个缺陷，就是它只能够实现移动、缩放、旋转和淡入淡出这四种动画操作，那如果我们希望可以对View的背景色进行动态地改变呢？很遗憾，我们只能靠自己去实现了。说白了，之前的补间动画机制就是使用硬编码的方式来完成的，功能限定死就是这些，基本上没有任何扩展性可言。

最后，补间动画还有一个致命的缺陷，就是它只是改变了View的显示效果而已，而不会真正去改变View的属性。什么意思呢？比如说，现在屏幕的左上角有一个按钮，然后我们通过补间动画将它移动到了屏幕的右下角，现在你可以去尝试点击一下这个按钮，点击事件是绝对不会触发的，因为实际上这个按钮还是停留在屏幕的左上角，只不过补间动画将这个按钮绘制到了屏幕的右下角而已。
