---
title: AsyncTask 工作原理及线程池
date: 2017-1-6 16:06:25
categories: [android,学习笔记]
tags: [AsyncTask,线程池]
---

> 读书笔记： 《Android 开发艺术探索》 ——第十一章：android 线程及线程池

在 android 中，线程通常为主线程和子线程，前者主要处理和界面相关的事情，而后者主要用于耗时操作。
android 中的线程主要有 `Thread`、`AsyncTask`、`IntentService` 和 `HandlerThread` 。
<!--more-->
## 一、android 中的线程形态

AsyncTask、IntentService 和 HandlerThread 的底层实现都是线程，但都有特殊的表现形式，各有优缺点。 
**AsyncTask** 封装了 线程池 和 Handler ，主要用于子线程更新UI；**HandlerThread** 是一种具有消息循环的线程，内部可以使用 Handler ； **IntentService** 是一个服务，内部采用 HandlerThread 执行任务，它类似一个后台线程，但是一个服务，不容易被杀死。

### 1.1 AsyncTask

AsyncTask 是一个轻量级的异步线程任务类，它在线程池中执行后台任务，然后把进度和最终结果传递给主线程并在主线程中更新UI，它封装了 Thread 和 Handler，但不适合特别耗时的后台任务，对于特别耗时的任务可以用线程池。


AsyncTask 是一个**抽象的泛型类**，有 Params, Progress, Result 三个泛型参数，分别表示参数类型、后台任务执行进度类型、后台任务返回结果类型。如果不需要具体的参数，可用 Void 代替。
```
public abstract class AsyncTask<Params, Progress, Result> {}
```

核心方法如下：

