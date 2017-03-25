---
title: Android View 的事件体系
date: 2016-12-17 16:06:25
categories: [android,学习笔记]
tags: [View,事件分发,滑动冲突]
---


>本文为读书笔记： 《Android 开发艺术探索 》——第三章 View 的事件体系     

android 系统虽然提供了很多基本的控件，如Button、TextView等，但是很多时候系统提供的view不能满足我们的需求，此时就需要我们根据自己的需求进行自定义控件。这些控件都是继承自View的。
<!-- more -->
## 一、android 控件架构
android 中的控件在界面上都会占一块巨型区域，主要分为两类：ViewGroup和View控件。ViewGroup作为父控件可以包含多个View控件，并管理他们，但其也是继承自View。通过Viewgroup，整个控件界面形成了View的控件树，如图1所示。

上层控件负责字控件的测量与绘制，并传递交互事件。在Activity 中 通过`findViewById()`方法，就是以树的 *深度优先遍历*  查找对应的控件。控件树的顶部都有一个ViewParent 对象，对整个视图进行控制。
![](/img/article_img/2016/view.png)


如上面图2 所示，是android 界面的架构图，在activity 中 通过 `setContentView()` 方法设置为根布局。在每一个Activity 中 都包含一个Window 对象，它由 PhoneWindow来实现，PhoneWindow 讲一个 DecorView 设置为整个应用窗口的根View。DecorView 作为窗口界面的顶层视图，封装了一些窗口操作的通用方法，所有View 的监听事件，都通过`WindowManagerService` 进行接收，并通过Activity 对象来回调相应的onClickListener。对于DecorView，他由TitleView 和ContentView 组成，
前者承载的是一个`Actionbar`，后者承载的是一个`FrameLayout`。

## 二、View 的基本知识
### 2.1、View 的位置参数
view 的位置由两个顶点坐标来决定，主要是左上（left,top）和右下(right,bottom)坐标。他们是相对于View 的父容器来说的，是相对坐标。如下图他们的关系：
![](/img/article_img/2016/view_zuobiao.png)

```
width = right - left;
height = bottom - top;

```
在View 中都有相应的方法来获取他们的值。从android 3.0开始，View增加了几个参数：x,y,translationX和translationY，其中x、y表示View 左上角的坐标，而translationX和translationY是View左上角相对于父容器的偏移量。同样的，他们也有相应的get/set方法，translationX和translationY的默认值均为0。
```
x = left + translationX;
y = right + translationY;
```
在View 的移动过程中top和left 表示原始左上角坐标，并不会改变。

### 2.2、MotionEvent和TouchSlop
**（1）、MotionEvent**
在手指触摸屏幕后，会有一系列的事件，主要事件类型有：

```
ACTION_DOWN // 收支接触
ACTION_MOVE // 手指在屏幕上移动
ACTION_UP //手指从屏幕松开
ACTION_CANCEL //取消
...
```
使用 `MotionEvent` 对象获取的 点击的 x 和 y ,使用 `getX / getY` 获取的是相对于当前View左上角的x和y,而 `getRawX / getRawY` 获取的是相对于手机屏幕左上角的坐标。

**（2）、TouchSlop**
TouchSlop 是系统所能识别的最小滑动距离，小于它则视未发生滑动，他和设备相关，在不同的设备上获取的值不同。通过 ` ViewConfiguration.get(getContext()).getScaledTouchSlop();` 获取。


### 2.3、VelocityTracker、GestureDetector和Scroller
**（1）、VelocityTracker**
速度追踪，用于追踪滑动过程中的速度，包括水平和竖直速度。如下具体使用步骤：

```
//1.在 onTouchEvent 方法中追踪当前事件的速度
VelocityTracker  tracker = VelocityTracker.obtain();
tracker.addMovement(event);
//2.获取当前速度
tracker.computeCurrentVelocity(1000);//计算速度
int xVelocity = (int) tracker.getXVelocity();
int yVelocity = (int) tracker.getYVelocity();
//3.在不需要的时候重置回收内存
tracker.recycle();
```

**（2）、GestureDetector**
手势检测，用于检测单击、滑动、长按、双击等手势。
在使用时，首先要实现 `GestureDetector.OnGestureListener`接口，如果需要双击，则需实现 `GestureDetector.OnDoubleTapListener` 接口；

