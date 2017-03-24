---
title: ScrollView嵌套ListView的解决方案
date: 2016-04-23 16:29:25
categories: [android,学习笔记]
tags: [ScrollView,ListView]
---
在android开发中，有时会遇到ScrollView嵌套ListView的相关问题，然而直接使用ScrollView 嵌套ListView，会导致界面卡顿无法滚动，或者listview只希显示1行（设置lisview的高度为400dp课以解决）。<!--more-->网上也有不同的解决方案，但主要有以下几种。
### 1、不使用ScrollView

这种做法是直接将scrollview中除lisview的部分单独写到一个布局文件中，将其加入到listview的头部（即：position==0 的位置）。
```
listView.addHeaderView(LayoutInflater.from(getApplicationContext()).
					inflate(R.layout.list_top_view, null));
或者在adapter的getview中加：
if(position==0)
{
        convertView = LayoutInflater.from(context).inflate(R.layout.list_top_view, null);
	return convertView;
}
```
注：“这种方法不推荐使用，使用它就破会listview 使用ViewHolder的结构，不能达到优化的目的。
### 2、动态测量ListView

在执行完listView.setAdapter(myAdapter);后调用下面的方法；
```
	/** 动态设置ListView的高度
	 * @param listView
	 */
	public  void setListViewHeightBasedOnChildren(ListView listView) {
		if(listView == null) return;
		ListAdapter listAdapter = listView.getAdapter();
		if (listAdapter == null) {
			return;
		}
		int totalHeight = 0;
		for (int i = 0; i < listAdapter.getCount(); i++) {
			View listItem = listAdapter.getView(i, null, listView);
			listItem.measure(0, 0);
			totalHeight += listItem.getMeasuredHeight();
		}
		ViewGroup.LayoutParams params = listView.getLayoutParams();
		params.height = totalHeight + (listView.getDividerHeight() * (listAdapter.getCount() - 1));
		listView.setLayoutParams(params);
	}
}
```
但是这样，界面显示的是以listview开始的，他上的内容不会显示，需手动设置ScrollView定位到顶部，或者让listview失去焦点（listView.setFocusable(false);）也可显示顶部内容。
scrollView定位到顶部代码：
```
scrollView.smoothScrollTo(0, 20);
scrollView.fullScroll(ScrollView.FOCUS_UP);//此处无效
scrollView.scrollTo(0, 0);//此处无效
```
注：这种方法不用更改控件，但是它必须要求getview返回的view的布局是LinearLayout的，否则会抛出异常，而且使用时，会把所有lisview的所有item 绘制出来。
### 3、自定义ListView

自定义listview，继承自ListView，添加原有的三个构造方法，重写onMeasure() 方法，在布局文件处使用自定义的Listview，具体代码如下：
```
import android.content.Context;
import android.util.AttributeSet;
import android.widget.ListView;

public class MyListView extends ListView {

	public MyListView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}
	public MyListView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}
	public MyListView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
	}

	/**
	 * 重写原方法，使ListView适应ScrollView的效果
	 */
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2,
				MeasureSpec.AT_MOST);
		super.onMeasure(widthMeasureSpec, expandSpec);
	}
}
```
注：这种方法使用起来较为方便，它保正了lisview的所有方法，个人就是这样用的。
除此之外，还有使用linearLayout替代lisview，个人没有进行测试，感兴趣的的可以尝试下。对上面的各种方法，个人都经过测试，进行事件的监听也不会出先问题，可以放心使用。
