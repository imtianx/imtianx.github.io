---
title: 数据绑定库DataBinding的使用
date: 2016-09-10 16:06:25
categories: [android,学习笔记]
tags: [DataBinding,数据绑定]
---

`Data Binding` 是谷歌提供的 android 数据绑定库，为了而方便开发者实现 MVVM 的架构模式，使用它可以避免我们写大量的`findViewByID`，降低代码的耦合性。
[官方介绍](https://developer.android.com/topic/libraries/data-binding/index.html)(需翻墙)

### 一、使用环境要求
通过查看官方文档，改数据绑定库的使用环境要求如下：

- 下载 SDK Manager 中的支持库： Support repository；<!--more-->
- android studio 版本在1.3之后；
- gradle 版本在1.5.0-alpha1之后；
- android sdk在android 2.1（API level7 +）以后。

### 二、具体的使用
#### 2.1、配置 data binding.
在 model 的gradle中的 `android` 节点下添加如下代码：
```
dataBinding{
    enabled = true
}
```

#### 2.2、 建立数据对象
添加一个POJO类，这里定义的是 User类，添加3个变量（uname，usex，uage）及相应的get,set方法，方便接下来与布局文件惊醒绑定。

#### 2.3、 修改布局文件
使用databinding后，布局文件根节点不在是简单的LinearLayout，RelativeLayout等ViewGroup,而是 `Layout`，同时还增加了 `data` 元素，来为ui控件提供数据。基本局如下：
```
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
    </data>
    <!--原先的根节点-->
    <LinearLayout>
    ....
    </LinearLayout>
</layout>
```
下面简单举例说明，显示用户信息，包括用户名，性别和年龄，布局文件名为`activity_main`，使用 databinding 的布局代码如下：
```
<?xml version="1.0" encoding="utf-8"?>
<layout
    xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
        <variable
            name="user"
            type="cn.imtianx.databindingdemo.bean.User">
        </variable>
    </data>
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical">
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{user.uname}"/>
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{user.usex}"/>
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{user.uage}"/>
    </LinearLayout>
</layout>
```
该布局主要是三个TextView，来显示信息，在`data`标签中添加了变量`variable`,其中`name`是变量名,`type`使我们定义的java类（注：需要写完整的包名），通过`@{}`来为 TextView设置显示的文本。
此外，这里的`data`也可以用`import`进行导入，如下：
```
 <data>
    <import type="cn.imtianx.databindingdemo.bean.User"/>
    <variable
        name="user"
        type="User"/>
</data>
```
如果要使用`String`等`java.lang.*`下的类，则可以直接使用。

#### 2.4、绑定变量数据
编译项目即可根据布局文件名生成相关的Binding类，生成规则是按布局文件名，去掉’_‘，按驼峰法则，并在末尾添加`Binding`。如，这里的布局文件名为`activity_main`,则生成的数据绑定类为`ActivityMainBinding`，它存放在`包名.databinding`下，然后再 **activity**  的**onCreate**方法中设置变量，代码如如下：
```
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ActivityMainBinding mainBinding = DataBindingUtil
            .setContentView(this, R.layout.activity_main);
    User user = new User("imtianx", "男", "20");
    mainBinding.setUser(user);

}
```
**注意：** 这里的 ActivityMainBinding 类会根据布局文件中的 variable 生成相应的 `set`方法。
至此，一个简单的数据绑定就实现了，运行程序，会依次显示user中设置的三个字段的值。

### 三、设置见监听事件
这里可以通过两种方式进行绑定事件：**方法引用**和**监听器引用**。如下代码：
```
public class Presenter {

    public void onTextChanged(CharSequence s, int start, int before, int count) {
        mUserBean.setName(s.toString());
        mBinding.setUser(mUserBean);
    }

    public void onClick(View view) {
        Toast.makeText(MainActivity.this, "点击了名字", Toast.LENGTH_SHORT).show();
    }

    public void onClickListenerBinding(UserBean bean) {
        Toast.makeText(MainActivity.this, bean.getSex(), Toast.LENGTH_SHORT).show();
    }

}
```
使用时首先在xml的data标签下添加变量
```
<variable
    name="presenter"
    type="cn.imtianx.databindingdemo.MainActivity.Presenter">
</variable>
```
#### 3.1 方法引用
必须使用android 已有的监听的方法名及其参数，如上面的onTextChanged，onClick方法，具体的调用如下：
```
 android:onClick="@{presenter.onClick}"
```
#### 3.2 监听器引用
可以方便的丛xml中向java代码中传递数据，可使用lambda表达式,如onClickListenerBinding，具体调用如下：
```
android:onClick="@{()->presenter.onClickListenerBinding(user)}"
```
采用了lambda表达式的格式。

### 四、在Fragment中的用法
布局文件与上一个一样，在 Fragment 的 onCreateView 中设置相关的属性，具体代码如下：
```
private ActivityMainBinding mMainBinding;
    private User user;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.activity_main, container, false);
        // 方式1,直接用默认生成的Binding类绑定
        mMainBinding = ActivityMainBinding.bind(view);

        // 方式2，向上转成ViewDataBinding类型
//        ViewDataBinding viewDataBinding = ActivityMainBinding.bind(view);
//        mMainBinding = (ActivityMainBinding) viewDataBinding;

        //方式3，使用生成的Binding的inflater，
//        mMainBinding = ActivityMainBinding.inflate(inflater);

        //方式4，使用生成的Binding的inflater,类似Inflater api
//        mMainBinding = ActivityMainBinding.inflate(inflater, container, false);

        //方式5，某种情况无法生存默认Binding的情况下，并且把对应的layout传入
//        ViewDataBinding viewDataBinding = DataBindingUtil.inflate(inflater, R.layout.activity_main, container, false);
//        mMainBinding = (ActivityMainBinding) viewDataBinding;

        //方式6，某种情况无法生存默认Binding的情况下
//        ViewDataBinding viewDataBinding = DataBindingUtil.bind(view);

        user = new User("imtianx", "男", "20");
        mMainBinding.setUser(user);
        return view;
    }
```
总之，它都需要初始化Binding类，初始化model类和数据绑定。


### 五 、高级用法
#### 5.1. 使用类方法
首先在布局文件的`data` 使用`import`导入方法所在的类的全路径，然后再选要的地方调用，具体使用和java一样。

#### 5.2. 类型别名
在开发中可能会遇到两个用名的类，如果在`data`下同时导入他们，改如何解决？这里不用担心，可以在`import`节点下添加`alias`属性,来区别。如下示例：
```
 <data>
    <import type="cn.imtianx.databindingdemo.bean.User" alias="User1"/>
    <import type="cn.imtianx.databindingdemo.model.User" />
    <variable
        name="user"
        type="User1"/>
    <variable
        name="user2"
        type="User"/>
</data>
```
#### 5.3. Null Coalescing 运算符
这个和java中的三木表达式一样
```
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="@{user.uage ??user.uage}"/>
```
它等价于：
```
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="@{user.uage!=null?user.uage:0}"/>
```
#### 5.4. 属性值
使用`@{}`在xml中使用java 中定义的一些属性值,如下给visibility 设置值，注意需要到如View类，
```
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:visibility="@{user.display? View.VISIBLE:View.GONE}"
    android:text="@{user.uage"/>
```
#### 5.5. 使用资源数据
设置`padding`的值，需要的dime文件中添加largePadding和smallPadding的item。对于引用 `String、drawable`等资源类似。
```
 <TextView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:padding="@{user.display?(int)@dimen/largePadding : (int)@dimen/smallPadding}"
    android:text="@{user.uage}"/>
```
#### 5.6. 使用include
使用命名空间来传递variable，将当前 variable 的值传递给 include 进来 的布局中。
为 layout 添加命名空间：
```
xmlns:bind="http://schemas.android.com/apk/res-auto"
```
在`include`中使用：
```
<include
    layout="@layout/layout_user"
    bind:user="@{user}">
```
注意在 `layout_user.xml`中也要在 variable 中 定义添加 user 变量。

#### 5.7. 使用表达式
java 中的表达式，在这里也是支持的，

 - 数学 + - / * %
 - 字符串连接 +
 - 逻辑 && ||
 - 二进制 & | ^
 - 一元运算 + - ! ~
 - 移位 >> >>> <<
 - 比较 == > < >= <=
 - instanceof
....
Data Binding代码生成时自动检查是否为null来避免出现`null pointer exceptions`错误,`String` 类型默认值是` null` ,`int`类型默认值是 `0`，`boolean` 类型默认值是 `false`。


#### 5.8. 集合
常用的集合：arrays、lists、sparse，lists以及maps，为了简便都可以使用`[]`来访问。注意,在使用泛型时`<`需要转义，用`&lt;`代替，否则会报错。
```
<data>
  <import type="android.util.SparseArray"/>
  <import type="java.util.Map"/>
  <import type="java.util.List"/>
  <variable name="list" type="List&lt;String>"/>
  <variable name="sparse" type="SparseArray&lt;String>"/>
  <variable name="map" type="Map&lt;String, String>"/>
  <variable name="index" type="int"/>
  <variable name="key" type="String"/>
</data>
…
android:text="@{list[index]}"
…
android:text="@{sparse[index]}"
…
android:text="@{map[key]}"
```
#### 5.9.Data对象（数据绑定）
Data Binding 的强大之处主要在于双向数据绑定，当POJO对象发生变化时，通知改变Data对象，已达到更新UI的效果。有三种不同的数据变化通知机制：`Observable`对象、`ObservableFields`以及`observable  collections`。
这里以 Observable 为例，更改User类。使其继承`BaseObservable`,在`getter`方法前添加`Bindable`注解，在`setter`方法中调用`notifyPropertyChanged`进行更新数据。如果只更新某一字段，只需将该字段设置为`ObservableFields`类型的，如boolean,可用ObservableBoolean代替，但对其的使用需要通过get和set方法。具体代码如下：
```
public class User extends BaseObservable{
    private String uname;
    private String usex;
    private String uage;
    private boolean isDisplay;

    public User() {
    }

    public User(String uname, String usex, String uage, boolean isDisplay) {
        this.uname = uname;
        this.usex = usex;
        this.uage = uage;
        this.isDisplay = isDisplay;
    }
    @Bindable
    public String getUname() {
        return uname;
    }

    public void setUname(String uname) {
        this.uname = uname;
        notifyPropertyChanged(BR.uname);
    }

    @Bindable
    public String getUsex() {
        return usex;
    }

    public void setUsex(String usex) {
        this.usex = usex;
        notifyPropertyChanged(BR.usex);
    }

    @Bindable
    public String getUage() {
        return uage;
    }

    public void setUage(String uage) {
        this.uage = uage;
        notifyPropertyChanged(BR.uage);
    }

    @Bindable
    public boolean isDisplay() {
        return isDisplay;
    }

    public void setDisplay(boolean display) {
        isDisplay = display;
        notifyPropertyChanged(BR.display);
    }
```
在编译期间，Bindable注解在BR(与R文件类似)类文件中生成一个Entry。BR类文件会在模块包内生成。如果用于Data类的基类不能改变，Observable接口通过方便的PropertyChangeRegistry来实现用于储存和有效地通知监听器。

Data Binding的基本用法已经介绍完了，但它 的使用知识点较多，暂且写到这里,对于它在ListView/RecyclerView中的用法、事件处理等稍后再做介绍。
<br>


文中部分资料来源于页底的参考资料。

> 参考资料：
1. https://github.com/LyndonChin/MasteringAndroidDataBinding
2. http://www.jianshu.com/p/b1df61a4df77
3. https://realm.io/cn/news/data-binding-android-boyar-mount/?utm_source=tuicool&utm_medium=referral












