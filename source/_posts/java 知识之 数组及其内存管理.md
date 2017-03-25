---
title: java知识 之 数组及其内存管理
date: 2016-11-17 16:06:25
categories: [java,高级知识]
tags: [java,数组,内存管理]
---


> 读书笔记：《疯狂java 程序员的基本修养》第一章——数组及其内存管理

## 1.数组初始化
数组是一个复合数据结构，当需要多个类型相同的变量时，可以定义数组惊醒使用。在java中，数组变量是一个引用类型的变量。<!--more-->
java 中的数组是**静态的**，即初始化后，它索占的内存空间、数组长度是不变的。而且必须先**初始化**后使用。

**数组的初始化方式：**

- **静态初始化：**初始化是指定数组的元素的值，由系统决定其长度。
```
String[] datas = new String[]{"java","C++","html"};
```

- **动态初始化:**指定长度，由系统为数组元素分配初始值。
```
String[] datas = new String[5];//指定长度为5，系统为每个元素指定初始值为null
```
初始值分配规则：

| 数组类型| 初始化值 |
| :------ | :-----:  |
| byte、short、long| 0 |
|float、double | 0.0 |
|char | '\u0000' |
|boolean | false |
|引用类型（类、接口） | null |

*注：不要同时使用静态和动态初始化，即同时指定数组长度和元素初始值*

## 2.数组的内存分析
如下定义三个数组并初始化：
```
//1.静态初始化一
String[] books = new String[]{
        "疯狂java 讲义",
        "轻量级javaee企业应用实战",
        "疯狂ajax讲义",
        "疯狂XNL讲义"
};
System.out.println("第一个数组的长度为：" + books.length);// 4
//2.静态初始化二
String[] names = {
        "孙悟空",
        "猪八戒",
        "白骨精"
};
System.out.println("第二个数组的长度为：" + names.length);// 3
//3.动态初始化
String[] strArr = new String[5];
System.out.println("第三个数组的长度为：" + strArr.length); // 5
```
上面采用两种静态和一种动态方式初始化数组，其长度分别为4、3、5，其内存分配如下：

![](/img/article_img/2016/数组内存分配1.png)


数组变量存在栈区，数组对象存在堆内存，只能通过引用来访问堆内存中的数据。

数组一旦初始化完成后，其内存空间即分配结束，无法改变其长度，但可以修改其元素的值。但数组是一中引用类型的变量，他只是指向对内存中的数组对象，可以改变其引用，从而造成其长度可变的假象，如下：

```
books = names;
System.out.println("books数组的长度为：" + books.length);
strArr = names;
System.out.println("strArr数组的长度为：" + strArr.length);
books[1] = "唐僧";
System.out.println("snames的第三个元素：" + books[1]);
```
>输出结果为：
books数组的长度为：3
strArr数组的长度为：3
strArr数组的长度为：唐僧

books原本长度为4，现在打印出来的是3，这里只是其引用变了导致的，原来books变量引用的数组长度依然是4，只是没有任何引用了，将会被GC回收。内存变化如下：

![](/img/article_img/2016/数组内存分配2.png)

**java 中的数组变量只是引用变量，他并不是数组的本身，只要让数组变量指向有效的数组对象，即可使用该数组变量.**

```
 int[] nums = new int[]{3,5,20,12};
int[] prices;
prices = nums;//prices 未初始化，但将其指向nums所引用的数组
for (int i = 0; i < prices.length; i++) {
    System.out.println(prices[i]);
}
//为prices第三个元素赋值
prices[2] = 34;
System.out.println("nums数组第三个元素为："+nums[2]);//输出34
```
prices数组并没有初始化，但可以使用，执行`prices = nums;`后，他们指向相同的数组对象，是等价的，因此，修改prices的数组元素值，nums的也会随之改变。**对于数组，只要让其指向有效的数组对象，即可使用该变量。**

> 注意： 引用变量本质上是一个指针，只要通过引用变量访问属性或调用方法，该引用变量就会由它所引用的对象替换。

## 3.引用类型数组初始化
引用类型的数组元素依然是一用类型的，它存储的是引用，指向另一块内存，该内存中存储了引用变量所引用的对象（包括数组和java对象）。

定义一个Person类，用于定义改类型的数组：
```
public class Person {
    public int age;
    public double height;

    public void printInfo() {
        System.out.println("年龄是：" + age + ", 身高是：" + height);
    }
}
```
定义person数组：
```
Person[] students;
students = new Person[2];
System.out.println("students数组长度：" + students.length);
Person zhang = new Person();
zhang.age = 12;
zhang.height = 158;

Person lee = new Person();
lee.age = 16;
lee.height = 161;

students[0] = zhang;
students[1] = lee;

//lee和students[1]指向同一个person的实例，以下两句执行效果一样
lee.printInfo();
students[1].printInfo();
```
上述数组内存分配图：

![](/img/article_img/2016/数组内存分配3.png)

student数组的两个元素相当于两个引用，分别指向zhang和lee,lee和studentd[1]是指到同一个对象的，同一块内存，有相同的效果。

## 4.数组的使用
当定义一个数组，初始化后就相当于定义了多个相同类型的变量。通过索引使用数组元素时，可将其作为普通变量的使用。
```
class Cat
{
	double weight;
	int age;
	public Cat(double weight , int age)
	{
		this.weight = weight;
		this.age = age;
	}
}
public class ArrayTest
{
	public static void main(String[] args)
	{
		// 定义，并动态初始化一个int[]数组
		int[] pos = new int[5];
		// 采用循环为每个数组元素赋值
		for (int i = 0; i < pos.length ; i++ )
		{
			pos[i] = (i + 1) * 2;
		}
		// 对于pos数组的元素来说，用起来完全等同于普通变量
		// 下面即可将数组元素的值赋给int变量，
		// 也可将int变量的值赋给数组元素
		int a = pos[1];
		int b = 20;
		pos[2] = b;             
		// 定义，并动态初始化一个Cat[]数组
		Cat[] cats = new Cat[2];
		cats[0] = new Cat(3.34, 2);
		// 将cats数组的第1个元素的值赋给c1。
		Cat c1 = cats[0];
		Cat c2 = new Cat(4.3, 3);
		// 将c2的值赋给cats数组的第2个元素
		cats[1] = c2;             
	}
}
```
上述代码中，相关的内存分配图示意图：

![](/img/article_img/2016/数组内存分配4.png)

## 5.多维数组
对于 `int`类型，添加 `[]`后就是一个数组类型，若以`int[]`类型为已有类型，则增加一个`[]`,`int[][]`，也是一个数组类型。因此，所谓的多维数组，其数组元素依然是一个数组，即N维数组，是数组元素为N-1维数组的一维数组。
如下示例：
```
int[][] a = new int[4][];
a[0] = new int[2];
a[0][1] = 6;
```
内存空间分配图：

![](/img/article_img/2016/数组内存分配5.png)

如果将其扩展成三维数组，则6所对应的数组元素指向两一个数组。

**多维数组的本质是一维数组。**




