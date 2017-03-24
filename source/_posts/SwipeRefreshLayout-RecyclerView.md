---
title: SwipeRefreshLayout+RecyclerView实现下拉刷新
date: 2016-04-23 16:36:25
categories: [android,学习笔记]
tags: [5.X新特新,RecyclerView,CardView]
---
SwipeRefreshLayout+RecyclerView实现下拉刷新
另外还使用了CardView（一个容器类布局，它继承自FrameLayout）。<br/><!--more-->
效果图如下：
![这里写图片描述](http://img.blog.csdn.net/20160411115226554)


## 具体的使用：

#### 1.CardView<br>
首先，引入依赖：<br>
	```
	compile 'com.android.support:cardview-v7:23.3.0'
	```
 接着，在布局中引用，需要添加新的名字空间<br>
	```
	xmlns:card_view="http://schemas.android.com/apk/res-auto"
	```
 通过名字空间添加两个新的属性,通过名字很容易知道，第一个是设置背景颜色，第二个是设置圆角<br>
	```
	card_view:cardBackgroundColor="#b911e8"
	card_view:cardCornerRadius="4dp"
	```
这里，RecyclerView 的每一个item都是一个CardView<br><br>
####  2.SwipeRefreshLayout
它在V4 包下，使用代码如下：[activity_main.xml](https://github.com/imtianx/StudyDemoForAndroid/blob/master/A02-swrvdemo%2Fsrc%2Fmain%2Fres%2Flayout%2Factivity_main.xml)
	
```
<?xml version="1.0" encoding="utf-8"?>
<android.support.v4.widget.SwipeRefreshLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/swipe_container"
android:layout_width="match_parent"
android:layout_height="match_parent">

<android.support.v7.widget.RecyclerView
android:layout_width="match_parent"
android:layout_height="wrap_content"
android:id="@+id/relv">
</android.support.v7.widget.RecyclerView>

</android.support.v4.widget.SwipeRefreshLayout>
```
在activity中设置相关的方法：
```
//设置进度条颜色,最多可以有四个颜色
setColorSchemeResources(int… colorResIds);
//设置进度圈背景颜色
setProgressBackgroundColorSchemeColor(int color);
//设置监听,在OnRefresh()中处理结果
setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener);
//设置刷新状态
setRefreshing(Boolean refreshing);
```

####  3.RecyclerView

它是谷歌对ListView的升级，效率更高，并对ViewHolder进行了封装。使用时，同样，需要依赖库:
```
compile 'com.android.support:recyclerview-v7:23.3.0'
```
编写自己的adapter，继承自 RecyclerView.Adapter ，实现三个方法：(具体内容见：[RvAdapter.java](https://github.com/imtianx/StudyDemoForAndroid/blob/master/A02-swrvdemo%2Fsrc%2Fmain%2Fjava%2Fcn%2Fimtianx%2Fswrvdemo%2FRvAdapter.java))
```
/**
 * 将布局转换成view 并传递给RecyclerView 封装好的 ViewHolder
 *
 * @param parent
 * @param viewType
 * @return
 */
@Override
public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
    View view = LayoutInflater.from(parent.getContext()).inflate(
            R.layout.rv_item_cardview, parent, false);
    return new ViewHolder(view);
}

/**
 * 建立ViewHolder中视图与数据的关联
 *
 * @param holder
 * @param position
 */
@Override
public void onBindViewHolder(ViewHolder holder, int position) {
    holder.imageView.setImageResource(R.mipmap.img);
    holder.textView.setText(datas.get(position));
}  
```


添加内部内ViewHolder继承自RecyclerView.ViewHolder, 由于android没有给RecyclerView设置点击事件，需要我们自己使用接口回调，设置监听。
```
public class ViewHolder extends RecyclerView.ViewHolder
{
    public ImageView imageView;
    public TextView textView;

    public ViewHolder (final View itemView)
    {
        super (itemView);
        imageView = (ImageView) itemView.findViewById (R.id.img_head);
        textView = (TextView) itemView.findViewById (R.id.tv_title);

        itemView.setOnClickListener (new View.OnClickListener()
        {
            @Override
            public void onClick (View v)
            {
                itemClickListener.onItemClick (v, getPosition() );
            }
        });

        textView.setOnClickListener (
            new View.OnClickListener()
        {
            @Override
            public void onClick (View v)
            {
                if (itemClickListener != null)
                {
                    itemClickListener.onTextClick (v, getPosition() );
                }
            }
        });
    }
}

public OnItemClickListener itemClickListener;

/**
 * 设置接口
 *
 * @param itemClickListener
 */
public void setItemClickListener (OnItemClickListener itemClickListener)
{
    this.itemClickListener = itemClickListener;
}

/**
 * 点击事件接口
 */
public interface OnItemClickListener
{
    //item的点击事件
    void onItemClick (View view, int position);
    //item中文字的点击事件
    void onTextClick (View view, int position);
}
```
最后在activity中设置监听，具体见：[MainActivity.java](https://github.com/imtianx/StudyDemoForAndroid/blob/master/A02-swrvdemo/src/main/java/cn/imtianx/swrvdemo/MainActivity.java)

 **[demon地址](https://github.com/imtianx/StudyDemoForAndroid/tree/master/A02-swrvdemo)**