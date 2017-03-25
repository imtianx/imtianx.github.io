---
title: java 知识 之 内存管理
date: 2016-11-24 16:06:25
categories: [java,高级知识]
tags: [java,内存回收]
---
> 读书笔记：《疯狂java 程序员的基本修养》第四章——java内存管理



java 中的内存管理包括内存分配和内存回收，这些都是由 JVM 帮我们完成的。当创建对象时为其分配内存空间；当失去引用时，GC会自动清除并回收他们所占用的空间。
<!--more-->

## 一、java 引用的种类

当java对象创建完后，垃圾回收机制会实时的监测每个对象的状态，包括对象的申请、引用、被引用。赋值等。当它不存在引用时，对其进行回收。

当一个对象在堆内存中运行时，根据它对应的有向图的状态，有如下三种状态：

- 可达状态
 当一个对象被创建后，有一个以上的引用变量引用他，在有向图中可以从起点导航到该点，此时可以通过引用变量调用它的属性和方法。
- 可恢复状态
  程序中不再有任何对象引用变量引用它，此时不能从有向图的起点到达它。系统准备回收，再回收之前系统会调用该对象的`finalize()`方法进行资源清理，如果在finalize 中重新让一个及以上的引用变量引用该对象，则它会再次变为可达状态，否则，进入不可达状态。
- 不可达状态
  所有的关联都被切断，永久性的失去引用，只有在该状态下系统才会真正的回收对象所占用的资源。

三张状态转换图如下：

![](/img/article_img/2016/object_state.png)



### **a. 强引用**

在java  中，创建一个对象，并把它赋值给一个引用变量，就是强引用。**被强引用所引用的对象时绝对不会被垃圾回收机制回收的，即使系统非常紧张**，因此它是造成内存泄露的主要原因之一。

### **b. 软引用**
软引用需要用`SoftReference`类来实现，当一个对象只有软引用时，它有可能被回收。对于软引用，**当系统内存空间足够时，不会被回收，否则会被系统回收，该对象不可再被使用**。
软引用是强引用很好的替代，他能避免系统内存不足的异常。具体的使用如下（其中Person类有两个属性和一个tostring方法）：
```
public class SoftReferenceTest {
    public static void main(String[] args)
            throws Exception {
        SoftReference<Person>[] people =
                new SoftReference[100000];
        for (int i = 0; i < people.length; i++) {
            people[i] = new SoftReference<Person>(new Person(
                    "名字" + i, (i + 1) * 4 % 100));
        }
        System.out.println(people[2].get());
        System.out.println(people[4].get());
        // 通知系统进行垃圾回收
        System.gc();
        System.runFinalization();
        // 垃圾回收机制运行之后，SoftReference数组里的元素保持不变
        System.out.println(people[2].get());
        System.out.println(people[4].get());
    }
}
```
运行结果：
```
Person[name=名字2, age=12]
Person[name=名字4, age=20]
Person[name=名字2, age=12]
Person[name=名字4, age=20]
```
系统内存足够，在垃圾回收前后结果一样，和强引用并无区别。若指定jvm的内存大小，则软引用所引用的对象会被系统回收，可使用如下命令指定堆内存只有2M，则创建长度为100000的数组可使内存紧张，则会被回收，最终输出均为
null：
```
java -Xmx2m -Xms2m SoftReferenceTest
```
> Xmx：设置java虚拟机堆内存最大容量；
Xms：设置java虚拟机初始容量。 

如果将前面初始化people的方式改为下面的强引用方式，依然指定2M内存，则会抛出`java.lang.OutOfMemoryError`的内存溢出异常,因而终止程序,此处也体现了前面所说的强引用对象不会回收其所占用的内存，尽管内存不足。
```
Person[] people = new Person[100000];
```
### **c. 弱引用**
弱引用于软引用类似，但他的生存期更短，通过`WeakReference`类实现。对于只有弱引用的对象，当垃圾机制运行时，**不管内存是否足够，总会回收该对象占用的内存**。
如下示例代码：
```
public class WeakReferenceTest {
    public static void main(String[] args) throws Exception {
        // 创建一个字符串对象
        String str = new String("疯狂Java讲义");
        // 创建一个弱引用，让此弱引用引用到"疯狂Java讲义"字符串
        WeakReference<String> wr = new WeakReference<String>(str);
        // 切断str引用和"疯狂Java讲义"字符串之间的引用
        str = null;      //②
        // 取出弱引用所引用的对象
        System.out.println(wr.get()); //输出：疯狂Java讲义
        // 强制垃圾回收
        System.gc();
        System.runFinalization();
        // 再次取出弱引用所引用的对象
        System.out.println(wr.get());  //输出：null
    }
}

```

