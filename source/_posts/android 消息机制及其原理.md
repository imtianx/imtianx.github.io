---
title: android 消息机制及其原理
date: 2016-12-27 16:06:25
categories: [android,学习笔记]
tags: [消息机制,Handler]
---



> 读书笔记： 《Android 开发艺术探索》 ——第十章：android 消息机制

对于 android 中的消息机制，主要是指 **Handler** 的运行机制。在我们平时的开发中 ，对它并不陌生。由于android 是 单线程（UI线程）机制，对于一些耗时操作会在子线程中进行，如文件读取等.
<!--more-->
往往在操作完成后会有 UI 的更新，由于 android 中不允许在子线程中更新ui,所以我们 常常用 Handler 来更新UI ，但它的功能不仅仅如此。

## 一、消息机制概述

`Handler` 的运行 需要底层的 **MessageQueue** 和 **Looper** 支撑。`MessageQueue` 是指消息队列，在他内部存储了一组消息，以队列的形式对外提供增删。虽名为队列，但是其内部的实现是采用 单链表。`Looper` 主要是用于消息循环，他内部通过无线循环的方式，查看是否有消息，如果有就处理，否则阻塞等待着。 在 Looper 中 利用 `ThreadLocal` 进行存储数据，它可以保证各个线程中互不干扰的存储和提供数据。
如果 使用 Handler 就必须为线程创建 Looper。我们能够在 Activity 只用它，主要是应为在 UI 线程( ActivityThread ) 创建是会初始化 looper。

android 系统不允许 在子线程中访问UI ，主要是 很多控件时线程不安全的，如果多线程并发访问会出现不可预期的效果；同时由于 锁机制会让 UI 访问逻辑变复杂，并且会阻塞某些线程从而降低 UI 访问效率，并没有对 UI 线程进行加锁 操作。

如下是 Handler 的 工作过程：

![](/img/article_img/2016/Handler 消息机制.png)

> 说明：首先 Handle 通过 `sendMessage()` 等方法发送一个消息，最终会调用 MessageQueue 的 **enqueueMessage** 方法 将消息添加到消息队列中；而 Looper 的 loop方法发现新消息后，从队列中取出消息，最后将其转发到 Handle 中，最终在 handleMessage 进行处理。而Looper 是运行在创建handler 的线程中，这样将Handler 中的业务逻辑切换到 穿件 Handler 的线程中去了。


## 二、消息机制分析

### 2.1 ThreadLocal 的工作原理

ThreadLocal 主要是线程内部的数据存储类，他可以在指定的线程中存储数据，然后只有指定的线程可以获取。，而其他线程则无法获取。这里使用它 可以方便的实现 Looper 在线程中的存取，此外，他还可以在复杂的逻辑下进行对象的传递，如监听器的传递。

由于 api23 前后，ThreadLocal 的内部实现不同，这里不具体介绍。


### 2.2  MessageQueue 的工作原理

在消息队列 MessageQueue 中主要包括两个操作：插入和读取，在读取的同时伴随有删除。 插入和读取分别对应于 `enqueueMessage` 和 `next`。 enqueueMessage 是往队列中插入 一条数据，采用非的是单链表的插入操作，其内部采用了锁机制，而 next 是一个无限循环方法，若无消息，那么它将阻塞者，若有消息，则返回该消息并将其从消息队列中移除。

### 2.3 Looper 的工作原理

Looper 是消息循环的角色，不停的从 MessageQueue 中取消息，若存在则立即处理，否则阻塞。在 Looper 的构造方法中会创建一个MessageQueue对象。
Handle  的工作需要 looper ，如果没有回报错，可以用 `prepare` 方法创建Looper：
```
// 创建looper
Looper.prepare();
//....
//开启循环
Looper.loop();
```
才外，还提供了 `prepareMainLooper` 方法为主线程创建Looper。对于退出循环，则提供了 `quit` 和 `quitSafely` 方法，前者是直接退出，后者则是设置个退出标记，等消息处理完后再退出。
通常在子线程中创建的looper ,在执行完后应该退出，当执行退出后，次线程会立即终止，若handler 再次发送消息，则会返回 false。
由于在 Looper 的 loop 方法中调用用了 MessageQueue 的 next方法，而next 方法是个阻塞的，导致loop阻塞。如下loop方法：

