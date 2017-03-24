---
title: 属性动画详解（Animator）
date: 2016-04-25 19:00:38
categories: [android,学习笔记]
tags: [android,Animator,属性动画]
---
# 1、概述
对于之前介绍的Animation，它属于**视图动画**（View Animation）(可参见：[Animation 动画详解](http://imtianx.cn/2016/04/25/view-Animation/))，包括**补间动画**（Tween Animation）和**逐帧动画**（Tween Animation）；而在android中还有另一种动画，那就是**属性动画**（Property Animator），它包括**ValueAnimator** 和 **ObjectAnimator**。
<!--more-->
两者的**区别**：

 - 引入时间不同
   视图动画在API Level 1 引入的，而属性动画在API Level 11（即 android 3.0）引入的； 
 - 所在包不同
 视图动画在 **android.view.animation.Animation**包下，属性动画在：**android.animation**包下
 - 动画类的命名不同
 视图动画中类的名字为：**XXXAnimation**，而在属性动画中是：**XXXAnimator**
 - **作用的对象不同**（这个也是引入属性动画的原因）
 **视图动画是对控件做动画，不能改变控件内部的属性，对所有的控件都可以；而属性动画是通过改变控件的属性来实现动画，但使用ObjectAnimator时要求作用的控件的属性要有get,set方法。如果控件的属性没有get/set方法，可以通过包装类间接的设置get/set方法，或者使用ValueAnimator 实现。**

# 2、ValueAnimator 的基本使用
ValueAnimator是动画的核心，但不提供任何动画效果，它更像一个数值发生器，产生具有一定规律的数字，然后让调用者来控制动画的实现过程。用法如下：

 - **创建ValueAnimator实例**
 例：创建0到500的动画，时间为1s:
 ```
ValueAnimator animator = ValueAnimator.ofInt(0,500);  
animator.setDuration(1000); 
 ```
代码中可以看出，它不与任何控件关联，只对动画做运算。

 - **添加它的监听事件**
 下面是给它添加监听事件，实现动画的。
 ``` 
 animator.addUpdateListener(new ValueAnimator.
                        AnimatorUpdateListener() {
                    @Override
                    public void onAnimationUpdate(ValueAnimator animation) {
                        //具体处理动画逻辑
                    }
                });
                //开启动画
                animator.start();
    
 ```
 具体示例：
 点击按钮使textView从(200,200)移动到（600，,600）
  ```
  btnStartAnim = (Button) findViewById(R.id.btn);
tv = (TextView) findViewById(R.id.tv);
btnStartAnim.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        //设置数据
        ValueAnimator animator = ValueAnimator.ofInt(200, 600);
        animator.setDuration(1000);
        //监听动画
        animator.addUpdateListener(new ValueAnimator.
                AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                //获取当前动画的值
                int curValue = (int) animation.getAnimatedValue();
                //设置tv的位置
                tv.layout(curValue, curValue,
                        curValue + tv.getWidth(),
                        curValue + tv.getHeight());
            }
        });
        //开启动画
        animator.start();
    }
});
  ```
示例效果：
![](/img/article_img/ValueAnimator-simple-demo.gif)

# 3、ValueAnimator 常用方法
 
```
/**
* 设置动画参数，参数类型为可变参数
*/
ValueAnimator ofInt(int... values);
ValueAnimator ofFloat(int... values);

/**
* 设置动画时长，单位是毫秒
*/
ValueAnimator setDuration(long duration);

/**
* 获取 ValueAnimator 在运动时，当前运动点的值
*/
Object getAnimatedValue();

/**
* 开始动画
*/
void start();

/**
* 设置循环次数,设置为 INFINITE 表示无限循环
*/
void setRepeatCount(int value);

/**
* 设置循环模式
* value 取值有 RESTART，REVERSE（分别为：重新开始，倒序重新开始）
*/
void setRepeatMode(int value);

/**
* 取消动画
*/
void cancel();
```
通过源码，发现ofInt和ofFloat方法内部实现一样的，他们的区别在于传入的参数类型不同，需要注意的是在使用**getAnimatedValue**方法时，如果前面**使用的是ofInt,要强转成int 类型**，否则，转为float类型。
此外，如果不需要动画，可以调用移除动画监听方法，但需要先调用cancel方法取消动画。
# 4、ObjectAnimator 的基本使用
ObjectAnimator 类继承自ValueAnimator，使用时通过静态工厂类直接返回一个对象，参数包括对象和对象的属性名，但该属性必须要有get和set函数，这样可以真实的控制一个view的属性值，因此它基本可以实现所有的动画效果。
使用示例：
使textView的translationX从0变化到200在变化到500，持续时间为1s,代码如下：
```
ObjectAnimator animator = ObjectAnimator.ofFloat(textView,
            "translationX",new float[]{200,500});
    animator.setDuration(1000);
    animator.start();
```
ofFloat的参数：第一个是要操纵的View；第二个是要操纵的属性；第三个是参数，是一个可变数组。同样的，可以给它设置显示时长，插值器等。
在开始提到了，ObjectAnimator用于有get，set属性的控件，对于没有的可以通过一个包装类来实现，如下：
```
/**
 * 包装类，给width添加get，set方法
 */
public static class WrapperView {
    private View mTarget;

    public WrapperView(View target) {
        mTarget = target;
    }

    public int getWidth() {
        return mTarget.getLayoutParams().width;
    }

    public void setWidth(int width) {
        mTarget.getLayoutParams().width = width;
        mTarget.requestLayout();
    }
}
```
使用时，直接操纵包装类，如下：
```
WrapperView mWrapperView = new WrapperView(btnStartAnim);
ObjectAnimator animator = ObjectAnimator.ofInt(
        mWrapperView,"width",500).setDuration(500);
animator.start();
```
通过上面，可以知道，ObjectAnimator 实现动画主要是通过set方法来设置控件的对应的属性实现动画。

# 5、ObjectAnimator 的常用方法
除了上面的ofInt,ofFloat方法，对于要改变背景色的，可以使用**ArgbEvaluator**，用法如下,给textView设置背景色在三种颜色间变化：
```
ObjectAnimator animator = ObjectAnimator.ofInt(textView,
        "BackgroundColor",0xffff00ff, 0xffffff00, 0xffff00ff);
animator.setDuration(2000);
animator.setEvaluator(new ArgbEvaluator());
animator.start();
```
其他常用函数如下：
摘抄于：http://wiki.jikexueyuan.com/project/android-animation/7.html
```
/** 
 * 设置动画时长，单位是毫秒 
 */  
ValueAnimator setDuration(long duration)  
/** 
 * 获取 ValueAnimator 在运动时，当前运动点的值 
 */  
Object getAnimatedValue();  
/** 
 * 开始动画 
 */  
void start()  
/** 
 * 设置循环次数,设置为 INFINITE 表示无限循环 
 */  
void setRepeatCount(int value)  
/** 
 * 设置循环模式 
 * value 取值有 RESTART，REVERSE， 
 */  
void setRepeatMode(int value)  
/** 
 * 取消动画 
 */  
void cancel() 
```
监听相关的方法：
```
/** 
 * 监听器一：监听动画变化时的实时值 
 */  
public static interface AnimatorUpdateListener {  
    void onAnimationUpdate(ValueAnimator animation);  
}  
//添加方法为：public void addUpdateListener(AnimatorUpdateListener listener)  
/** 
 * 监听器二：监听动画变化时四个状态 
 */  
public static interface AnimatorListener {  
    void onAnimationStart(Animator animation);  
    void onAnimationEnd(Animator animation);  
    void onAnimationCancel(Animator animation);  
    void onAnimationRepeat(Animator animation);  
}  
//添加方法为：public void addListener(AnimatorListener listener)
```
插值器与 Evaluator:
```
/** 
 * 设置插值器 
 */  
public void setInterpolator(TimeInterpolator value)  
/** 
 * 设置 Evaluator 
 */  
public void setEvaluator(TypeEvaluator value) 
```

更多方法可以查看api
# 6、AnimatorSet的使用
在视图动画中  AnimationSet 来处理混合动画，同样的，这里的AnimatorSet来处理多个动画的。它出了实现多种动画，还可以精确的进行顺序控制。
示例代码：
```
ObjectAnimator animator1 = ObjectAnimator.ofFloat(textView, "translationX", 300);
ObjectAnimator animator2 = ObjectAnimator.ofFloat(textView, "scaleX", 1, 0, 1);
ObjectAnimator animator3 = ObjectAnimator.ofFloat(textView, "scaleY", 1, 0, 1);
AnimatorSet animatorSet = new AnimatorSet();
animatorSet.setDuration(1000);
animatorSet.playTogether(animator1, animator2, animator3);
animatorSet.start();
```
示例效果：
![](/img/article_img/AnimatorSet.gif)

以上示例设置textView在x轴方向移动300，x和y方向先缩小到一倍再还原到一倍三种动画是同时执行。
若需要按顺序执行，可以调用Animator的**playSequentially**方法。

# 7、PropertyValuesHolder 的使用
除了上面讲的AnimatorSet 实现多种动画，还可以通过PropertyValuesHolder来实现，比如上面的例子在平移的过程中实现x,y轴的缩放。如下代码;
```
PropertyValuesHolder valuesHolder1 = PropertyValuesHolder
    .ofFloat("translationX", 300);
PropertyValuesHolder valuesHolder2 = PropertyValuesHolder
    .ofFloat("scaleX", 1, 0, 1);
PropertyValuesHolder valuesHolder3 = PropertyValuesHolder
    .ofFloat("scaleY", 1, 0, 1);
ObjectAnimator.ofPropertyValuesHolder(tv, valuesHolder1,
    valuesHolder2, valuesHolder3).setDuration(1000).start();
```

运行效果同AnimatorSet中的示例。
它的实现是先分别用PropertyValuesHolder的对象来控制不同的属性，最后调用ofPropertyValuesHolder方法实现多个属性动画的共同作用。

# 8、在XML文件中实现属性动画
先在xml文件中定义属性，如下示例：
```
<?xml version="1.0" encoding="utf-8"?>
<objectAnimator xmlns:android="http://schemas.android.com/apk/res/android">
    android:duration=1000"
    android:propertyName="scaleX"
    android:valueFrom="1.0"
    android:valueTo="2.0"
    android:valueType="floatType"
</objectAnimator>
```
在java代码代码中使用：
```
Animator animator = AnimatorInflater.
        loadAnimator(MainActivity.this,
        R.animator.scalex);
animator.setTarget(tv);
animator.start();
```
需要注意的是，xml文件的定义需要放在res/animator下，而且根节点只能是：set,objectAnimator,valueAnimator三者之一。如果使用的set，可以为其指定播放的方式，属性名为：ordering=["together"]|["sequentially"]，
默认值为：“together”，对于其他具体的属性这里不再赘述了，可以参见文档。
在实际开发中建议使用代码实现动画，比较简单，而且很多时候某些属性的起始值无法确定。

# 8、View的animate方法
在android3.0之后，添加了animate方法来直接驱动属性动画，它其实是对属性动画的简写，如下示例：
```
 view.animate()
        .alpha(0)
        .y(300)
        .setDuration(1000)
        .withStartAction(new Runnable() {
            @Override
            public void run() {

            }
        })
        .withEndAction(new Runnable() {
            @Override
            public void run() {

            }
        }).start();

```
上面的例子很好理解，可以通过属性来确定他的含义。
总之，在实现动画时，可以根据自己的实际情况选择相应的方式实现动画，必要的时候还可以自定义实现动画，往往在使用时，不只是一种动画，我们要选择合适的方式实现多种动画。