- **onPreExecute()**
在主线程中执行，异步任务之前调用，一般用于做准备工作。
- **doInBackground(Params... params)**
在线程池中执行异步任务，可以通过 publishProgress （最终会调用onProgressUpdate）方法更新任务进度，次啊外该方法需要计算返回结果给onPostExecute。
- **onProgressUpdate((Progress... values)**
在主线程中当任务进度改变后被调用
- **onPostExecute(Result result)**
在主线程中执行，异步任务执行完后，result 是 doInBackground 返回的值。

使用时注意事项：

-  AsyncTask 必须在主线程中加载
- AsyncTask 的对象必须在主线程中创建
- execute 方法必须在UI线程中调用
- 不要在程序中直接调用 上述和新方法
- 一个 AsyncTask 对象只能调用一次 execute 方法
- AsyncTask 在 android3.0后 ，用一个线程串行执行任务。


在使用 AsyncTask 时调用了 execute方法，而该方法调用了 executeOnExecutor ，如下源码：

```
 @MainThread
public final AsyncTask<Params, Progress, Result> execute(Params... params) {
        return executeOnExecutor(sDefaultExecutor, params);
}
@MainThread
public final AsyncTask<Params, Progress, Result> executeOnExecutor(Executor exec,
        Params... params) {
    if (mStatus != Status.PENDING) {
        switch (mStatus) {
            case RUNNING:
                throw new IllegalStateException("Cannot execute task:"
                        + " the task is already running.");
            case FINISHED:
                throw new IllegalStateException("Cannot execute task:"
                        + " the task has already been executed "
                        + "(a task can be executed only once)");
        }
    }

    mStatus = Status.RUNNING;

    onPreExecute();

    mWorker.mParams = params;
    exec.execute(mFuture);

    return this;
}
```
sDefaultExecutor 是一个串行的线程池，所有的任务都在该线程池中排队执行。这里也可以发现 AsyncTask 的 onPreExecute 方法是先执行的。mFuture 是一个 FutureTask（一个并发类） 对象，在AsyncTask的构造函数中通过 mWorker 进行实例化，而 mWorker 中 保存的有AsyncTask的参数。
如下 AsyncTask 的构造方法：
```
public AsyncTask() {
    mWorker = new WorkerRunnable<Params, Result>() {
        public Result call() throws Exception {
            mTaskInvoked.set(true);
            Result result = null;
            try {
                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
                //noinspection unchecked
                result = doInBackground(mParams);
                Binder.flushPendingCommands();
            } catch (Throwable tr) {
                mCancelled.set(true);
                throw tr;
            } finally {
                postResult(result);
            }
            return result;
        }
    };

    mFuture = new FutureTask<Result>(mWorker) {
        @Override
        protected void done() {
            try {
                postResultIfNotInvoked(get());
            } catch (InterruptedException e) {
                android.util.Log.w(LOG_TAG, e);
            } catch (ExecutionException e) {
                throw new RuntimeException("An error occurred while executing doInBackground()",
                        e.getCause());
            } catch (CancellationException e) {
                postResultIfNotInvoked(null);
            }
        }
    };
}
```

下面是线程池的执行过程：

```
public static final Executor SERIAL_EXECUTOR = new SerialExecutor();
private static volatile Executor sDefaultExecutor = SERIAL_EXECUTOR;
//...
private static class SerialExecutor implements Executor {
    final ArrayDeque<Runnable> mTasks = new ArrayDeque<Runnable>();
    Runnable mActive;

    public synchronized void execute(final Runnable r) {
        mTasks.offer(new Runnable() {
            public void run() {
                try {
                    r.run();
                } finally {
                    scheduleNext();
                }
            }
        });
        if (mActive == null) {
            scheduleNext();
        }
    }

    protected synchronized void scheduleNext() {
        if ((mActive = mTasks.poll()) != null) {
            THREAD_POOL_EXECUTOR.execute(mActive);
        }
    }
}
```
在 AsyncTask 执行时，首先将 参数封装成 FutureTask 对象，然后将其传入到 SerialExecutor 的 execute 方法中处理，首先通过  mTasks.offer() 方法将其添加到任务队列中，如果没有正在活动的任务，执行下一个任务 scheduleNext()。这里可以发现 AsyncTask 是串行执行的。 THREAD_POOL_EXECUTOR 是一个 线程池，真正的执行任务，而 SerialExecutor 负责任务的排队，InternalHandler 负责将执行环境从线程池切换到主线程中。

由于 FutureTask 的run方法最终会调用 mWorker 中call方法，这里回看前面 AsyncTask 的构造方法，在 mWorker 中call方法中 先将 mTaskInvoked 设置为true ，表示当前任务已被调用过，然后执行 doInBackground 方法，并将其结果传给 postResult 方法，而 postResult 方法主要是 通过 sHandler （InternalHandler对象）发送一个  MESSAGE_POST_PROGRESS 消息，最后调用到 AsyncTask 的 finish方法，通过传入的 Result ，在 finish 中 最后确定是调用取消（`onCancelled(result)`）还是执行完成（`onPostExecute(result)`）。到此 ，AsyncTask 的整个工作流程结束。

InternalHandler 是一个 静态的 Handler 对象，为了能将执行环境切换到主线程，则 sHandler 必须在主线程中创建，同时 变相要求了 AsyncTask 要在 主线程中 创建。



### 1.2 HandlerThread

`HandlerThread` 类继承自 Thread ，是一个可以使用 Handler 的 Thread。主要是**在其 run 方法中创建了消息队列和开启消息循环**。这样就可以 在 HandlerThread 中创建Handler。
如下其 run方法：
```
public void run() {
    mTid = Process.myTid();
    Looper.prepare();
    synchronized (this) {
        mLooper = Looper.myLooper();
        notifyAll();
    }
    Process.setThreadPriority(mPriority);
    onLooperPrepared();
    Looper.loop();
    mTid = -1;
}
```
HandlerThread 的run 方法是一个无线循环方法，在不需要时可以 通过 `quit` 或者 `quitSafely` 进行终止。 HandlerThread 主要用在 IntentService 中，

### 1.3 IntentService

`IntentService` 是一个特殊的 service  ，继承自 Service，并且是一个抽象类，使用时必须创建其子类方可使用，它主要用于执行后台耗时任务，完成后自动关闭，它的优先级比普通的线程高，比较适合执行一些高优先级的后台任务。在其内部封装了 `HandlerThread` 和 `Handler（ServiceHandler）` 。如下其 `onCreate` 方法：
```
public void onCreate()
{
    super.onCreate();
    HandlerThread thread = new HandlerThread ("IntentService[" + mName + "]");
    thread.start();

    mServiceLooper = thread.getLooper();
    mServiceHandler = new ServiceHandler (mServiceLooper);
}
```
IntentService 在初次启动时调用 onCreate 方法，此时创建 HandlerThread ，然后通过它的 Looper 来构造一个 Handler 对象 mServiceHandler，这样通过 mServiceHandler 发送的消息最后都在 HandlerThread 中处理，这导致 IntentService 也是顺序执行后台任务的。

每次启动 IntentService ，它的 onStartCommand 会被调用，处理每一个后台任务，调用了 onStart 方法 ,通过 mServiceHandler 发送一个消息，最后在 HandlerThread 中处理。
```
public int onStartCommand (@Nullable Intent intent, int flags, int startId)
{
    onStart (intent, startId);
    return mRedelivery ? START_REDELIVER_INTENT : START_NOT_STICKY;
}

public void onStart (@Nullable Intent intent, int startId)
{
    Message msg = mServiceHandler.obtainMessage();
    msg.arg1 = startId;
    msg.obj = intent;
    mServiceHandler.sendMessage (msg);
}
```
如下是 ServiceHandler 类的定义：
```
private final class ServiceHandler extends Handler
{
    public ServiceHandler (Looper looper)
    {
        super (looper);
    }

    @Override
    public void handleMessage (Message msg)
    {
        onHandleIntent ( (Intent) msg.obj);
        stopSelf (msg.arg1);
    }
}
```
mServiceHandler 收到消息后会将 Intent 对象传递给 onHandleIntent 处理，这里的 Intent 和 startService(intent) 中的 intent 完全一致，这样通过 这个 intent 就可以解析出外界启动 IntentService 所传递的参数，在 onHandleIntent 方法 中对不同的后台任务做处理。当 onHandleIntent 执行完后 调用 stopSelf ，停止服务。

上面提到的 onHandleIntent 方法是一个抽象方法，在使用时需要实现。

## 二、android中的线程池
线程池主要有如下几个优点：

- 重用线程池中的线程，避免因线程的重复创建和销毁导致的性能开销；
- 能有效控制线程池的最大并发数，避免线程相互抢占资源导致阻塞；
- 能够对线程进行简单的管理，提供定时执行等功能。

### 2.1  ThreadPoolExecutor
android 中的线程池 源于 java 中的 Exector,Exector是一个接口，真正的线程池的实现类为 ThreadPoolExecutor 类，它提供了一系列的参数来配置线程池，通过不同的参数可以创建不同的线程池。
如下他它的一个常用构造方法的声明：
```
public ThreadPoolExecutor (int corePoolSize,
                           int maximumPoolSize,
                           long keepAliveTime,
                           TimeUnit unit,
                           BlockingQueue<Runnable> workQueue,
                           ThreadFactory threadFactory)
```
参数说明：

- **corePoolSize** 
核心线程数，默认情况下 一直存活着，即使处于闲置状态。将 allowCoreThreadTimeOut 属性设置为 true 时，闲置的核心线程等待新任务到来时会有超时策略，改时间间隔由 keepAliveTime 所指定，当时间超过 keepAliveTime 后，线程会被终止。
- **maximumPoolSize**
最大线程数，当线程数达到该值后，后续的线程会被阻塞。
- **keepAliveTime**
非核心线程闲置的超时时长，超过后就会被回收。
- **unit**
指定 keepAliveTime 参数的时间单位，常用的有 TimeUnit.MILLISECONDS（毫秒）、TimeUnit.SECONDS（秒）、TimeUnit.MINUTES（分）等
- **workQueue**
线程池中的任务队列
- **threadFactory**
线程工厂，为线程池提供创建新线程的功能，是一个 接口。

如下是 AsyncTask 中 THREAD_POOL_EXECUTOR 线程池的配置：
```
//cpu 数
private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
//核心线程 
private static final int CORE_POOL_SIZE = Math.max (2, Math.min (CPU_COUNT - 1, 4) );
//线程池最大线程数 
private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
//闲置超时时间 30s
private static final int KEEP_ALIVE_SECONDS = 30;

private static final ThreadFactory sThreadFactory = new ThreadFactory()
{
    private final AtomicInteger mCount = new AtomicInteger (1);

    public Thread newThread (Runnable r)
    {
        return new Thread (r, "AsyncTask #" + mCount.getAndIncrement() );
    }
};
//任务队列容量 128
private static final BlockingQueue<Runnable> sPoolWorkQueue =
    new LinkedBlockingQueue<Runnable> (128);
public static final Executor THREAD_POOL_EXECUTOR;

static
{
    ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor (
        CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_SECONDS, TimeUnit.SECONDS,
        sPoolWorkQueue, sThreadFactory);
    threadPoolExecutor.allowCoreThreadTimeOut (true);
    THREAD_POOL_EXECUTOR = threadPoolExecutor;
}
```
### 2.2 线程池的分类

除了 前面 的 ThreadPoolExecutor ，android 中还有如下四类线程池，他们都直接或者间接的通过配置 ThreadPoolExecutor 来实现自己的功能，通过 `Executors` 对应的new方法来创建。

- **FixedThreadPool**
通过 `Executors.newFixedThreadPool()` 创建，线程数固定的线程池，线程空闲时不会被回收，除非线程池被关闭。这种方式创建的线程池中只有核心线程且不会超时，任务队列无大小限制，能够更快的响应外界的请求。
 
 ```
 public static ExecutorService newFixedThreadPool (int nThreads)
{
    return new ThreadPoolExecutor (nThreads, nThreads,
                                   0L, TimeUnit.MILLISECONDS,
                                   new LinkedBlockingQueue<Runnable>() );
}
 ```
 
- **CachedThreadPool**
通过 `Executors.newCachedThreadPool()` 创建，是一种线程数不固定的线程池，只有核心线程，最大数为 Integer.MAX_VALUE，超时时间60s。

 ```
 public static ExecutorService newCachedThreadPool()
{
    return new ThreadPoolExecutor (0, Integer.MAX_VALUE,
                                   60L, TimeUnit.SECONDS,
                                   new SynchronousQueue<Runnable>() );
}
 ```

- **ScheduledThreadPool**
通过 `Executors.newScheduledThreadPool()` 创建，是一种核心线程数固定，非核心线程数不固定的线程池。主要用于执行定时任务和具有固定周期的重复任务。

 ```
 public static ScheduledExecutorService newScheduledThreadPool (int corePoolSize)
{
    return new ScheduledThreadPoolExecutor (corePoolSize);
}
public ScheduledThreadPoolExecutor (int corePoolSize)
{
    super (corePoolSize, Integer.MAX_VALUE,
           DEFAULT_KEEPALIVE_MILLIS, MILLISECONDS,
           new DelayedWorkQueue() );
}
 ```
 
- **SingleThreadExecutor**
通过 `Executors.newSingleThreadExecutor()` 创建，内部只有一个线程，可以确保所有的任务都在同一个线程中顺序执行，可以统一外界的任务到一个线程中。
 
 ```
 public static ExecutorService newSingleThreadExecutor()
{
    return new FinalizableDelegatedExecutorService
           (new ThreadPoolExecutor (1, 1,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>() ) );
}

 ```
这是系统提供的四种常见的 线程池，此外还可以根据自己的实际需要灵活的配置线程池。



