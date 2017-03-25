---
title: java 知识之 注解的使用和解析
date: 2016-11-26 10:06:25
categories: [java,高级知识]
tags: [java,注解,自定义注解]
---


在java中，例如重写父类方法使用的 `@Override`，就是注解。在开发中使用的框架，大部分也是用了注解。通过注解可以是代码更加简洁，更加清晰。在jdk1.5后，引入了注解。<!--more-->
官方概念：java提供了已汇总源程序中的元素关联任何信息和任何元数据的途径和方法。



## 一 、常见的注解
在java 中主要有如下三个注解：

- @Override
 指明被注解的方法需要覆写父类中的方法，该方法在父类或接口中一定定存在，而且定义的一模一样（包括方法名、返回类型、参数），否则会报错误。
- @Deprecated
 表明该类被废弃，但仍然可以使用，只是使用时方法中间显示一横线。
- @SuppressWarnings("deprecation")
 这个主要是排除因使用了被Deprecated 标记的方法而出现的警告，尽量在方法上使用来压制警告。

更多java注解类的信息请查看源码 `java.lang.annotation` 包下面的注解类。

**第三方注解：**
 如果使用过Spring和Mybatis后台框架，对Spring中的@Autowired、@Service、@Repository以及Mybatis中的@InsertProvider、@UpdateProvider、@Options的使用就较为了解。
 
 
## 二、 注解的分类

按照**运行时机制**分为：
 
- 源码注解
注解只存在源码中，编译后的.class文件中不存在

- 编译时注解
在源码和.class中都存在，比如前面java中的 `@Override、@Deprecated、@SuppressWarnings("deprecation")`
- 运行时注解
在运行阶段起作用，会影响运行逻辑的注解。

按照**来源**分为：

- 来自jdk的注解
- 第三方注解
- 自定义注解

## 三、自定义注解

在进行自定义注解时 使用 `@interface`关键字，与新建类类似。idea中新建java class时类型可以选择为`Annotation`，可以直接建立注解类。

> 建立注解类时，若类中只有一个成员时，方法名必须为**value**，使用时可以忽略成员名和赋值号；
如果没有成员，则该注解成为标识注解，如 `@Inherited`；注解中，成员的类型可以为java中的基本类型（int/float/double/...）,也可以是String、Class、Annotation,Enumeration。此外，还可以使用 `default`关键字指定默认值。

如下简单注解例子：

```
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited//允许子类继承
@Documented//生成java doc时包含注解信息
public @interface Description {

    String desc();

    String author();

    int age() default 18;//指定默认值
}
```
上面的注解中，`@Target`指注解的作用域，包含java中的类、构造方法、属性等，具体参数如下：
```
ElementType.METHOD  //方法声明
ElementType.TYPE     //类、接口
ElementType.CONSTRUCTOR    //构造方法声明
ElementType.TYPE.FIELD  //属性声明
ElementType.LOCAL_VARIABLE  //局部变量声明
ElementType.PACKAGE //包声明
ElementType.PARAMETER   //参数声明

```
`@Retention` 是指注解的生命周期，可以为：
```
RetentionPolicy.RUNTIME     // 运行时，可以通过反射获取；
RetentionPolicy.SOURCE      //源码中显示，编译后丢弃；
RetentionPolicy.CLASS       //编译时记录到class中，运行时忽略
```

`@Inherited` 表示允许子类继承，这个只能用与类，而且子类只能继承父类的类注解，不能继承方法上的注解。
`@Documented` 表示生成javadoc时包含注解信息

在注解类名之前的注解称为元注解。

**自定义注解的使用语法：
@注解名(成员名1=XXX,成员名2=XXX,...)；**
对于只有一个成员的注解，直接用**@注解名(XXX)**

上面的注解可以使用在类和方法上，如下为在方法上的使用：
```
@Description(desc = "run",author = "imtianx",age = 20)
public void run() {

}
```
## 四、解析注解
对于注解的解析，主要用到了反射技术。
通过反射获取类、函数或成员上的运行时注解信息，实现动态的控制程序的逻辑。

这里介绍下注解内容的获取，首先在使用注解到需要的类上：
```
@Description(desc = "student",author = "imtianx",age = 20)
public class Student implements Person {

    public String name;

    @Description(desc = "run-M",author = "imtianx-M",age = 21)
    public void run() {
    }

    @Override
    public void sign() {

    }
}
```
测试获取注解内容：
```
public class TestDemo01 {

    public static void main(String[] args) {

        try {
            //1.反射获取类信息
            Class c = Class.forName("Student");

            //2.获取类上面的注解
            boolean hasCAnno = c.isAnnotationPresent(Description.class);
            if (hasCAnno) {
                Description d = (Description) c.getAnnotation(Description.class);
                System.out.println(d.desc());
                System.out.println(d.author());
                System.out.println(d.age());

            }
            //3.获取方法上的注解
            Method[] methods = c.getMethods();
            for (Method method : methods) {
                boolean isMAnno = method.isAnnotationPresent(Description.class);
                if (isMAnno) {
                    Description md = method.getAnnotation(Description.class);
                    System.out.println(md.desc());
                    System.out.println(md.author());
                    System.out.println(md.age());

                }
            }
            //另一种获取获取注解的方式，以获取类上面的注解为例
            for (Method method : methods) {
                Annotation[] as = method.getDeclaredAnnotations();
                for (Annotation a : as) {
                    if (a instanceof Description) {
                        Description d = (Description) a;

                        System.out.println(d.desc());
                        System.out.println(d.author());
                        System.out.println(d.age());
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```
首先通过反射获取类信息，然后依次获取类、方法上面的注解内容。至于属性上面的注解，可以使用`Class.getDeclaredFields()`获取所有的属性，然后进行遍历获取。可参见 [java 知识之 反射的使用](http://imtianx.cn/2016/11/25/java%20%E7%9F%A5%E8%AF%86%E4%B9%8B%20%E5%8F%8D%E5%B0%84%E7%9A%84%E4%BD%BF%E7%94%A8/) 一文了解反射相关的知识。

当你了解了自定义注解和它的解析，再去看自己项目所用框架中的注解的实现，就十分简单，自己也能实现相同的效果。










 
 