```
//设置监听
mGestureDetector = new GestureDetector(this);
//避免长按后无法拖动，自己测试时发现不设置，长按后也可以拖动
mGestureDetector.setIsLongpressEnabled(false);
```
然后在 onTouchEvent 添加如下代码：

```
boolean consume = mGestureDetector.onTouchEvent(event);
return consume;
```

GestureDetector 类中的 OnGestureListener 接口和 OnDoubleTapListener 接口相关实现方法说明：

|方法名|描述|所属接口|
|------|:----:|:------:|
|onDown|手指轻触，一个ACTION_DOWN 触发|OnGestureListener|
|onShowPress|手指轻触，尚未松开或者拖动|OnGestureListener|
|onSingleTapUp|单击：手指（轻触后）松开，伴随一个ACTION_UP触发|OnGestureListener|
|onScroll|拖动：手指按下并拖动，一个ACTION_DOWN，多个ACTION_MOVE|OnGestureListener|
|onLongPress|长按|OnGestureListener|
|onFling|快速滑动：按下快速滑动并松开|OnGestureListener|
||||
|onSingleTapConfirmed|严格单击：这个只可能是单击，不会是双击中的一次单击|OnDoubleTapListener|
|onDoubleTap|双击 :与onSingleTapConfirmed 不共存|OnDoubleTapListener|
|onDoubleTapEvent|表示发生了双击行为|OnDoubleTapListener|


**（3）、Scroller**
弹性滑动，可是实现有过度效果的滑动，View 的 ScrollTo/ScrollBy 都是瞬间滑动完成的。

## 三、View 的滑动
实现View的滑动主要有如下三种方式:

1. **scrollTo /scrollBy** :适合对view 的内容改变；
2. **动画**： 主要用于没有交互的View 和实现复杂的动画效果；
3. **改变布局参数**：操作稍微复杂，适合有交互的View 。



### 3.1. 通过View 的 ScrollTo/ScrollBy 方法

View 源码中的相关实现：

```
  /**
     * Set the scrolled position of your view. This will cause a call to
     * {@link #onScrollChanged(int, int, int, int)} and the view will be
     * invalidated.
     * @param x the x position to scroll to
     * @param y the y position to scroll to
     */
    public void scrollTo(int x, int y) {
        if (mScrollX != x || mScrollY != y) {
            int oldX = mScrollX;
            int oldY = mScrollY;
            mScrollX = x;
            mScrollY = y;
            invalidateParentCaches();
            onScrollChanged(mScrollX, mScrollY, oldX, oldY);
            if (!awakenScrollBars()) {
                postInvalidateOnAnimation();
            }
        }
    }
    
      /**
     * Move the scrolled position of your view. This will cause a call to
     * {@link #onScrollChanged(int, int, int, int)} and the view will be
     * invalidated.
     * @param x the amount of pixels to scroll by horizontally
     * @param y the amount of pixels to scroll by vertically
     */
    public void scrollBy(int x, int y) {
        scrollTo(mScrollX + x, mScrollY + y);
    }

```

其中 `scrollBy` 调用的是 `scrollTo`，它实现了使用当前位置的相对滑动，而 `scrollTo` 是基于所传参数的绝对滑动。**在滑动过程中，mScrollX 的值等于 View 左边缘 和 View 内容左边缘在水平方向的距离，而 mScrollY 则是View 上边缘和 View 内容上边缘在竖直方向的距离。他们都是以像素单位。如果从 左往右/从上往下 滑动，mScrollX/mScrollY 为正。**

scrollBy 和 scrollTo 只能改变 View 内容的位置而不能改变View 在布局中的位置。

如下滑动过程中，mScrollX/mScrollY 取值情况：

![](/img/article_img/2016/View 中的scrollTo和scrollBy.png)


### 3.2. 使用动画

通过动画为View 添加平移效果，View 的 tanslationX 和 tanslationY 属性，可以采用传统的动画和属性动画。
动画不能真正的改变 View 的位置，只是移动的是他的影像，如果在新位置有点击事件，则无效。但是在android 3.0以后属性动画解决了该问题。

### 3.3. 改变布局参数
通过改变View 的LayoutParams 使得 View 重新布局实现滑动。
这里以 把 Button 水平移动 100px 为例。可以改变 Button 的 `marginLeft` ,或者在其左边放一个宽度为0 的view,当要平移时改变他的宽度，使其被挤到右边（加入Button的父布局为LinearLayout），实现滑动。

