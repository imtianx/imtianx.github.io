---
title: 天盾app项目总结
date: 2016-010-23 21:48:25
categories: [android,项目总结]
tags: [拍照oom,图片错位,xutils3]
---

经过几个星期的努力，天盾app2.0版正式发布。再次记录下自己在开发中遇到的问题：

 1. 拍照图片oom
 2. listview 图片错位
 3. xutils 数据库的使用与升级
<!--more-->

### 1. 拍照显示图片oom
由于该app中有快递单的采集，用RecyclerView 展示，并且每条可能需要拍照录入三张图片，这些图片需要显示并保存到文件便于上传。
目前，各个各个手机拍照后生成的图片比较大，分辨率也很高，直接显示很容易出现oom,使用BitmapFactory创建bitmap显示图片，每次使用都会分配内存，通过设置它的**采样率**，以避免。通过使用下面的工具类来加载图片：
```
public class BitmapUtil {
private static final boolean DEBUG = false;
private static final String TAG = BitmapUtil.class.getSimpleName();

private BitmapUtil() {
    throw new Error("Do not need instantiate!");
}

/**
 * 图片压缩处理（使用Options的方法）
 * <p/>
 * @param reqWidth  目标宽度
 * @param reqHeight 目标高度
 */
public static BitmapFactory.Options calculateInSampleSize(
        final BitmapFactory.Options options, final int reqWidth,
        final int reqHeight) {
    // 源图片的高度和宽度
    final int height = options.outHeight;
    final int width = options.outWidth;
    int inSampleSize = 1;
    if (height > 400 || width > 450) {
        if (height > reqHeight || width > reqWidth) {
            // 计算出实际宽高和目标宽高的比率
            final int heightRatio = Math.round((float) height
                    / (float) reqHeight);
            final int widthRatio = Math.round((float) width
                    / (float) reqWidth);
            // 选择宽和高中最小的比率作为inSampleSize的值，这样可以保证最终图片的宽和高
            // 一定都会大于等于目标的宽和高。
            inSampleSize = heightRatio < widthRatio ? heightRatio
                    : widthRatio;
        }
    }
    // 设置压缩比例
    options.inSampleSize = inSampleSize;
    options.inJustDecodeBounds = false;
    return options;
}



/**
 * 获取一个指定大小的bitmap
 *
 * @param reqWidth  目标宽度
 * @param reqHeight 目标高度
 */
public static Bitmap getBitmapFromFile(String pathName, int reqWidth,
                                       int reqHeight) {
    BitmapFactory.Options options = new BitmapFactory.Options();
    options.inJustDecodeBounds = true;
    BitmapFactory.decodeFile(pathName, options);
    options = calculateInSampleSize(options, reqWidth, reqHeight);
    return BitmapFactory.decodeFile(pathName, options);
}
}
```
这里只列出了计算采样率和从文件中加载显示的方法，如需了解更多该工具，请[点击此处查看](https://github.com/l123456789jy/Lazy/blob/master/lazylibrary/src/main/java/com/github/lazylibrary/util/BitmapUtil.java)
具体使用如下：
```
int width = mImageView.getWidth();
int height = mImageView.getHeight();
//picPath 为图片存储路径
mImageView.setImageBitmap(BitmapUtil.getBitmapFromFile(picPath, width, height));
```
进过测试，连续拍照10多张并显示，内存的消耗物明显变化，大约有2M的多动，测试手机为Nexus 6,至此，oom完美解决，性能也十分好。

### 2. Listview 加载网络图片错位
在app登陆前，需要选择相应的快递和分部，而快递列表的设计是显示快递图片和快递公司名称，该部分数据是由网络获取的，展示在listView中。当图片地址为空时，无图片的item就会显示其他的图片，而且随着屏幕的滚动而变化，出现错位的现象。这种情况**主要是由于ListView适配器 中getView的convertView复用导致的，解决办法是为imageview设置tag标记，这里以图片的url作为标记。**如下，getView的代码：
```
@Override
public View getView(int position, View convertView, ViewGroup parent) {
    ViewHolder holder;
    if (convertView == null) {
        convertView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_item_express, parent, false);
        holder = new ViewHolder(convertView);
        convertView.setTag(holder);
    } else {
        holder = (ViewHolder) convertView.getTag();
    }

    String imgUrl = mDatas.get(position).getExpressIco();
    holder.imgExpressIcon.setTag(imgUrl);

	//这里注意图片地址的判断，被 "" 坑了好久
    if (holder.imgExpressIcon.getTag() == null || holder.imgExpressIcon.getTag().equals("")) {
		//若无网络图片，显示错误图片
        holder.imgExpressIcon.setImageResource(R.drawable.express_error);
    } else if (holder.imgExpressIcon.getTag().equals(imgUrl)) {
        x.image().bind(holder.imgExpressIcon, Constants.BASE_URL + imgUrl);
    }
    holder.tvExpressName.setText(mDatas.get(position).getExpressName());

    return convertView;
}
```

### 3. xutils3 数据库的使用与升级
为了节省流量，将采集的数据保存在本地，便于在wifi情况下同一上传，只有该功能需要数据库，加上项目中使用的有xutils，带有数据库模块，便没有自己写或者使用 GreenDao，Ralem等其他的数据库框架。
此处简单的记录下改数据库框架的使用。

- 在Application中配置
在自己的application类（或者使用的activity）中添加配置信息，这里为了方便，在Application类中添加，并通过单利类访问使用。
如下部分代码：
```
public class SNApplication extends Application {

    private static DbManager.DaoConfig mDaoConfig = null;

    /**
     * 获取数据库配置对象
     *
     * @return
     */
    public static DbManager.DaoConfig getDaoConfig() {
        if (mDaoConfig == null) {
            mDaoConfig = new DbManager.DaoConfig()
                    .setDbName("ygjexpress.db")
                    .setDbVersion(2)
                    .setDbOpenListener(new DbManager.DbOpenListener() {
                        @Override
                        public void onDbOpened(DbManager db) {
                            // 开启WAL, 提升写入速度
                            db.getDatabase().enableWriteAheadLogging();
                        }
                    })
                    .setDbUpgradeListener(new DbManager.DbUpgradeListener() {
                        @Override
                        public void onUpgrade(DbManager db, int oldVersion, int newVersion) {
                            //升级数据库
                            try {
								//添加 user_id ，避免同一手机登陆多个账号出现数据混乱
                                db.addColumn(PickupDbItem.class,"user_id");
                            } catch (DbException e) {
                                e.printStackTrace();
                            }
                        }
                    });

        }
        return mDaoConfig;
    }
}
```
- 创建数据表对应的实体类
通过注解，来指定数据表名（Table）和字段名（Column），isId 指定是否为id,property设置是否唯一。
```
@Table(name = "pickup_item")
public class PickupDbItem {
    @Column(name = "id", isId = true)
    private int id;
    @Column(name = "sender_idcrad_id")
    private String senderIdcradID;//身份证id
    @Column(name = "express_no")
    private String expressNo;//快递编号
    @Column(name = "pic_bale_before")
    private String picBaleBefore;//打包前
    @Column(name = "pic_bale_after")
    private String picBaleAfter;//打包后图片
    @Column(name = "pic_bale_complete")
    private String picBaleComplete;//贴快递单后图片

    @Column(name = "user_id")
    private String userId; //当前登录的用户id

   //此处省略构造方法和getter和setter方法
```
- 具体的使用
```
//获取数据库配置
private static DbManager mDbManager = x.getDb(SNApplication.getDaoConfig());
//插入一条
 mDbManager.save(pickupDbItem);
 //查找-条
 pickupDbItem = mDbManager.selector(PickupDbItem.class)
                        .where("express_no", "=", expressNo)
                        .findFirst();
//查找所有
mDbManager.selector(PickupDbItem.class).findAll();
//更新三个字段
 mDbManager.update(pickupDbItem, "sender_idcrad_id", "pic_bale_before", "pic_bale_after", "pic_bale_complete");
 //删除
 mDbManager.delete(pickupDbItem);
```
用法很简单，负责的查询条件可以使用`WhereBuilder`类来构造。更多的请参见[此处](https://github.com/imtianx/xUtils3/blob/master/sample/src/main/java/org/xutils/sample/DbFragment.java)。

-  数据库的升级

在配置文件中**增加版本号，在 setDbUpgradeListener 中的 onUpgrade 方法中添加或删除列，最后在实体中添加相应的字段即可**。

项目比较小，遇到的问题也就这些，需要查看该app的，请访问[内测平台](https://www.pgyer.com/ygjexpress)


