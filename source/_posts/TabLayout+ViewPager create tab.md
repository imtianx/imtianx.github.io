---
title: TabLayout+ViewPager创建tab
date: 2016-05-28 12:00:25
categories: [android,学习笔记]
tags: [5.X新特性,TabLayout]
---

在degingn库中有TabLayout控件，可以方便的实现tab切换的效果，配合ViewPager.
<!--more-->
如下展示效果：
![](/img/article_img/TabLayout+ViewPager-create-tab.gif)
### 1. 添加依design赖库
```
 compile 'com.android.support:design:23.4.0'
```
### 2.编写主布局文件。
使用TabLayout和ViewPager。TabLayout 有以下三个属性，方便我们设置tab的字体颜色，选中时字体的颜色及指示器的颜色：
```
app:tabTextColor="@android:color/black"
app:tabSelectedTextColor="@color/colorPrimary"
app:tabIndicatorColor="@color/colorPrimary"
```
具体的使用，如下代码：
```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    tools:context="cn.imtianx.tablayoutdemo.MainActivity">

    <android.support.design.widget.TabLayout
        android:id="@+id/tab"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="@android:color/white"
        app:tabIndicatorColor="@color/colorPrimary"
        app:tabSelectedTextColor="@color/colorPrimary"
        app:tabTextColor="@android:color/black">
    </android.support.design.widget.TabLayout>

    <android.support.v4.view.ViewPager
        android:id="@+id/container"
        android:layout_width="match_parent"
        android:layout_height="match_parent">

    </android.support.v4.view.ViewPager>
</LinearLayout>

```
### 3. 编写每个tab的布局。
为了简单，根布局仅使用一个 LinearLayout 并给其背景设置了颜色。
### 4. 创建适配器
创建 FragmentAdapter类，继承FragmentPagerAdapter。
```
/**
 * Created by imtianx on 2016-5-27.
 */
public class FragmentAdapter extends FragmentPagerAdapter {

    private List<String> mTitles; //标题
    private List<Fragment> mFragments;//viewpager 显示的页面

    public FragmentAdapter(FragmentManager fm, List<String> titles, List<Fragment> fragments) {
        super(fm);
        mTitles = titles;
        mFragments = fragments;
    }

    @Override
    public Fragment getItem(int position) {
        return mFragments.get(position);
    }

    @Override
    public int getCount() {
        return mFragments.size();
    }

    /**
     * tab 标题
     *
     * @param position
     * @return
     */
    @Override
    public CharSequence getPageTitle(int position) {
        return mTitles.get(position);
    }
}

```
### 5. 新建fragment页面
创建3个fragment，加载相应的布局。
### 6.绑定控件
在MainActicity 中绑定控件，设置adapter。
```
public class MainActivity extends AppCompatActivity {

    List<Fragment> mFragmentList;
    List<String> mTitles;
    TabFragment1 mFragment1;
    TabFragment2 mFragment2;
    TabFragment3 mFragment3;
    FragmentAdapter mAdapter;

    private TabLayout mTabLayout;
    private ViewPager mViewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();
    }

    private void initView() {
        mTabLayout = (TabLayout) findViewById(R.id.tab);
        mViewPager = (ViewPager) findViewById(R.id.container);

        //添加标题
        mTitles = new ArrayList<>();
        mTitles.add("报价中");
        mTitles.add("运输中");
        mTitles.add("已完成");

        //添加页面
        mFragmentList = new ArrayList<>();
        mFragment1 = new TabFragment1();
        mFragment2 = new TabFragment2();
        mFragment3 = new TabFragment3();
        mFragmentList.add(mFragment1);
        mFragmentList.add(mFragment2);
        mFragmentList.add(mFragment3);

        //初始化适配器
        mAdapter = new FragmentAdapter(getSupportFragmentManager(),
                mTitles, mFragmentList);
        //设置适配器
        mViewPager.setAdapter(mAdapter);
        //加载viewpager
        mTabLayout.setupWithViewPager(mViewPager);
    }
}

```
### 7. 带icon的tab
效果图如下：
![](/img/article_img/TabLayout+ViewPager-create-tab_icon.gif)

- 1.布局基本没有变，只是在上面的布局基础下，将ViewPager和TabLayout的上下位置调换下。添加如下属性将TabLayout的指示条高度设为0，不可见：
```
app:tabIndicatorHeight="0dp"
```
- 2.为每个tab添加selector。以第一个tab为例，具体如下：
```
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">

    <item android:drawable="@drawable/home_pressed" android:state_selected="true"/>
    <item android:drawable="@drawable/home_normal"/>

</selector>
```
- 3.IconTabActivity中将定义的selector设置为TabLayout的icon:

```
mTabLayout.getTabAt(0).setIcon(getResources().getDrawable(R.drawable.tab_hall_bg));
mTabLayout.getTabAt(1).setIcon(getResources().getDrawable(R.drawable.tab_joined_bg));
mTabLayout.getTabAt(2).setIcon(getResources().getDrawable(R.drawable.tab_me_bg));
```

到此，已经完成了，TabLayout的使用和TabHost的使用类似，但它更为方便，使用起来较为简单。
[Demo下载](https://github.com/imtianx/StudyDemoForAndroid/blob/master/A03-tablayoutdemo)<br>
注：demo中,不带icon:的是MainActivity，带icon的是IconTabActivity。可在AndroidManifest切换运行查看




