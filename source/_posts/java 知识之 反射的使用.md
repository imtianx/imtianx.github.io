
---
title: java 知识之 反射的使用
date: 2016-11-25 16:06:25
categories: [java,高级知识]
tags: [java,反射]
---


所谓反射，是指在运行状态中，对于任意一个类，都能够知道这个类的所有属性和方法；对于任意一个对象，都能够调用它的任意一个方法和属性。这种动态获取信息以及动态调用对象方法的功能称为java语言的反射机制。<!--more-->

反射有如下的功能：

- 在运行时判断任意一个对象所属的类；
- 在运行时构造任意一个类的对象；
- 在运行时判断任意一个类所具有的成员变量和方法；
- 在运行时调用任意一个对象的方法；
- 生成动态代理。

这里的反射主要通过`Class`类来实现。

## 一、Class类的使用

`Class`类的实例表示java 应用运行时的类或者接口，包括数组、基本类型(`int/long/Indeger/String/...`)、关键字(`void/...`)等。没有共有构造方法，在使用new创建对象或者加载ClassLoader时，由JVM自动调用。

> 每个java类运行时都在JVM里表现为一个class对象，可通过类名.class,类型.getClass(),Class.forName("类名")等方法获取class对象。

可以通过下面三种方式获得Class对象：

1.通过 类名.class 获取，可以认为每个类都有一个静态的Class对象。
 ```
Class c1 = Person.class;
 ```

2.通过类的对象获取
 ```
 Person person = new Person();
 Class c2 = person.getClass();
 ```
 
3.通过类名获取，**动态加载**（这个再很多地方都有使用，如：加载数据库驱动）
 ```
 Class c3 = null;
    try {
        c3 = Class.forName("Person");
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    }
 ```

上面的**c1/c2是Person的类类型，Person是Class类的对象。可以理解为一切类都是Class的对象**。

打印上面三种方法获取的Class对象：

```
System.out.println(c1 == c2);//true
System.out.println(c1 == c3);//true
System.out.println(c2 == c3);//true
```

上面三种方式获取的Class对象，两两均相等。可见，可以理解为每个对象都有一个静态的Class变量。因为在java 中，*Object* 是一切类的父类，在Object中有一个获取Class对象的native(由C++或C语言实现，通过java 调用，具体的可参见jni相关的知识)方法。如下部分Object开头源码：

```
 public class Object {
     
     // ...
      
     /**
     * Returns the runtime class of this {@code Object}. The returned
     * {@code Class} object is the object that is locked by {@code
     * static synchronized} methods of the represented class.
     *
     * <p><b>The actual result type is {@code Class<? extends |X|>}
     * where {@code |X|} is the erasure of the static type of the
     * expression on which {@code getClass} is called.</b> For
     * example, no cast is required in this code fragment:</p>
    
     * @return The {@code Class} object that represents the runtime
     *         class of this object.
     *         
 */
    public final native Class<?> getClass();
    
   // ...
```

通过上面 getClass 方法前的部分注释，可以清楚的明白他的作用。
 
## 二、动态加载类

在java 中，使用new创建的对象都是静态加载的，这些类必须存在，不管在实际中是否使用，否则编译不通过。可以通过动态加载类来解决该问题。
通过Class类的forName方法进行加载,传入相应的名加载具体的类，可以使程序的扩展性更好，避免编译出错。

该方法的原型为：

```
  public static Class<?> forName(String className)
```
## 三、使用Class获取类信息

Class类提供的部分获取类信息的方法如下：

|方法名|说明|
|:-----|:----:|
|getFields() | 获取所有public类型的成员变量|
| getDeclaredFields()|获取该类自己声明的所有变量 |
|getConstructors() |获取所所有public类型的构造方法 |
|getDeclaredConstructors() |获取所有的构造方法|
|getMethods() |获取所有的public函数，包括父类继承来的|
|getDeclaredMethods |获取该类所有声明的方法|

上面分别为获取成员变量、构造方法和成员方法。

**获取成员参数**

```
public class ClassUtils {
    public static void getClassField(Object obj) {
            Class c = obj.getClass();
            Field[] fs = c.getDeclaredFields();// c.getMethods();
            for (Field f : fs) {
                Class fieldType = f.getType();
                System.out.println(fieldType.getName() + " " + f.getName());
            }
        }
}
```

上述代码是获取所有成员变量的，获取的每个成员方法都是 `Fidld` 类型的对象。
如下测试代码获取String类中的成员变量：

```
ClassUtils.getClassField("reflect");
```

运行结果：

```
[C value
int hash
long serialVersionUID
[Ljava.io.ObjectStreamField; serialPersistentFields
java.util.Comparator CASE_INSENSITIVE_ORDER
```

其中第一个和第三个表示的是数组。查看String中的源码，成员变量如下：

