---
title: Git 子模块：git submodule
date: 2018-03-08 16:06:25
categories: [版本控制,Git]
tags: [版本控制,Git]
---

工作中，可能会遇到**在一个Git仓库 中添加 其他 Git 仓库的场景**。比如，在项目中引用第三方库。或者在模块化开发中，某些公共的模块是需要单独维护的，使用单独的仓库比较方便，但是在项目中需要引用，就会出现这样的场景。这里使用 Git 的 `git submodule` 命令为一个 `git 项目` 添加 `子git项目`。<!--more-->


可以使用 `git submodule --help` 查看所有相关命令。
为了方便说明，这里在主项目 `MainProject` 中加两个子模块 `liba` 和 `libb` .

## 1. 添加子模块

进入 `MainProject` 使用 **`git submodule add `** 进行添加,操作命令：

```
git clone https://github.com/imtianx/MainProject.git
cd MainProject/
git submodule add https://github.com/imtianx/liba.git
```
如下图：
![](http://img.imtianx.cn/18-3-7/40164089.jpg)

使用 `git submodule add https://github.com/imtianx/libb.git` 添加 `libb` 子模块。 对于上图，文件夹 `liba` 为新增加的子模块目录, `.gitmodules` 中存放的为子模块的信息，使用 `cat` 或 `vim` 查看内容为：

```
[submodule "liba"]
	path = liba
	url = https://github.com/imtianx/liba.git
[submodule "libb"]
	path = libb
	url = https://github.com/imtianx/libb.git
```

> **.gitmodules文件**：保存项目 URL 与已经拉取的本地目录之间的映射，有多个子模块则含有多条记录，会随着版本控制一起被拉去和推送的。

此时文件目录树如下：
```
.
├── README.md
├── liba
│   ├── README.md
│   ├── a.txt
│   └── a2.txt
├── libb
│   ├── README.md
│   ├── b.txt
│   └── b2.txt
└── test.text

```

最后，**提交添加的子模块到主目录**

```
$ git commit -m "add liba and libb submodules"
[master 6b15e30] add liba and libb submodules
 3 files changed, 8 insertions(+)
 create mode 100644 .gitmodules
 create mode 160000 liba
 create mode 160000 libb
```
## 2. 更新子模块
往往子模块是单独开发的，这里以更新 `liba` 为例（为了测试，这里先在liba仓库添加了一个文件）：

```
cd liba/
git fetch
git merge origin/master
```
操作结果如下图，**注意需要进入子模块目录**：
![](http://img.imtianx.cn/18-3-8/31258305.jpg)

此外，还可以在主目录下 直接用下面的命令更新 `libb`子模块：
```
git submodule update --remote liba
```
$\color{red}{注意：上面的操作的都 master 分支，无法操作其他分支}$

**使用下面的方式，更新 `libb` 的 `dev` 分支：**

```
git config -f .gitmodules submodule.liba.branch dev
git submodule update --remote
```
如下图：
![](http://img.imtianx.cn/18-3-8/49923190.jpg)

> 这里对 `.gitmodules` 加了 `-f` 参数，修改提交后对所有用户有效。

## 3. 删除子模块
在日常开发中，有添加，当然也会有删除 子模块的需求。
这里主项目包含两个子模块：`liba`、`libb`，以删除 `liba` 为例说明：

-  使用 `git rm --cached liba` 将liba 从版本控制中删除（本地仍保留有），若不需要可不带 `--cached`进行完全删除。
- 使用 `vim .gitmodules` 可打开vim编辑,删除对应的内容
 
 ```
  [submodule "liba"]
           path = liba
           url = https://github.com/imtianx/liba.git
           branch = dev
 ```
- 使用 `vim .git/config` 可打开vim编辑,删除对应的内容
 
 ```
 [submodule "liba"]
          url = https://github.com/imtianx/liba.git
          active = true
 ```
- 使用 `rm -rf .git/modules/liba`, 删除.git下的缓存模块，最后提交项目。

经过上面的删除后还可以进行添加子模块。

## 4. 克隆含子模块的仓库
若需要克隆含有子模块的仓库，直接 进行克隆是无法拉取之模块的代码，可加上 **`--recursive`** 参数，如下：

```
git clone --recursive https://github.com/imtianx/MainProject.git
```
或者使用下面的三部操作：

```
git clone  https://github.com/imtianx/MainProject.git
git submodule init
git submodule update
```
<br/>
更多子模块的操作，请参考官方文档：[Git 工具 - 子模块](https://git-scm.com/book/zh/v2/Git-工具-子模块)





