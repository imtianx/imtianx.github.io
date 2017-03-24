---
title: PhotoView与GifView的使用
date: 2016-04-23 16:11:25
categories: [android,学习笔记]
tags: [android,图片缩放,gif]
---
为了解决图片的缩放和gif格式的图片显示问题，这里采用了开源库PhototView(处理图片缩放问题)和GifView(显示gif格式图片)。<!--more-->
[PhototView下载路径](http://download.csdn.net/detail/txadf/9204419)，[GifView下载路径](http://download.csdn.net/detail/txadf/9204413)，[Demo下载路径](http://download.csdn.net/detail/txadf/9204481)
### 1、PhotoView加载本地图片
```
/**
 * PhotoView 加载本地图片
 */

private ImageView mImageView;
private PhotoViewAttacher mPhotoViewAttacher;

protected void onCreate(Bundle savedInstanceState) {
	super.onCreate(savedInstanceState);
	requestWindowFeature(Window.FEATURE_NO_TITLE);
	setContentView(R.layout.photoview_local);
	mImageView = (ImageView) findViewById(R.id.iv_img);
	mPhotoViewAttacher = new PhotoViewAttacher(mImageView);

	try {
		InputStream inputStream = getAssets().open("testPhotoView.jpg");

		Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
		mImageView.setImageBitmap(bitmap);</span>
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
}
```
	
### 2、PhotoView加载网络图片：
```
/**
 * PhotoView 加载网络图片
 */

private PhotoView mImageView;
private PhotoViewAttacher mPhotoViewAttacher;

private ImageLoader mImageLoader;

private  String URL = "http://pic3.nipic.com/20090525/2416945_231841034_2.jpg";


@Override
protected void onCreate(Bundle savedInstanceState) {
	// TODO Auto-generated method stub
	super.onCreate(savedInstanceState);
	requestWindowFeature(Window.FEATURE_NO_TITLE);
	setContentView(R.layout.photoview_network);

	mImageView = (PhotoView) findViewById(R.id.iv_img);

	mPhotoViewAttacher = new PhotoViewAttacher(mImageView);
	mImageLoader = ImageLoader.getInstance();
	mImageLoader.displayImage(URL, mImageView);

	mImageView.setOnPhotoTapListener(new OnPhotoTapListener() {

		@Override
		public void onPhotoTap(View arg0, float arg1, float arg2) {
			// TODO Auto-generated method stub

		}
	});
}
```
布局文件：
```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical" >

    <uk.co.senab.photoview.PhotoView
        android:id="@+id/iv_img"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent" />

</LinearLayout></span>
```
### 3、GifView加载本地图片：
```
private GifView mGifView;
@Override
protected void onCreate(Bundle savedInstanceState) {
	// TODO Auto-generated method stub
	super.onCreate(savedInstanceState);
	requestWindowFeature(Window.FEATURE_NO_TITLE);
	setContentView(R.layout.gifview);

	mGifView = (GifView) findViewById(R.id.gifview);
	//加载本地图片
	mGifView.setGifImage(R.drawable.gifview);
}
```
布局文件：
```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical" >

    <com.ant.liao.GifView
        android:id="@+id/gifview"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent" />

</LinearLayout></span>
```