```
public static void loop()
{
    final Looper me = myLooper();
    if (me == null)
    {
        throw new RuntimeException ("No Looper; Looper.prepare() wasn't called on this thread.");
    }
    final MessageQueue queue = me.mQueue;

    // Make sure the identity of this thread is that of the local process,
    // and keep track of what that identity token actually is.
    Binder.clearCallingIdentity();
    final long ident = Binder.clearCallingIdentity();

    for (;;)
    {
        Message msg = queue.next(); // might block
        if (msg == null)
        {
            // No message indicates that the message queue is quitting.
            return;
        }

        // This must be in a local variable, in case a UI event sets the logger
        final Printer logging = me.mLogging;
        //...

        final long traceTag = me.mTraceTag;
        if (traceTag != 0 && Trace.isTagEnabled (traceTag) )
        {
            Trace.traceBegin (traceTag, msg.target.getTraceName (msg) );
        }
        try
        {
            msg.target.dispatchMessage (msg);
        } finally
        {
            if (traceTag != 0)
            {
                Trace.traceEnd (traceTag);
            }
        }

        //...
        // Make sure that during the course of dispatching the
        // identity of the thread wasn't corrupted.
        final long newIdent = Binder.clearCallingIdentity();
        //...

        msg.recycleUnchecked();
    }
}
```

> 注意 `msg.target.dispatchMessage (msg);`一句，msg是一个从MessageQueue 中取出的Message对象，而 target 则是  Message 中的一个 Handler 类型的 成员变量，这样使得 loop方法将消息队列中的消息分发给 Handler 进行处理。

### 2.4 Handler 的工作原理

handler 主要包括消息的发送和接受，主要包括一系列的post和send方法实现的,而post最终是通过 send实现的。如下各个方法：

```
 public final boolean sendMessage(Message msg)
{
    return sendMessageDelayed(msg, 0);
}
 public final boolean sendEmptyMessage(int what)
{
    return sendEmptyMessageDelayed(what, 0);
}
 public final boolean sendEmptyMessageDelayed(int what, long delayMillis) {
    Message msg = Message.obtain();
    msg.what = what;
    return sendMessageDelayed(msg, delayMillis);
}
 public final boolean sendEmptyMessageAtTime(int what, long uptimeMillis) {
    Message msg = Message.obtain();
    msg.what = what;
    return sendMessageAtTime(msg, uptimeMillis);
}
 public final boolean sendMessageDelayed(Message msg, long delayMillis)
{
    if (delayMillis < 0) {
        delayMillis = 0;
    }
    return sendMessageAtTime(msg, SystemClock.uptimeMillis() + delayMillis);
}
 public boolean sendMessageAtTime(Message msg, long uptimeMillis) {
        MessageQueue queue = mQueue;
        if (queue == null) {
            RuntimeException e = new RuntimeException(
                    this + " sendMessageAtTime() called with no mQueue");
            Log.w("Looper", e.getMessage(), e);
            return false;
        }
        return enqueueMessage(queue, msg, uptimeMillis);
    }
      private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
        msg.target = this;
        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }
```
通过上面的各个方法，最终是往调用了 **enqueueMessage 方法 往 MessageQueue 中插入一条消息**。在Looper 中 调用了 MessageQueue 的next 方法，取出一条消息，通过 dispatchMessage 方法将消息分发给 Handler 处理,如下其具体实现：

```
public void dispatchMessage(Message msg) {
    if (msg.callback != null) {
        handleCallback(msg);
    } else {
        if (mCallback != null) {
            if (mCallback.handleMessage(msg)) {
                return;
            }
        }
        handleMessage(msg);
    }
}
```
这里首先检查 callback 是否为null,不为空就调用 handleCallback 处理，它是一个 Runnable对象；其次检查 mCallback　是否为null ，mCallback　是一个Callback类型的接口，内部只有一个方法：
```
public interface Callback {
    public boolean handleMessage(Message msg);
}
```
这里的 Callback 可以用来创建 Handle 对象，常见的创建 Handler 是重写 handleMessage 方法。
如下 Handler 的消息处理流程：
![](/img/article_img/2016/Handler消息处理流程.png)


## 三、主线程消息循环

主线程即ActivityThread ，其注入口方法为 main,在该方法中，通过 `Looper.prepareMainLooper();`  创建Looper，最后通过 `Looper.loop();`开启消息循环。


```
public static void main (String[] args)
{

    //...
   // 创建主线程的Looper
    Looper.prepareMainLooper();

    ActivityThread thread = new ActivityThread();
    thread.attach (false);

    if (sMainThreadHandler == null)
    {
        sMainThreadHandler = thread.getHandler();
    }

    if (false)
    {
        Looper.myLooper().setMessageLogging (new
                                             LogPrinter (Log.DEBUG, "ActivityThread") );
    }

    // End of event ActivityThreadMain.
    Trace.traceEnd (Trace.TRACE_TAG_ACTIVITY_MANAGER);
    //开启循环
    Looper.loop();

    throw new RuntimeException ("Main thread loop unexpectedly exited");
}
```
ActivityThread 的内部类 H 继承自 Handler ，其内部定义了一组消息类型，组要包括了四大组件的启动和停止。

**主线程消息循环模型**：ActivityThread 内部通过 ApplicationThread 和 AMS 进行进程间通信，AMS 以进程间通信的方式完成 ActivityThread 的请求后回调 ApplicationThread 中的 Binder 方法，然后 ApplicationThread 向 H 发送消息， H收到后将 ApplicationThread 中的逻辑切换到 ActivityThread 中去执行。














