---
title: android 自定义View 详解
date: 2016-12-19 16:06:25
categories: [android,学习笔记]
tags: [View,自定义,原理]
---
> 读书笔记： 《Android 开发艺术探索》 ——第四章：View 的工作原理

经过上一节 [Android View 的事件体系](http://imtianx.cn/2016/12/17/Android%20View%20%E7%9A%84%E4%BA%8B%E4%BB%B6%E4%BD%93%E7%B3%BB/)的介绍，对 View 的架构及相关的事件分发有了解，本章主要介绍自定义 View 的相关知识。

对于自定义 View ，主要有： 直接继承View 和 ViewGroup，或者继承现有控件，如 ListView 等。不管使用哪种方式，都要先了解View 的工作原理 ，才能更好的进行自定义 View。
<!--more-->
## 一、理解 MeasureSpec

MeasureSpec 意思是 “度量规格”，它是View 的一个静态内部类，封装了父view传递给子View 的布局要求，
在很大程度上确定了一个View 的尺寸。在测量过程中，系统会将 View 的LayoutParams 根据父容器所施加的规则转换成相应的 MeasureSpec，然后通过它测量 View 的宽高。

MeasureSpec 是一个32 位的int值，高2位代表 `SpecModel`,低30位代表 `SpecSize`。 SpecModel 指测量模式，SpecSize指在某种测量模式下的规格大小。这种将来两个个值打包成一个int值，可以避免过多的对象内存分配。对于 `SpecModel` 主要有如下三种模式：

- **UNSPECIFIED**
  该模式下，父容器不对View 有任何限制，要多大给多大，一般用于系统内部。
- **EXACTLY**
该模式下，父容器已经检测出 View 所需的**精确**大小，此时 View  的最终大小就是 **SpecSize**，它对应 LayoutParams 中的 `match_parent` 和 `具体数值`。
- **AT_MOST**
View 的大小不能超过父容器指定的可用大小 (`SpecSize`) ,它对应 LayoutParams 中的 `wrap_parent`。

上面提到了 View  的绘制还会和 `LayoutParams` 相关，对于 `DecorView` ,他的规则如下：

- LayoutParams.MATCH_PARENT:精确模式，大小就是窗口大小；
- LayoutParams.WARO_CONTENT:最大模式，大小不定，但不能超过窗口大小；
- 固定大小：如100dp，精确模式，LayoutParams 中指定的大小。

对于普通的 View 它的 MeasureSpec 创建规则如下：

|parentSpecMode <br> childLayoutParamsl<br>|EXACTLY|AT_MOST<br>|UNSPECIFIED<br>|
|:----:|:----:|:----:|:----:|
|dp/px|EXACTLY<br>childSize|EXACTLY<br>childSize|EXACTLY <br>childSize|
|match_parent|EXACTLY<br> parentSize|AT_MOST <br> parentSize|UNSPECIFIED <br> 0|
|wrap_content|AT_MOST<br> parentSize|AT_MOST<br> parentSize|UNSPECIFIED <br> 0|

> 说明：
对于普通 View 的 MeasureSpec 是由它父容器的 MeasureSpec 和 其本身的 LayoutParams 决定的。

> 当View 采用固定宽高时，其 MeasureSpec 是精确的，大小是 LayoutParams 指定的大小；
当View 的宽高是 match_parent 时，若其父容器是 精确的，则它也是精确的，大小为父布局的剩余空间；若父容器是最大模式，则view也是最大模式且大小不会超过父容器的剩余空间；
当 view 的宽高都是 wrap_content时，不管父容器是精确还是最大模式，他都是最大模式，大小不超过父容器的剩余空间。
对于 UNSPECIFIED 模式，主要用于系统内部，一般情况下我们不用关注。

## 二、View 的工作流程

对于View 它的工作流程主要指**测量(measure)、布局(layout)、绘制(draw)**这三大流程，其中 `measure` 确定 view 的测量宽高， `layout` 确定view 的最终宽高和四个顶点的位置，  `draw` 将 view 绘制在屏幕上。

### 2.1 measure 过程

对于**View 的测量**，是由 `measure`方法完成的，而该方法是一个final 类型的，其中调用 了 `onMeasure` 方法，如下 View中 onMeasure方法源码：

```
protected void onMeasure (int widthMeasureSpec, int heightMeasureSpec)
{
    //设置view 的测量值
    setMeasuredDimension (getDefaultSize (getSuggestedMinimumWidth(), widthMeasureSpec),
                          getDefaultSize (getSuggestedMinimumHeight(), heightMeasureSpec) );
}
```
其中，setMeasuredDimension 方法是设置测量值，而 `getDefaultSize` 方法是获得测量尺寸，如下源码：

```
public static int getDefaultSize (int size, int measureSpec)
{
    int result = size;
    int specMode = MeasureSpec.getMode (measureSpec);
    int specSize = MeasureSpec.getSize (measureSpec);

    switch (specMode)
    {
    case MeasureSpec.UNSPECIFIED:
        result = size;
        break;
    case MeasureSpec.AT_MOST:
    case MeasureSpec.EXACTLY:
        result = specSize;
        break;
    }
    return result;
}
```

注意 ` MeasureSpec.AT_MOST` 和 `MeasureSpec.EXACTLY` 两个分支语句返回相同结果，他们都是 MeasureSpec 中获取的测量结果。从这里可见 View 的宽高由 spaceSize 决定，所以**自定义控件时直接继承view 需要重写 `onMeasure` 方法，设置 `wrap_content` 时的大小，否则 使用 wrap_content 就相当于 match_parent了，都是精确模式。**

在 onMeasure 中用到了 `getSuggestedMinimumWidth` 方法，如下源码：

```
/**
 * 如果无背景，返回mMinWidth（为 android:minWidth 指定的值）；
 * 否则，返回 minWidth 指定的值和背景最小宽度两者的最大值
 */
protected int getSuggestedMinimumWidth()
{
    return (mBackground == null) ? mMinWidth :
           max (mMinWidth, mBackground.getMinimumWidth() );
}
//获取背景最小宽度,即 Drawable 的原始宽度，如果没有就返回0
public int getMinimumWidth()
{
    final int intrinsicWidth = getIntrinsicWidth();
    return intrinsicWidth > 0 ? intrinsicWidth : 0;
}
```


对于**ViewGroup 的测量过程**，它可以包含多个 View ，所以除了调用自己的测量法法外，还要遍历所有子元素的测量方法。它是一个抽象类，没有onMeasure 方法，但也提供了 `measureChildren` 方法，在该方法中调用 `measureChild` 方法，分别测量子view 的宽高。

```
protected void measureChildren (int widthMeasureSpec, int heightMeasureSpec)
{
    final int size = mChildrenCount;
    final View[] children = mChildren;
    //遍历子view ，测量所有不是 GONE 状态的 view
    for (int i = 0; i < size; ++i)
    {
        final View child = children[i];
        if ( (child.mViewFlags & VISIBILITY_MASK) != GONE)
        {
            measureChild (child, widthMeasureSpec, heightMeasureSpec);
        }
    }
}
protected void measureChild (View child, int parentWidthMeasureSpec,
                             int parentHeightMeasureSpec)
{
    final LayoutParams lp = child.getLayoutParams();

    final int childWidthMeasureSpec = getChildMeasureSpec (parentWidthMeasureSpec,
                                      mPaddingLeft + mPaddingRight, lp.width);
    final int childHeightMeasureSpec = getChildMeasureSpec (parentHeightMeasureSpec,
                                       mPaddingTop + mPaddingBottom, lp.height);

    //调用 子view 的测量方法
    child.measure (childWidthMeasureSpec, childHeightMeasureSpec);
}
```

由于 ViewGroup 的子布局有不同的特性，这里通过调用子布局的 测量方法来测量每一个具体的View 的宽高，最终将他他们累加在一起，在计算具体的 View 时要考虑到 他的 padding 值。

由于view 的测量和 activity 的生命周期不是同的，如果要在 activity 中获取 view 的宽高，不能在 `onCreate` `onResume` 等方法中获取，可通过下面几种方式获取：

-  重写 onWindowFocusChanged(boolean hasFocus)  方法，在 hasFocus 为 true时获取
-  使用view.post(Runnable runnable) 发送消息队列
-  使用ViewTreeObserver ，添加 `addOnGlobalLayoutListener` 监听。

到此，view的测量完成了，接下来就是对其进行布局。


### 2.2 layout 过程

`layout` 方法确定 view 本身的位置，而ViewGroup 的 `onLayout` 方法确定所有子view 的位置。对于View 的layout 方法，首先是 调用 `setFrame`方法设置四个点的坐标，然后调用父容器的 `onLayout` 方法，确定子view 的位置。在布局过程中 view的最终宽高被确定，通常和测量宽高相等，他们只是在赋值的过程中不同。

### 2.3 draw 过程
绘制过程，主要是将view 绘制到屏幕上显示。调用 `draw(Canvas canvas)`方法，如下源码：

```
public void draw (Canvas canvas)
{
    final int privateFlags = mPrivateFlags;
    final boolean dirtyOpaque = (privateFlags & PFLAG_DIRTY_MASK) == PFLAG_DIRTY_OPAQUE &&
                                (mAttachInfo == null || !mAttachInfo.mIgnoreDirtyState);
    mPrivateFlags = (privateFlags & ~PFLAG_DIRTY_MASK) | PFLAG_DRAWN;

    /*
     * Draw traversal performs several drawing steps which must be executed
     * in the appropriate order:
     *
     *      1. Draw the background
     *      2. If necessary, save the canvas' layers to prepare for fading
     *      3. Draw view's content
     *      4. Draw children
     *      5. If necessary, draw the fading edges and restore layers
     *      6. Draw decorations (scrollbars for instance)
     */

    // Step 1, draw the background, if needed
    int saveCount;

    if (!dirtyOpaque)
    {
        drawBackground (canvas);
    }

    // skip step 2 & 5 if possible (common case)
    final int viewFlags = mViewFlags;
    boolean horizontalEdges = (viewFlags & FADING_EDGE_HORIZONTAL) != 0;
    boolean verticalEdges = (viewFlags & FADING_EDGE_VERTICAL) != 0;
    if (!verticalEdges && !horizontalEdges)
    {
        // Step 3, draw the content
        if (!dirtyOpaque)
        {
            onDraw (canvas);
        }

        // Step 4, draw the children
        dispatchDraw (canvas);

        // Overlay is part of the content and draws beneath Foreground
        if (mOverlay != null && !mOverlay.isEmpty() )
        {
            mOverlay.getOverlayView().dispatchDraw (canvas);
        }

        // Step 6, draw decorations (foreground, scrollbars)
        onDrawForeground (canvas);

        // we're done...
        return;
    }

```
主要有四个步骤：

- 绘制背景：drawBackground (canvas)；
- 绘制自己 ：onDraw (canvas);
- 绘制children：dispatchDraw (canvas);
- 绘制装饰： onDrawForeground(canvas);

view 通过 `dispatchDraw` 方法分发绘制的过程，而该方法会遍历所有子vied 的draw方法。如果View 是继承ViewGroup的并且自身不具备绘制功能时，可以调用 `setWillNotDraw` 设置标记位，使系统对其进行优化。

view 的大致工作流程就是这样的，自定义view涉及到View 的层次结构、事件分发和相关工作原理，尽管挺复杂，掌握它对我们的开发有很大的帮助。

## 三、自定义View

### 3.1 View 的分类
常见的自定义view的方式主要有如下几种：

1. 继承view 重写 onDraw方法；
这种方式主要用于实现不规则效果，需要自己支持 wrap_content 和 padding的处理
2. 继承 ViewGroup 派生出特殊的Layout
自定义布局，需要合适的处理ViewGroup 的测量和布局。
3. 继承特定的View（如TextView）
扩展现有控件，需要自己支持 wrap_content 和 padding的处理
4. 继承特定的ViewGroup（如LinearLayout）
这种方式和2类似，但不需要自己测量和布局过程。

### 3.2 自定义view的注意事项

1. 让View 支持 wrap_content
在 onMeasure 中对其进行处理，否则控件不支持 wrap_content属性
2.  让View 支持 padding
在draw方法中处理 padding，如果是继承自ViewGroup，需要在 onMeasure 中处理 padding 和 margin
3.  尽量不要使用 Handler ,View 本身提供的有 post方法
4.  view中如果有线程和动画需要及时停止。
5.  对于嵌套滑动，要处理好滑动冲突

至此，View 的相关知识介绍完毕，接下来就是进行具体自定义操作了。

> **本文作者**：[imtianx](http://imtianx.cn/about)
> **本文链接**： http://imtianx.cn/2016/12/19/android%20%E8%87%AA%E5%AE%9A%E4%B9%89View%20%E8%AF%A6%E8%A7%A3
> **版权申明**:：本站文章均采用 [CC BY-NC-SA 3.0 CN](http://creativecommons.org/licenses/by-nc-sa/3.0/cn/) 许可协议，请勿用于商业，转载请注明出处！



