---
title: java知识 之 对象及其内存管理
date: 2016-11-19 16:06:25
categories: [java,高级知识]
tags: [java,对象,内存管理]
---
> 读书笔记：《疯狂java 程序员的基本修养》第二章——对象及其内存管理


java中的内存管理分为两个方面：

- **内存分配**：指创建java对象时JVM为该对象在堆空间中所分配的内存空间。
 
- **内存回收**：指java 对象失去引用，变成垃圾时，JVM的垃圾回收机制自动清理该对象，并回收该对象所占用的内存。<!--more-->

虽然JVM 内置了垃圾回收机制，但仍可能导致内存泄露、资源泄露等，所以我们不能肆无忌惮的创建对象。此外，垃圾回收机制是由一个后台线程完成，也是很消耗性能的。

## 1.实例变量和类变量
java程序中的变量，大体可以分为**成员变量**和**局部变量**。其中局部变量可分为如下三类：

- **形参**：在方法名中定义的变量，有方法调用者负责为其赋值，随着方法的结束而消亡。
- **方法内局部变量**：在方法内定义的变量，必须在方法内对其进行初始化。它从初始化完成后开始生效，随着方法结束而消亡。
- **代码块内局部变量**：在代码块内定义的变量，必须在代码块内对其显示初始化。从初始化完成后生效，随着代码块的结束而消亡。

*局部变量的作用时间很短暂，他们被存在栈内存中。*
类体内定义的变量为成员变量。如果使用`static`修饰，则为静态变量或者类变量，否则成为非静态变量或者实例变量。
> **static**:
他的作用是将实例成员编程类成员。只能修饰在类里定义的成员部分，包括变量、方法、内部内（枚举与接口）、初始化块。不能用于修饰外部类、局部变量、局部内部类。

**使用static修饰的成员变量是类类型，属于类本身，没有修饰的属于实例变量，属于该类的实例。在同一个JVM中，每个类可以创建多个java对象。同一个JVM中每个类只对应一个Class对象，机类变量只占一块内存空间，但是实例变量，每次创建便会分配一块内存空间。**

```
class Person
{
	String name;
	int age;
	static int eyeNum;
	public void info()
	{
		System.out.println("我的名字是：" + name
			+ "， 我的年龄是：" + age);
	}
}
public class FieldTest
{
	public static void main(String[] args)
	{
		// 类变量属于该类本身，只要该类初始化完成，
		// 程序即可使用类变量。
		Person.eyeNum = 2; 		  //①
		// 通过Person类访问eyeNum类变量
		System.out.println("Person的eyeNum属性："
			+ Person.eyeNum);
		// 创建第一个Person对象
		Person p = new Person();
		p.name = "猪八戒";
		p.age = 300;
		// 通过p访问Person类的eyeNum类变量
		System.out.println("通过p变量访问eyeNum类变量："
			+ p.eyeNum);           //②
		p.info();
		// 创建第二个Person对象
		Person p2 = new Person();
		p2.name = "孙悟空";
		p2.age = 500;
		p2.info();
		// 通过p2修改Person类的eyeNum类变量
		p2.eyeNum = 3;     		   //③
		// 分别通过p、p2和Person访问Person类的eyeNum类变量
		System.out.println("通过p变量访问eyeNum类变量："
			+ p.eyeNum);
		System.out.println("通过p2变量访问eyeNum类变量："
			+ p2.eyeNum);
		System.out.println("通过Person类访问eyeNum类变量："
			+ Person.eyeNum);
	}
}
```
上述代码中的内存分配如下：

![](/img/article_img/2016/对象内存分配1.png)

当Person类初始化完成，类变量也随之初始化完成，不管再创建多少个Person对象，系统都不再为 eyeNum 分配内存，但会为 name 和age 分配内存并初始化。当eyeNum值改变后，通过每个Person对象访问eyeNum的值都随之改变。

### **a.实例变量的初始化**
对于实例变量，它属于java对象本身，每次程序创建java对象时都会为其分配内存空间，并初始化。
实例变量初始化地方：

- 定义实例化变量时；
- 非静态初始化块中；
- 构造器中。

其中前两种比第三种更早执行，而前两种的执行顺序与他们在程序中的排列顺序相同。它们三种作用完全类似，经过编译后都会提取到构造器中执行，且位于所有语句之前，定义变量赋值和初始化块赋值的顺序与他们在源代码中一致。

