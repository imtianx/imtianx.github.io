---
title: Animation 动画详解
date: 2016-04-25 11:00:38
categories: [android,学习笔记]
tags: [android,Animation,动画]
---
在android 开发中，适当的添加动画可以使界面的交互变得更加的友好，特别是在提示，引导类的场景中，合理的使用动画可以带来更好的用户体验。这里，介绍**Animation** 框架的用法。<!--more-->

## 1. 概述
在 Animation动画框架中提供了四中动画方式，分别为：

 - 透明    [AlphaAnimation](https://developer.android.com/reference/android/view/animation/AlphaAnimation.html)
 - 旋转    [RotateAnimation](https://developer.android.com/reference/android/view/animation/RotateAnimation.html)
 - 缩放    [ScaleAnimation](https://developer.android.com/reference/android/view/animation/ScaleAnimation.html)
 - 平移   [TranslateAnimation](https://developer.android.com/reference/android/view/animation/TranslateAnimation.html)
此外，还提供了[AnimationSet](https://developer.android.com/reference/android/view/animation/AnimationSet.html)动画集合，混合使用多种动画。
它们对应的 **xml**  的标签分别为：**alpha,rotate,scale,translate和set。**
**Animation**是他们的基类，有如下的标签和对应的函数：
**android:duration setDuration(long)** 动画持续时间，以毫秒为单位
**android:fillAfter setFillAfter(boolean)** 如果设置为 true，控件动画结束时，将保持动画最后时的状态
**android:fillBefore setFillBefore(boolean)** 如果设置为 true,控件动画结束时，还原到开始动画前的状态
**android:fillEnabled setFillEnabled(boolean)** 与 android:fillBefore 效果相同，都是在动画结束时，将控件还原到初始化状态
**android:repeatCount setRepeatCount(int)** 重复次数
**android:repeatMode setRepeatMode(int)** 重复类型，有 reverse 和 restart 两个值，取值为 RESTART 或 REVERSE，必须与 repeatCount 一起使用才能看到效果。因为这里的意义是重复的类型，即回放时的动作。
**android:interpolator setInterpolator(Interpolator)** 设定插值器，其实就是指定的动作效果，比如弹跳效果等

## 2. Interpolator 插值器
对于动画，它的速率变化有快又慢，谷歌给出了**插值器**，来方便我们控制动画的变化。在不同的插值器的作用下，其变化也不一样。官方给的插值器有（谷歌官方）：
![](/img/article_img/Interpolator.jpg)
部分资源id为(改图来自网络)：
![](/img/article_img/Interpolator-resource-id.png)

## 3. xm实现动画
以**scale**标签为例，其他类似。scale有以下几个属性：

- **android:fromXScale** 起始的 X方向上相对自身的缩放比例，浮点值，比如 1.0 代表自身无变化，0.5 代表起始时缩小一倍，2.0 代表放大一倍；
- **android:toXScale** 结尾的 X 方向上相对自身的缩放比例，浮点值；
- **android:fromYScale** 起始的 Y方向上相对自身的缩放比例，浮点值，
- **android:toYScale** 结尾的 Y 方向上相对自身的缩放比例，浮点值；
- **android:pivotX** 缩放起点 X 轴坐标，可以是数值、百分数、百分数 p。 三种样式，比如 50、50%、50%p，当为数值时，表示在当前 View的左上角，即原点处加上 50px，做为起始缩放点；如果是 50%，表示在当前控件的左上角加上自己宽度的 50%做为起始点；如果是 50%p，那么就是表示在当前的左上角加上父控件宽度的 50%做为起始点 x 轴坐标。
- **android:pivotY** 缩放起点 Y 轴坐标，取值及意义跟android:pivotX 一样。
- **android:interpolator** 就是添加的插值器，通过不同的Resource ID引用不同的插值器类。
- **android：fillAfter** 保持动画结束的状态，同样的可以保存初始化状态（**fileBefore**）
- **android:repeatMode** 设定回放类型，重新开始/倒退（restart /reverse）
在res下新建anim 文件夹，新建scaleanim.xml文件，如下代码（宽高从0放大到1.5倍，开开始和结束速度慢，中间快，停留在结束状态，重复一次）：
```
<?xml version="1.0" encoding="utf-8"?>
<scale
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:interpolator="@android:anim/accelerate_decelerate_interpolator"
    android:fromXScale="0.0"
    android:fromYScale="0.0"
    android:pivotX="50"
    android:pivotY="50"
    android:toXScale="1.5"
    android:toYScale="1.5"
    android：fillAfter="true"
    android:repeatCount="1"  
    android:repeatMode="restart"  >
</scale>
```
上面定义好了动画，下面就是具体的使用，这里以给textView设置上面的scale动画为例，代码如下：
```
Animation mAnimation = AnimationUtils.loadAnimation(this,R.anim.scaleanim);
    textView.startAnimation(mAnimation);
```
注：对于其他的标签及其属性可以参见[官方文档](https://developer.android.com/reference/android/view/animation/Animation.html),这些标签可以放在一个**set标签**中，来定义动画集合。
## 4. java 代码实现动画
这里以**AlphaAnimation**为例，若xml代码为：
``` 
<?xml version="1.0" encoding="utf-8"?>  
<alpha xmlns:android="http://schemas.android.com/apk/res/android"  
    android:interpolator="@android:anim/bounce_interpolator"
    android:fromAlpha="1.0"  
    android:toAlpha="0.1"  
    android:duration="3000"  
    android:fillBefore="true">  
</alpha>
```
与其有相同效果的java代码为：
```
alphaAnim = new AlphaAnimation(1.0f,0.1f);  
alphaAnim.setDuration(3000);  
alphaAnim.setFillBefore(true); 
alphaAnim.setInterpolator(new BounceInterpolator());//设置插值器
```
 最后，就是给相应的控件设置动画，如下：
```
textView.startAnimation(alphaAnim);
```
  
## 5. 动画回调监听事件
对于上面的两中方法设置动画，可以添加相应的监听回调，获得动画的开始，结束和重复事件，并对不同的事件作出相应的处理。
```
mAnimation.setAnimationListener(new Animation.AnimationListener() {
        @Override
        public void onAnimationStart(Animation animation) {
            //动画开始前的回调处理
        }
        @Override
        public void onAnimationEnd(Animation animation){
            //动画结束时的回调处理
        }
        @Override
        public void onAnimationRepeat(Animation animation) {
            //动画重复的回调处理
        }
    });
```
更多：[属性动画（ValueAnimator 和 ObjectAnimation）](http://imtianx.cn/2016/04/25/Property-animatorValueAnimator_ObjectAnimation)

