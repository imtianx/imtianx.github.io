---
title: Android Bluetooth 蓝牙技术初体验
date: 2016-09-20 16:06:25
categories: [android,学习笔记]
tags: [android,蓝牙,通信]
---


转自：[http://www.jb51.net/article/79334.htm](http://www.jb51.net/article/79334.htm)

### 1.Bluetooth包简介
Android平台提供了一个android.bluetooth的包，里面实现蓝牙设备之间通信的蓝牙API。总共有8个类，常用的四个类如下:
**BluetoothAdapter类**
代表了一个本地的蓝牙适配器。它是所有蓝牙交互的入口点。利用它你可以发现其他蓝牙设备，查询绑定了的设备，使用已知的MAC地址实例化一个蓝牙设备和建立一个BluetoothServerSocket（作为服务器端）来监听来自其他设备的连接。<!--more-->
**BluetoothDevice类**
代表了一个远端的蓝牙设备，使用它请求远端蓝牙设备连接或者获取远端蓝牙设备的名称、地址、种类和绑定状态（其信息是封装在BluetoothSocket中）。
**BluetoothSocket类**
代表了一个蓝牙套接字的接口（类似于TCP中的套接字），它是应用程序通过输入、输出流与其他蓝牙设备通信的连接点。
**BlueboothServerSocket类**
代表打开服务连接来监听可能到来的连接请求（属于server端），为了连接两个蓝牙设备必须有一个设备作为服务器打开一个服务套接字。当远端设备发起连接连接请求的时候，并且已经连接到了的时候，BlueboothServerSocket类将会返回一个BluetoothSocket。

### 2.常用类的使用
**BluetoothAdapter：蓝牙适配器**
> cancelDiscovery()取消探索，当我们正在搜索设备的时候调用这个方法将不再继续搜索
disable()关闭蓝牙
enable()打开蓝牙，这个方法打开蓝牙不会弹出提示，更多的时候我们需要问下用户是否打开，以下两行代码同样是打开蓝牙，但会提示用户：
Intentenabler = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
startActivity(enabler);
getAddress()获取本地蓝牙地址
getDefaultAdapter()获取默认BluetoothAdapter，实际上，也只有这一种方法获取BluetoothAdapter
getName()获取本地蓝牙名称
getRemoteDevice(String address)根据蓝牙地址获取远程蓝牙设备
getState()获取本地蓝牙适配器当前状态
isDiscovering()判断当前是否正在查找设备，是则返回true
isEnabled()判断蓝牙是否打开，已打开返回true，否则返回false
listenUsingRfcommWithServiceRecord(String name,UUID uuid)根据名称，UUID创建并返回BluetoothServerSocket，这是创建BluetoothSocket服务器端的第一步
startDiscovery()开始搜索，这是搜索的第一步

**BluetoothDevice：远程蓝牙设备**
> createRfcommSocketToServiceRecord(UUIDuuid)根据UUID创建并返回一个BluetoothSocket，这个方法也是我们获取BluetoothDevice
的目的——创建BluetoothSocket
这个类其他的方法，如getAddress()、getName()等，同BluetoothAdapter。

**BluetoothSocket：客户端**
> //这个类一共有6个方法
close()关闭
connect()连接
isConnected()判断是否连接
getInptuStream()获取输入流
getOutputStream()获取输出流
getRemoteDevice()获取BluetoothSocket指定连接的远程蓝牙设备

**BluetoothServerSocket：服务端**
> //这个类一共有4个方法
accept()
accept(int timeout)
close()关闭
getChannel()返回这个套接字绑定的通道

### 3.数据传输
**蓝牙数据传输——服务器端**
> 、获得BluetoothAdapter。 
2、通过BluetoothAdapter.listenUsingRfcommWithServiceRecord(name,UUID uuid)方法创建BluetoothServerSocket对象。 
3、通过luetoothServerSocket.accept()方法返回一个BluetoothSocket对象。由于该方法处于阻塞状态，需要开启线程来处理。 
4、通过BluetoothSocket.getInputStream（）和BluetoothSocket.getOutputStream（）方法获得读写数据的InputStream和OutputStream对象。 
5、通过InputStream.read()方法来读数据。通过OutputStream.write（）方法来写数据。

**蓝牙数据传输——客户端**
> 1、获得BluetoothAdapter。 
2、通过BluetoothAdapter.getRemoteDevice(String address)获得指定地址的BluetoothDevice对象。 
3、通过BluetoothDevice.createRfcommSocketToServiceRecord (UUID uuid)方法创建BluetoothSocket对象。 
4、通过BluetoothSocket.connect（）方法来连接蓝牙设备。 
5、通过BluetoothSocket.getInputStream（）和BluetoothSocket.getOutputStream（）方法获得读写数据的InputStream和OutputStream对象。 
6、通过InputStream.read()方法来读数据。通过OutputStream.write（）方法来写数据。

需要的权限：
```
<uses-permissionandroid:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permissionandroid:name="android.permission.BLUETOOTH" />
```