可以使用 `javap`命令查看java编译器的机制：
```
用法: javap <options> <classes>
其中, 可能的选项包括:
-help  --help  -?        输出此用法消息
-version                 版本信息
-v  -verbose             输出附加信息
-l                       输出行号和本地变量表
-public                  仅显示公共类和成员
-protected               显示受保护的/公共类和成员
-package                 显示程序包/受保护的/公共类
                       和成员 (默认)
-p  -private             显示所有类和成员
-c                       对代码进行反汇编
-s                       输出内部类型签名
-sysinfo                 显示正在处理的类的
                       系统信息 (路径, 大小, 日期, MD5 散列)
-constants               显示最终常量
-classpath <path>        指定查找用户类文件的位置
-cp <path>               指定查找用户类文件的位置
-bootclasspath <path>    覆盖引导类文件的位置
```

### **b.类变量的初始化**
类变量属于java 类本身，每次运行时才会初始化。
类变量的初始化地方：

- 定义类变量时初始化；
- 静态代码块中初始化

如下代码，表面上看输出的是：17.2,17.2；但是实际上输出的是：-2.8,17.2
```
class Price
{
    // 类成员是Price实例
    final static Price INSTANCE = new Price(2.8);
    // 在定义一个类变量。
    static double initPrice = 20;
    // 定义该Price的currentPrice实例变量
    double currentPrice;
    public Price(double discount)
    {
        // 根据静态变量计算实例变量
        currentPrice = initPrice - discount;
    }
}
public class PriceTest
{
    public static void main(String[] args)
    {
        // 通过Price的INSTANCE访问currentPrice实例变量
        System.out.println(Price.INSTANCE.currentPrice);//输出：-2.8
        // 显式创建Price实例
        Price p = new Price(2.8);
        // 通过先是创建的Price实例访问currentPrice实例变量
        System.out.println(p.currentPrice);            //输出：17.2
    }
}
```
第一次使用Price 时，程序对其进行初始化，可分为两个阶段：
（1）系统为类变量分配内存空间；
（2）按初始化代码顺序对变量进行初始化。

这里的运行结果为：-2.8,17.2
**说明**：初始化第一阶段，系统先为 INSTANCE，initPrice两个类变量分配内存空间，他们的默认值为null和0.0，接着第二阶段依次为他们赋值。对 INSTANCE 赋值时要调用 Price(2.8),创建Price实例，为currentPrice赋值，此时，还未对 initPrice 赋值，就是用他的默认值0，则 currentPrice 值为-2.8，接着程序再次将 initPrice 赋值为20，但对于 currentPrice 实例变量已经不起作用了。

以下为在ide中的debug结果截图：

![](/img/article_img/2016/对象内存分配-debug.png)


## 2.父类构造器

java中，创建对象时，首先会依次调用每个父类的非静态初始化块、构造器（总是先从Object开始），然后再使用本类的非静态初始化块和构造器进行初始化。在调用父类时可以用`super`进行**显示调用**，也可以**隐式调用**。

在子类调用父类构造器时，有以下几种场景：

- 子类构造器第一行代码是用**super()**进行显示调用父类构造器，则根据super传入的参数调用相应的构造器；
- 子类构造器第一行代码是用**this()**进行显示调用本类中重载的构造器，则根据传入this的参数调用相应的构造器；
- 之类构造器中没有this和super,则在执行子类构造器前，隐式调用父类无参构造器。

> 注：super和this都是显示调用构造器，只能在构造器中使用，且必须在第一行，只能使用它们其中之一，最多只能调用一次。