```
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    
    private final char value[];

    private int hash; // Default to 0

    private static final long serialVersionUID = -6849794470754667710L;

    private static final ObjectStreamField[] serialPersistentFields =
            new ObjectStreamField[0];
            
    //...
     public static final Comparator<String> CASE_INSENSITIVE_ORDER
                                         = new CaseInsensitiveComparator();
    
    //...
}
```
同样的可以调用该方法查看其他类中的成员变量。


**获取构造方法和成员方法**

类似于上面获取成员变量的方法，如下获取构造函数和成员方法则很好理解了。
```
public class ClassUtils {
    //...
    
    /**
     * 获取所有的成员方法
     *
     * @param obj
     */
    public static void getClassMethods(Object obj) {
        Class c = obj.getClass();
        System.out.println("类名为：" + c.getName());
        Method[] ms = c.getDeclaredMethods();

        for (Method m : ms) {
            Class returnType = m.getReturnType();
            //返回值的类类型，如String-->String.class
            System.out.print(returnType.getName() + " ");
            //方法名称
            System.out.print(m.getName() + "(");
            //获取参数--参数列表的类类型
            Class[] paramTypes = m.getParameterTypes();
            int paramsNum = paramTypes.length;
            Class paramType;
            for (int i = 0; i < paramsNum; i++) {
                paramType = paramTypes[i];
                if (i == 1 || (i == paramsNum - 1))
                    System.out.print(paramType.getName());
                else
                    System.out.print(paramType.getName() + " ,");
            }
            System.out.println(")");
        }
    }
    /**
     * 获取所有的构造函数
     *
     * @param obj
     */
    public static void printConMessage(Object obj) {
        Class c = obj.getClass();
        Constructor[] cs = c.getDeclaredConstructors();
        for (Constructor constructor : cs) {
            System.out.print(constructor.getName() + " (");
            Class[] paramTypes = constructor.getParameterTypes();
            int paramsNum = paramTypes.length;
            Class paramType;
            for (int i = 0; i < paramsNum; i++) {
                paramType = paramTypes[i];
                if (i == 1 || (i == paramsNum - 1))
                    System.out.print(paramType.getName());
                else
                    System.out.print(paramType.getName() + " ,");
            }
            System.out.println(")");
        }
    }
}
```
此处省略测试。

## 四、方法反射的基本操作
对于方法的获取，可以通过方法名称和参数列表来确定某个方法。主要使用了 `Method.invoke(对象,参数列表);` 操作。

**首先需要获取类信息，然后指定方法名和参数获取方法对象，再通过`Method.invoke()`进行反射获取方法执行结果。若该方法无返回值，则invoke方法最后返回null,否则返回相应的结果**。

如下示例代码：

```
public class TestDemo {
    public static void main(String[] args) {
        //1.获取类信息
        A a = new A();
        Class aClass = a.getClass();
        //2.获取方法名称和参数
        try {
//            Method method = aClass.getMethod("print",new Class[]{int.class,int.class});
            Method method = aClass.getMethod("print", int.class, int.class);
            //方法返回结果：若无返回结果则o为null，否则为返回结果，这里返回为30
            Object o = method.invoke(a, 10, 20);
            System.out.println(o);//30
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }
}
//测试反射方法
class A {
    public int print(int a, int b) {
        System.out.println(a + b);
        return a + b;
    }

    public void print(String a, String b) {
        System.out.println(a.toUpperCase() + "-----" + b.toUpperCase());
    }
}

```
其中 Method()和invoke()方法第二个参数为可变数组，可有可无，如果有接写。可以通过new数组的方式或者直接一个个写出。

## 五、通过反射了解集合泛型的本质

我们都知道，在java中，定义集合指定什么泛型，就只能添加该类型的数据到集合中，否则就会报错。

通过反射可以往集合中添加不同类型的数据，这样虽没有多大意义，不便于遍历。这里主要说明了集合在编译后是去泛型化的，集合的泛型可以防止错误输入，在编译极前有效。

如下测试代码：
```
public class TestDemo04 {
    public static void main(String[] args) {
        ArrayList<String> l1 = new ArrayList<>();
        ArrayList l2 = new ArrayList();
        l1.add("java reflect");
//        datas.add(100);//报错
        Class c1 = l1.getClass();
        Class c2 = l2.getClass();
        System.out.println(c1 == c2);//true
        try {
            Method method = c2.getMethod("add", Object.class);
            method.invoke(l1, 100);
            System.out.println("数组大小："+l1.size());
            System.out.println("数组内容："+l1.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```
输出结果：
```
true
数组大小：2
数组内容：[java reflect, 100]
```
上面的代码，通过反射往String类型的集合中添加了int类型的100。

通过对反射的学习，发现反射是从.class到.java的过程，感觉像反编译字节码。以 `Class c1 = Person.class;`为例，Person.java类在编译后生成的字节码文件为Person.class,这里获取的Class正式这样的。



