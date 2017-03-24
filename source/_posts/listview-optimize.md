---
title: ListView的优化技巧
date: 2016-04-23 16:30:25
categories: [android,学习笔记]
tags: [Listview,性能优化]
---
在实际的应用开发时，往往有很多地方需要使用listview,当然我们得了解它的一些技巧。<!--more-->
### 1.ListView的优化技巧

主要使用ViewHolder来提高效率，利用它的视图缓存机制，避免每次在调用方getView()方法时通过findViewById()实例化控件。使用时，只需在自定义的adapter中定义内部类ViewHolder，将ListView的item中的控件作为其成员变量。

如下getView()方法：
 ```
	@Override
	   public View getView(int position, View convertView, ViewGroup parent) {
	     ViewHolder holder = null;
	       // 判断是否缓存
	       if (convertView == null) {
	           holder = new ViewHolder();
	           // 通过LayoutInflater实例化布局
	           convertView = mInflater.inflate(R.layout.notify_item, null);
	           holder.img = (ImageView) convertView.findViewById(R.id.imageView);
	           holder.title = (TextView) convertView.findViewById(R.id.textView);
	           convertView.setTag(holder);
	       } else {
	           // 通过tag找到缓存的布局
	           holder = (ViewHolder) convertView.getTag();
	       }
	       // 设置布局中控件要显示的视图
	       holder.img.setBackgroundResource(R.drawable.ic_launcher);
	       holder.title.setText(mData.get(position));
	       return convertView;
	   }
	//定义内部类
	   public final class ViewHolder {
	       public ImageView img;
	       public TextView title;
	   }
    ```
### 2.ListView的常用属性

设置分割线
```
android:divider="@null"
```
隐藏滚动条
```
android:scrollbars="none"
```
设置要显示在第N项
```
//瞬间完成
listView.setSelection(N);
//平滑完成
listView.smoothScrollBy(distance,duration);
listView.smoothScrollByOffset(offset);
listView.smoothScrollToPosition(n);
```
动态修改
```
//改变llist后调用
mAdapter.notifyDataSetChanged();
```
### 3.动态改变ListView的布局

如：实现聊天界面，加载连个布局的。
主要是比普通的adapter多实现getItemViewType()和getViewType()两个方法，然后再getView()中作出相应的处理。
如下部分主要代码：
```
//返回第position个item是何种类型
    @Override
    public int getItemViewType(int position) {
        ChatItemListViewBean bean = mData.get(position);
        return bean.getType();
    }

	//返回不同布局的总数
    @Override
    public int getViewTypeCount() {
        return 2;
    }</span>
	
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
			//判断布局类型
            if (getItemViewType(position) == 0) {
                holder = new ViewHolder();
                convertView = mInflater.inflate(
                        R.layout.chat_item_itemin, null);
                holder.icon = (ImageView) convertView.findViewById(
                        R.id.icon_in);
                holder.text = (TextView) convertView.findViewById(
                        R.id.text_in);
            } else {
                holder = new ViewHolder();
                convertView = mInflater.inflate(
                        R.layout.chat_item_itemout, null);
                holder.icon = (ImageView) convertView.findViewById(
                        R.id.icon_out);
                holder.text = (TextView) convertView.findViewById(
                        R.id.text_out);
            }
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.icon.setImageBitmap(mData.get(position).getIcon());
        holder.text.setText(mData.get(position).getText());
        return convertView;
    }
```
此外，ListView还能设置滑动监听，有OnTouchListener和OnScrollListener监听事件。