一般情况下，子类对象可以访问父类的实例变量，但父类不能访问子类的，因为父类不知道它会被哪个子类继承，子类又会添加怎样的方法。但在极端的情况下，父类可以访问子类变量的情况，如下实例代码：
```
package cn.imtianx.p02;

class Base {
    private int i = 2;
    public Base() {
        this.display();//this：运行时是Driver类型，编译时是Base 类型，这里是Driver对象
    }
    public void display() {
        System.out.println(i);
    }
}

// 继承Base的Derived子类
class Derived extends Base {
    private int i = 22;
    public Derived() {
        i = 222;
    }
    public void display() {
        System.out.println(i);
    }
}
public class Test {
    public static void main(String[] args) {
        // 创建Derived的构造器创建实例
        new Derived();
    }
}
```
上面的代码执行后，输出的并不是2、22或者222，而是**0**。在调用Derived 的构造器前会隐式调用Base的无参构造器，初始化 i= 2，此时如果输出`this.i`则为2，它访问的是Base 类中的实例变量，但是当调用`this.display()`时，表现的为Driver对象的行为，对于driver对象，它的变量i还未赋初始值，仅仅是为其开辟了内存空间，其值为0。

**在java 中，构造器负责实例变量的初始化（即，赋初始值），在执行构造器前，该对象内存空间已经被分配了，他们在内存中存的事其类型所对应的默认值。**

**在上面的代码中，出现了变量的编译时类型与运行时类型不同。通过该变量访问他所引用的对象的实例变量时，该实例变量的值由申明该变量的类型决定的，当通过该变量调用它所引用的实例对象的实例方法时，该方法将由它实际所引用的对象来决定**

当子类重写父类方法时，也会出现父类调用之类方法的情形，如下具体代码，通过上面的则很容易理解。
```
class Animal
{
	private String desc;
	public Animal()
	{
		this.desc = getDesc();       
	}
	public String getDesc()
	{
		return "Animal";
	}
	public String toString()
	{
		return desc;
	}
}
public class Wolf extends Animal
{
	private String name;
	private double weight;
	public Wolf(String name , double weight)
	{
		this.name = name;
		this.weight = weight;
	}
	// 重写父类的getDesc()方法
	@Override
	public String getDesc()
	{
		return "Wolf[name=" + name + " , weight="
			+ weight + "]";  //输出：Wolf[name=null , weight=0.0]
	}
	public static void main(String[] args)
	{
		System.out.println(new Wolf("灰太狼" , 32.3)); 
	}
}
```

## 3.父子实例的内存控制

java中的继承，在处理成员变量和方法时是不同的。如果之类重写了父类的方法，则完全覆盖父类的方法，并将其其移到子类中，但如果是完全同名的实例变量，则不会覆盖，不会从父类中移到子类中。所以，对于一个引用类型的变量，如果访问他所引用对象的实例变量时，该实例变量的值取决于申明该变量的类型，而调用方法时，则取决于它实际引用对象的类型。

在继承中，内存中子类实例保存有父类的变量的实例。

```
class Base {
    int count = 2;
}
class Mid extends Base {
    int count = 20;
}
public class Sub extends Mid {
    int count = 200;
    public static void main(String[] args) {
        // 创建一个Sub对象
        Sub s = new Sub();
        // 将Sub对象向上转型后赋为Mid、Base类型的变量
        Mid s2m = s;
        Base s2b = s;
        // 分别通过3个变量来访问count实例变量
        System.out.println(s.count);    //输出：200
        System.out.println(s2m.count);    //输出：20
        System.out.println(s2b.count);    //输出：2
    }
}
```
内存中的示意图：

![](/img/article_img/2016/对象内存分配2.png)

在内存中只有一个Sub对象，并没有Mid和Base对象，但存在3个count的实例变量。

**子类中会隐藏父类的变量可以通过super来获取,对于类变量，也可以通过super来访问。**

## 4.final 修饰符

final 的修饰范围：

- 修饰变量，被赋初始值后不可重新赋值；
- 修饰方法 ，不能被重写；
- 修饰类，不能派生出子类。

对于final 类型的变量，初始化可以在：定义时、非静态代码块和构造器中；对于final 类型的类变量，初始化可以在：定义时和静态代码块中。

> 当final类型的变量定义时就指定初始值，那么该该变量本质上是一个“宏变量”，编译器会把用到该变量的地方直接用其值替换。

如果在内部内中使用局部变量，必须将其指定为final类型的。普通的变量作用域就是该方法，随着方法的执行结束，局部变量也随之消失，但内部类可能产生隐式的“闭包”，使局部变量脱离它所在的方法继续存在。内部内可能扩大局部变量的作用域，如果内部内中访问的局部变量没有适用final修饰，则可以随意修改它的值，这样将会引起混乱，所以编译器要求被内部访问的局部变量必须使用final 修饰。





