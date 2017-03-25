---
title: SQLit相关类的介绍及使用
date: 2016-04-23 16:04:25
categories: [android,SQLit]
tags: [android,SQLit]
---
本文主要介绍了SQLit中相关的几个类（SQLiteDatabase、ContentValues、SQLiteOpenHelper）中的常用的方法及其作用。
<!--more-->
## **1. SQLiteDatabase类**
（对 SQLite数据库增、删、改、查的操作）
 常用方法
```
execSQL(String  sql);
execSQL(String sql, String[] args);
```
示例：删除 person表中personId＝1的记录：
```
SQLiteDatabase db=this.getWritableDatabase();
db.execSQL(“delete from  person where personId=?”,new
String[]{“1”});
db.execSQL(“delete from  person where personId=1”);
```
提示：this是 SQLiteOpenHelper类的实例，该类稍后介绍。
#### 打开数据库
``` 
Context.openOrCreateDatabase(Stringdbname,int mode);
```
作用：打开数据库，若数据库未创建则创建数据库。
参数－dbname：数据库文件名。
参数－mode：访问权限，有以下常量选择：
1、MODE_PRIVATE：不允许其它应用程序访问本数据库。
2、MODE_WORLD_READABLE：允许其它应用程序读本数据库。
3、MODE_WORLD_WRITEABLE：允许其它应用程序写本数据库。
4、MODE_APPEND：若数据库已存在，则允向数据库中许添加数据。


#### 添加
```
long insert(TABLE_NAME, String nullColumnHack, ContentValues   contentValues);
```
作用：添加记录。
参数－TABLE_NAME：表名。
参数－nullColumnHack：若插入的数据是空行，则本参数必须设置为 null。
参数－contentValues：Map类型的数据，每组键－值对代表一列及其该列的数据

#### 删除 
```
int delete(TABLE_NAME, String  where, String[]  whereValue);
```
作用：删除记录。
参数－TABLE_NAME：表名。
参数－where：删除的条件，相当于 SQL语句中的where部分的 SQL命令。
参数－whereValue：符合参数 where的数据。该值是 String[]类型的数组。
示例：删除当前数据库中表peson中，字段 personId值为1的行，代码如下：
```
delete(“person”,”personId=?”,newString[]{“1”});
```
#### 更新
```
int update(TABLE_NAME, contentValues,String  where, String[] whereValue) ;
```
作用：更新记录。
参数－TABLE_NAME：表名。
参数－contentValues：Map类型的数据，每组键－值对代表一列及其该列的数据。可
存放多个键－值对数据，代表需要更新的数据。
参数－where：更新的条件，相当于 SQL语句中的where部分的 SQL命令。
参数－whereValue：符合参数 where的数据。该值是 String[]类型的数组。
示例：更新当前数据库的person表中,personId＝1的记录，代码如下：
```
ContentValues  values=new ContentValues();//创建可存操作的键－值对的对象
values.put(“name”,”李四”);//存放姓名数据
values.put(“phone”,”13315577889”);//存放电话数据
//实例化SQLiteDatabase对象
SQLiteDatabase db=this.getWritableDatabase();
db.update(“person” ,values,”personId=?”，new String[]{“1”);//更新数据
```
#### 查询
```
Cursor rawQuery(String sql,String[]selectionArgs);
```
作用：执行带占位符的 SQL查询，返回的结果集存放在 Cursor对象中。
参数－sql：查询的 SQL命令。
参数－selectionArgs：查询的条件数据。
提示：
(1)Cursor类稍后介绍。
(2)若 sql中没有占位符，则第二个参数设置为 null。
(3)对数据表进行变更操作时，使用execSQL，对数据表进行查询时，使用rawQuery
方法。
```
Cursorquery(table,projection,selection,selectionArgs,groupby,having,orderby);
```
作用：执行带占位符的 SQL查询，返回的结果集存放在 Cursor对象中。
cursor :返回值类型，返回查询结果游标对象。
  table : String ,要查询的表名。
  projection : String[]，要查询的列名，如果为 null，则查询所有列。
  selection : String,查询条件。
  selectionArgs:String[]为selection中的？补值的数组。
  groupby : String,分组列的列名。
  having:String,分组在查询的条件。
  orderby:String排序列的列名。



## 2、ContentValues类
####  概述
ContentValues类包装了HashMap类，该类用于存取键－值对的数据，每个键－值对数
据表示一列的列名和该列的数据。
####  常用方法
```
ContentValues();
```

作用：无参构造方法，创建一个内部成员变量为 HashMap<String,Object>的对象。
```
void put(String key,Object value);
```
作用：向成员变量 mValues中存放一个键－值对数据。
提示：value可以是 Java的所有基本数据类型、数组、对象的类型。
```
Object** get(String key);
```
作用：获取键名 key对应的值。
```
XXX getAsXXX(String key);
```
作用：返回 XXX类型的值。
提示：XXX可以是所有基本类型的包装类，如 Integer，还有AsByteArray（字节数组类型）。


## 3 、SQLiteOpenHelper类
#### 概述
SQLiteOpenHelper类是Android提供的用于操作 SQLite数据库的工具类，该工具类能
方便地创建数据库、表，以及管理数据库版本。
#### 常用方法
```
synchronized SQLiteDatabasegetReadableDatabase();
```
作用：以读写的方式打开数据库对应的 SQLiteDatabase类的对象。
提示：synchronized关键字定义该方法为线程同步。
```
synchronized SQLiteDatabasegetWriteableDatabase();
```
作用：以写的方式创建或打开数据库对应的 SQLiteDatabase类的对象。
```
 abstract onCreate(SQLiteDatabase db);
```
作用：首次创建数据库时，回调本方法。