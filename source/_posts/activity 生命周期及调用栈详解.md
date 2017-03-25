---
title: activity 生命周期及调用栈详解
date: 2016-11-08 16:06:25
categories: [android,学习笔记]
tags: [android,Activity,生命周期]
---

`Activity `作为android四大组件之首，是我们是使用最频繁的组件，只有熟练的掌握其生命周期和启动模式，才能使我们在编程中进行合理的控制，在合适的生命周期处理相关的业务，开发出高质量的应用。下面具体的介绍下他的生命周期及启动模式。([android 官方文档-activity](https://developer.android.com/guide/components/activities.html))
<!--more-->
### 一、activity 的四种状态
1. **Active/Running**（活动）
  此时，activity 处于栈顶，可见，与用户进行交互。系统会不惜一切代价保护她的活跃性的，如果需要，会取消栈中靠下的activity来保证它所需要的资源。
2. **Paused**（暂停）
  当activity 失去焦点，被一个新的非全屏的activity 或者透明的activity放置在栈顶时，它会进入该状态。此时，它失去了与用户交互的能力，但所有的状态信息、成员变量都还保持着，只有在系统内存极低的情况下会被回收。
3. **Stopped**（停止）
当一个activity 被完全覆盖，完全不可见时会进入此状态。但在系统内存中仍然保存着所有的状态和成员信息。当需要内存时，将直接回收。
4. **Kill**（销毁）
当activity 被回收或者从来没有创建过，处于此状态。改状态的activity 会从activity栈中移除。
### 二、activity 的生命周期
如下如，展示activity的整个生命周期及其切换过程。
![](/img/article_img/2016/activity生命周期.png)

> 说明：
1. 当一个activity 第一次启动，回调方法如下：**onCreate**->**onStart**->**onResum**.
2. 用户打开新的activity或者切换到桌面，回调方法如下：**onPause**->**onStop**,如果新打开的activity 主题为**透明的**，则不会回调**onStop**。
3. 用户再次回到原activity，毁掉过程如下：**onRestart**->**onStart**->**onResume**。
4. 对于整个生命周期，onCreatehe onDestroy是配对的，他们标志着activity 的创建和销毁，并且只会调用一次；对于activity 是否可见，onStart和onStop是配对的，随着用户的操作或者屏幕的电量和熄灭，会被调用多次，但是该状态下不能与用户进行交互；从activity 是否在前台来说，onResume 和onPause 是配对的，他们也会被回调多次。
5.  当前activity 页面打开新的activity，先执行原activity 的 onPause 方法，然后才会启动新activity 。

### 三、异常情况下的生命周期
1. 资源相关配置改变导致activity销毁并重建
对于横竖屏切换导致的activity异常销毁并重建，其创建过程如下图：
![](/img/article_img/2016/activity异常重建.png)

2. 资源内存不足导致低优先级activity 被杀死
优先级从搞到低课分为如下三种情况：

- 处于前台与用户交互的activity 的优先级最高；
- 可见但非前台activity，如弹出的对话框，导致activity可见但无法与用户进行交互；
- 后台activity（已被暂停的），如执行了onStop方法，优先级最低。

当系统内存不足时，按照上面的优先级杀掉activity所在的进程。

**onSaveInstanceState (Bundle outState)**
当某个activity变得“容易”被系统销毁时，该activity的onSaveInstanceState就会被执行，除非该activity是被用户主动销毁的，具体的有如下几种场景：
1、当用户按下HOME键时。
这是显而易见的，系统不知道你按下HOME后要运行多少其他的程序，自然也不知道activity A是否会被销毁，故系统会调用onSaveInstanceState，让用户有机会保存某些非永久性的数据。以下几种情况的分析都遵循该原则

2、长按HOME键，选择运行其他的程序时。
3、按下电源按键（关闭屏幕显示）时。
4、从activity A中启动一个新的activity时。
5、屏幕方向切换时，例如从竖屏切换到横屏时。（如果不指定configchange属性） 在屏幕切换之前，系统会销毁activity A，在屏幕切换之后系统又会自动地创建activity A，所以onSaveInstanceState一定会被执行

总而言之，onSaveInstanceState的调用遵循一个重要原则，即当系统“未经你许可”时销毁了你的activity，则onSaveInstanceState会被系统调用。

> **注意点**：
1.布局中的每一个View默认实现了onSaveInstanceState()方法，这样的话，这个UI的任何改变都会自动的存储和在activity重新创建的时候自动的恢复。但是这种情况只有在你为这个UI提供了唯一的ID之后才起作用，如果没有提供ID，将不会存储它的状态。
>
2.由于默认的onSaveInstanceState()方法的实现帮助UI存储它的状态，所以如果你需要覆盖这个方法去存储额外的状态信息时，你应该在执行任何代码之前都调用父类的onSaveInstanceState()方法（super.onSaveInstanceState()）。 既然有现成的可用，那么我们到底还要不要自己实现onSaveInstanceState()?这得看情况了，如果你自己的派生类中有变量影响到UI，或你程序的行为，当然就要把这个变量也保存了，那么就需要自己实现，否则就不需要。

> 3.由于onSaveInstanceState()方法调用的不确定性，你应该只使用这个方法去记录activity的瞬间状态（UI的状态）。不应该用这个方法去存储持久化数据。当用户离开这个activity的时候应该在onPause()方法中存储持久化数据（例如应该被存储到数据库中的数据）。

> 4.onSaveInstanceState()如果被调用，这个方法会在onStop()前被触发，但系统并不保证是否在onPause()之前或者之后触发。


**onRestoreInstanceState (Bundle outState)**
至于onRestoreInstanceState方法，需要注意的是，onSaveInstanceState方法和onRestoreInstanceState方法“不一定”是成对的被调用的。

onRestoreInstanceState被调用的前提是，activity A“确实”被系统销毁了，而如果仅仅是停留在有这种可能性的情况下，则该方法不会被调用，例如，当正在显示activity A的时候，用户按下HOME键回到主界面，然后用户紧接着又返回到activity A，这种情况下activity A一般不会因为内存的原因被系统销毁，故activity A的onRestoreInstanceState方法不会被执行。

另外，onRestoreInstanceState的bundle参数也会传递到onCreate方法中，你也可以选择在onCreate方法中做数据还原。 还有onRestoreInstanceState在onstart之后执行。 至于这两个函数的使用，给出示范代码（留意自定义代码在调用super的前或后）：
```
@Override
public void onSaveInstanceState(Bundle savedInstanceState) {
        savedInstanceState.putBoolean("MyBoolean", true);
        savedInstanceState.putDouble("myDouble", 1.9);
        savedInstanceState.putInt("MyInt", 1);
        savedInstanceState.putString("MyString", "Welcome back to Android");
        // etc.
        super.onSaveInstanceState(savedInstanceState);
}

@Override
public void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);

        boolean myBoolean = savedInstanceState.getBoolean("MyBoolean");
        double myDouble = savedInstanceState.getDouble("myDouble");
        int myInt = savedInstanceState.getInt("MyInt");
        String myString = savedInstanceState.getString("MyString");
}

```

**onSaveInstanceState 方法只适用于保存保存一些临时性的状态，而 onPause 方法适用于数据的持久化保存。**


### 四、activity 启动模式
**任务栈**是一种后进先出的结构。位于栈顶的Activity处于焦点状态,当按下back按钮的时候,栈内的Activity会一个一个的出栈,并且调用其onDestory()方法。如果栈内没有Activity,那么系统就会回收这个栈,每个APP默认只有一个栈,以APP的包名来命名。

在AndroidManifest中可以给声明的activity通过**android:launchMode="standard|singleInstance|singleTask|singleTop"**属性指定设置如下四种启动的模式：
**standard**
默认的启动方式，每次都会创建新的实例，覆盖在原来的activity之上，可以被同时添加到多个任务栈中，并且每一个任务中可以有多个实例。（只有在该模式的activity 才可以使用startActivityForResult方法）
**singleTop**
若设置为该模式，在启动activity时，系统会判断当前栈顶的activity是否是要启动的activity，如果是则直接引用这个实例不创建新的，否则创建新的实例。
**singleTask**
与singleTop 类似，它是检测整个activity栈中是否存在当前需要启动的activity。如果存在，则将该activity置于栈顶，并销毁在它之上的activity（注：这是在一个app中）。
如果其他程序以singleTask模式来启动这个activity，将创建一个新的任务栈，该模式有**clearTop**效果。
**singleInstance**
该模式的使用和浏览器的工作原理类似。在多个程序访问浏览器时，如果浏览器没有打开，则打开，否则再当前打开的浏览器中访问。声明为这种模式的activity，会出现在一个新的任务栈中，而且该任务栈只有这一个activity。

### 五、Fragment和activity的生命周期关系
如下图：
![](/img/article_img/2016/fragment_and_activity_lifecycle.jpg)

谷歌官方 fragment 的生命周期如下图：
![](/img/article_img/2016/fragment-life.png)

> 参考文献：
《Android 开发艺术探索》
《Android 群英传》
《深入解析 Android虚拟机》