如下是改变 `LayoutParams`的方式：

```
 ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams)
                mButton.getLayoutParams();
params.width += 100;
params.leftMargin += 100;
mButton.setLayoutParams(params);  // 或者  mButton.requestLayout();
```

## 四、弹性滑动
为了避免 滑动的生硬，可以采用弹性滑动，提高用户体验。这里主要有 ：Scroller、动画、延时三种方式。

如下是 `Scroller` 的典型使用，主要是 **invalidate**方法起的作用。

```
Scroller mScroller = new Scroller(context);

/**
 * 滑动到指定位置
 *
 * @param destX  X 滑动距离
 * @param destY  Y 滑动距离
 */
private void smoothScrollTo(int destX, int destY) {
    //滑动起点X
    int scrollX = getScrollX();
    //滑动起点Y
    int scrollY = getScrollY();
    //1000 ms内慢慢滑向 （destX，destY）
    mScroller.startScroll(scrollX, scrollY, destX, destY, 1000);
    //重绘
    invalidate();
}
 /**
 * 使View 不断重绘
 */
@Override
public void computeScroll() {
    /**
     *  computeScrollOffset 方法通过时间流逝百分比计算 scrollX和scrollY 
     *  返回true 表示滑动未结束
     */
    if (mScroller.computeScrollOffset()) {
        //滑动到当前位置，通过小幅度滑动实现弹性滑动
        scrollTo(mScroller.getCurrX(), mScroller.getCurrY());
        //再次重绘
        postInvalidate();
    }
}
```
如下 **Scroller 的滑动原理（相关方法的调用过程）**：

![](/img/article_img/2016/Scroller滑动机制.png)


对于延时达到弹性滑动，主要是利用 了Handler 或者 View 的 postDelayed 方法，或者线程的 sleep方法。


## 五、View 的事件分发机制

在 view 中事件分发十分重要，了解他的原理，对我们理解View 和解决滑动冲突都十分重要。
>  1. 所有的Touch事件都封装到 `MotionEvent` 里面；
 2. 事件处理包括三种情况，分别为：**传递—-dispatchTouchEvent()函数、拦截——onInterceptTouchEvent()函数、消费—-onTouchEvent()函数和OnTouchListener**；
 3. 事件类型分为 ACTION_DOWN, ACTION_UP, ACTION_MOVE , ACTION_POINTER_DOWN, ACTION_POINTER_UP , ACTION_CANCEL 等，每个事件都是以 ACTION_DOWN 开始 ACTION_UP 结束。


用下面伪代码表示事件分发过程及其关系：

```
//事件分发
public boolean dispatchTouchEvent(MotionEvent event) {
    boolean consume = false;
    //是否被拦截
    if (onInterceptTouchEvent(event))
    {
        //被拦截，处理事件
        consume = onTouchEvent(event);
    } else {
        //未被拦截，向下分发
        consume = childView.dispatchTouchEvent(event);
    }
    return consume;
}
```

**事件传递的基本流程**：

-  事件都是从Activity.dispatchTouchEvent()开始传递；
-  事件由父View传递给子View，ViewGroup可以通过onInterceptTouchEvent()方法对事件拦截，停止其向子view传递；
- 如果事件从上往下传递过程中一直没有被停止，且最底层子View没有消费事件，事件会反向往上传递，这时父View(ViewGroup)可以进行消费，如果还是没有被消费的话，最后会到Activity的onTouchEvent()函数；
- 如果View没有对ACTION_DOWN进行消费，之后的其他事件不会传递过来，也就是说ACTION_DOWN必须返回true，之后的事件才会传递进来；
- OnTouchListener优先于onTouchEvent()对事件进行消费。

## 六、View 的滑动冲突

滑动冲突的出现是由于内外两个view都是可以滑动的，如 ScrollView 中嵌套 ListView 。常见的滑动冲突场景有：

- 场景一：内外滑动方向不一致；
- 场景二：内外滑动方向一致；
- 场景三：上述两种场景的嵌套。

对于场景一，可以根据水平竖直方向的滑动距离差判断是哪种滑动，进行相应的拦截；场景二，可以通过自己的业务制定相应的处理规则，然后进行处理；场景三则结合前两种进行。

有些滑动冲突是采用了不合理的布局导致，可以更换布局，而有些则必须通过自定义控件重写拦截和分发事件处理。




