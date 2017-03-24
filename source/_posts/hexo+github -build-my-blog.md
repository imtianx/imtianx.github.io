---
title: Hexo+github 搭建个人博客
categories: [工具软件,hexo]
tags: [软件,gihub]
---
最近，看见很多人在使用hexo+github搭建自己的博客，为了方便记录平时的学习内容。在此，我也学习搭建一个个人博客，记下自己的搭建过程，方便自己，也方便他人。
<!--more-->
## 1、安装前准备

>- 安装 **Node.js** ，(可以去 [官网][1] 下载相应的版本，并安装。
>- 安装Git (或者安装github客户端)

---
## 2、安装hexo
windows下进入命令行，执行如下命令：

        npm install-g hexo
然后启动 git shell 初始化hexo。这里，我打算把hexo放在自己新建的 “myblog” 文件夹下，则需要先进入该文件夹下，然后进行初始化，如下命令：
        
        
        E:\GitHub> cd myblog            //进入目录
        E:\GitHub\myblog> hexo init    //进行初始化

注：我的git shell 的根目录为 E:\Github ,myblog 文件夹在它下面。
然后就是静静的等待它下载完成，可能需要几分钟。
最后就可以生成静态界面：
        
        hexo g
启动服务：
        
        hexo s
打开浏览器，输入 http://localhost:4000/ 即可成功打开。
到此，你已经成功的弄好博客页面了。

---
## 3、配置到github
上面生成的 博客页面仅限本机使用，别人无法访问。有服务器的可以把它配置到服务器上。但这里采用的是提交到github，由它托管，就可以方便的访问了。
在github 上建立  ***用户名.github.io*** 的仓库。如我的github用户名为：txadf,仓库为：**txadf.github.io**  地址为 ：https://github.com/txadf/txadf.github.io.git
然后打开blog 文件夹下的 _config.yml 文件，在最后修改为如下代码：

        deploy:
          type: git
          repo: https://github.com/txadf/txadf.github.io.git
          branch: master


最后，提交博客文件到gtihub,执行如下命令：
        
        hexo d
如果不出错，那么就可以在浏览器用 txadf.github.进行访问了。

---
## 4、hexo 相关命令
        cls             清屏
        hexo clean      清理项目
        hexo g          生成静态界面
        hexo s          启动服务器
        hexo d          提交到github
        hexo help       全部的命令
新建文章：
    
    hexo new "blogname"
博客支持markdown语法，可以用相关的编辑器写好后放在**_posts**文件下。对于markdown语法，如有不懂课自行百度。

---
## 5、主题推荐
对于主题的修改，只需要修改 blog 文件夹下的 **_config.yml** 中的**theme**属性为指定的主题名，并将主题放到theme文件夹下。
然后 进行部署（hexo g） 和提交 （hexo d）
注：对于其他的属性，修改 方法类似，如网站标题，作者等。

这里推荐几个个人比较喜欢的主题：
 1. [我的博客主题][2]  
 2.  [hexo-theme-spfk][3]
 
更多主题，请访问[这里][4]
 
 


  [1]: https://nodejs.org/en/
  [2]: https://github.com/raytaylorlin/hexo-theme-raytaylorism
  [3]: https://github.com/txadf/hexo-theme-spfk
  [4]: https://github.com/hexojs/hexo/wiki/Themes