> 注：上面代码中创建字符串对象不可采用 “String str = "疯狂Java讲义";” 这种方式,因为这样的定义系统会把它缓存为常量，使用强引用来引用它，则不会被回收。

上述代码中的内存分配示意图：

![](/img/article_img/2016/weakreference.png)

在实际使用时，可以使用`WeakHashMap`来保存弱引用对象。

### **d. 虚引用**

虚引用主要是跟踪对象被垃圾回收的状态，可以通过检查与虚引用关联的队列中是否包含指定的引用，了解对象是否被回收。
与软引用和弱引用不同，虚引用不能单独使用。
虚引用对象在被释放前会将它添加到他关联的引用队列中。通过`PhantomReference`类实现，结合引用队列`ReferenceQuence`使用。如下使用示例：
```
public class PhantomReferenceTest {
    public static void main(String[] args)
            throws Exception {
        // 创建一个字符串对象
        String str = new String("疯狂Java讲义");
        // 创建一个引用队列
        ReferenceQueue<String> rq = new ReferenceQueue<String>();
        // 创建一个虚引用，让此虚引用引用到"疯狂Java讲义"字符串
        PhantomReference<String> pr =
                new PhantomReference<String>(str, rq);
        // 切断str引用和"Struts2权威指南"字符串之间的引用
        str = null;
        // 试图取出虚引用所引用的对象，
        // 程序并不能通过虚引用访问被引用的对象
        System.out.println(pr.get());  //输出null
        // 强制垃圾回收
        System.gc();
        System.runFinalization();
        // 取出引用队列中最先进入队列中引用与pr进行比较
        System.out.println(rq.poll() == pr);  //输出：true
    }
}
```

## 二、java 的内存泄露

与C++程序员不同，java 程序员无需关注内存释放的问题，这些由JVM帮我们完成。然而如果使用不当，一样会出现内存泄露。如果是可达状态的对象，但程序不访问，他们做占用的空间不会被回收，就会产生内存泄露。
yi ArrayList中的remove方法为例，每当删除一个元素时，就会让最后一个元素的引用置为null:

```
elementData[--size] = null;
```
在ArrayList中采用数组来保存每个元素的。由于集合中每个元素实际上存的是引用，如果不使用上述的代码，则ArrayList中被删除的元素一直被引用着，处于可达状态，导致无法被回收，因而会产生内存泄露。



## 三、垃圾回收机制

垃圾回收主要完成两件事：

- 跟踪监控java对象，当它处于不可达时，回收他所占用的内存；
- 清理内存分配和回收过程中产生的内存是碎片。

垃圾回收的基本算法有：

- 串行回收和并行回收
- 并发执行和应用程序停止
- 压缩/不压缩和复制

现在的垃圾回收机制用分代的方式采用不同的回收机制，根据**对象生存时间的长短**，把堆内存分为三代：**Yong(新生代)、Old(老年代)、Permanent(永生代)**。

在java中，绝大多数对象不会被长时间引用，他们在Yong期间被回收，很老的对象和很新的对象之间很少存在相互引用的情况。

当Yong代的内存快要用完时，垃圾回收机制会对其进行回收，此时回收的系统性能开销小。为次要回收；当Old代快要用完时，垃圾回收机制会进行全面的回收，包括Yong和Old，此时回收成本大，为主要回收。

Permanent时代主要用于装在Class、方法等信息，默认是64MB，通常不会被回收。


## 四、内存管理技巧

只有很好的掌握了垃圾回收及其机制，才能更好的管理java虚拟机，使我们写出更高性能的java代码。避免内存泄露的主要技巧如下：

- 使用直接量
  如使用 `String str = "hello;"` 代替 `String str = new String("hello");`，前者会在缓存池缓存这个常量
- 使用StringBuilder和StringBuffer进行字符串的连接
 使用String时会生成大量的临时字符串存在内存中。
- 及时释放无用对象的引用
- 减少静态变量
- 避免在经常调用的方法、循环中创建java对象
- 缓存经常使用的对象
  缓存技术是牺牲空间换时间的，主要使用容器保存已使用的对象，其关键在于如何控制缓存容器的空间使其不至于过大并且能够保留大部分已用过的对象。
- 尽量不要使用finalize方法
- 考虑使用SoftReference
 当创建长度很大的对象时，可以使用软引用包装数组，便于在内存不足的情况下被回收释放。
 
 
 
 
 
 





