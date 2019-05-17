---
title: Docker的使用及镜像编写
date: 2018-07-30 22:06:25
categories: [工具软件,docker]
tags: [docker,dockerfile,gitlab-ci]
---


随着容器技术的普及，越来越多的事情可以在 `Docker` 中完成。这里简要记录 docker 的常用命令以及镜像的构建与运用。结合gitlab-ci来构建 android apk。
<!-- more -->
## 一、docker 安装

### 1.Mac 安装 

在 mac 上,通常使用 [homebrew](https://brew.sh/) 包管理器来安装软件，其中 `cask` 扩展可以安装图形界面程序，这里安装带有图形界面的 **Docker** 软件：

```
brew cask install docker
```
获取去[官网](https://www.docker.com/products/docker-desktop)下载对应的安装包安装。

然后启动后即可在命令行使用。可以运行 `docker --version` 查看版本信息，检测启动情况。

由于Docker 的仓库大部分在国外，访问速度会受限，可以设置国内的镜像站点。

依次打开 ：`preferences` -> `daemon` ,然后在 `Registry mirrors` 中添加：[https://registry.docker-cn.com](https://registry.docker-cn.com)

### 2 centos 安装

由于通常很多的 Docker 镜像 都是在 Centos 服务器上运行，这里简记 Centos 安装。这里采用 [yum](http://yum.baseurl.org/) 安装,如下：(参考 [官方文档](https://docs.docker.com/install/linux/docker-ce/centos/#uninstall-old-versions))


```
// 1. 卸载旧版本
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
                  
// 2.安装相关工具
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
  
// 3.添加docker 软件源 
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    
// 如果需要最新版本，可使用如下命令安装
sudo yum-config-manager --enable docker-ce-edge

// 如果需要最新测试版本，可使用如下命令安装
sudo yum-config-manager --enable docker-ce-test

// 4.安装
sudo yum install docker-ce

// 启动docker 
sudo systemctl start docker
// 运行 hello-word 镜像 进行测试
docker run hello-word

```
同样的，为了提高速度，可以配置国内镜像加速服务,可选的有：

- docker 官方提供的：[https://registry.docker-cn.com](https://docs.docker.com/registry/recipes/mirror/#use-case-the-china-registry-mirror)
- 七牛云提供的：[ https://registry-mirror.qiniu.com](https://kirk-enterprise.github.io/hub-docs/#/user-guide/mirror)
- 阿里云提供的:[登陆阿里云申请](https://help.aliyun.com/document_detail/60750.html?spm=a2c4g.11186623.6.547.4eb36efcc3Cijq)

这里以第一种方式为例说明：
首先修改或者新建 `/etc/docker/daemon.json` 为如下内容：


```
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
```

保存并重启：

```
systemctl daemon-reload
systemctl restart docker
```

## 二、镜像、容器和仓库

**镜像**：是一个特殊的文件系统，为容器运行提供提供程序、资源、配置文件等，他不包含任何用户态数据，构建完成后不可改变。

**容器**：是镜像运行的实体，可以可以被创建、启动、删除、停止、暂停等。镜像与容器的关系，类似 Java 中的 类 和 实例。

**仓库**：用于存储分发镜像文件。可以使用官方的仓库 [docker hub](https://hub.docker.com/explore/),或者自己搭建私有仓库。


## 三、docker 常用命令

```
// 启动/停止  docker
systemctl start docker
systemctl stop docker

// 查看镜像
docker images 

// 查找 nginx 镜像
docker search nginx

// 拉取 nginx 镜像,默认tag为latest，需要仓库中有该标签的镜像方可使用
docker pull nginx
// 指定拉取 1.15.1 版本的
docker pull nginx:1.15.1

// 运行一个容器,name 指定名字，d 表示后台运行，p 指定端口，其中前者为主端口，后者为容器端口，可以通过 主机ip:外部端口 访问 
docker run --name nginx -d -p 8094:80 nginx

// 查看容器 运行日志，-f 实时显示
docker logs -f container_id

// 通过容器 id 进入容器,i交互模式，t终端，进入bash，使用 exit 退出 
docker exec -it container_id bash

// 查看docker 容器进程,-a 表示所有的，-q 只显示 id
docker ps 

// 停止容器 
docker stop container_id
// 重启容器
docker restart container_id
// 删除容器 
docker rm container_id

// 删除镜像，必须先删除对应版本启动的容器
docker rmi image_id
```

## 四、docker 镜像编写及 自动构建
可以根据自己的需求，编写 `Dockerfile` 文件，构建自己的镜像，然后上传到 [docker hub](https://hub.docker.com/explore/)。为了方便使用 git-runner 来构建项目，这里简单的编写 android SDK 镜像,如下 [Dockerfile](https://github.com/imtianx/docker-android-compiler/blob/master/Dockerfile)：

```
FROM openjdk:8-jdk
MAINTAINER imtianx "imtianx@gmail.com"

# -----------------------set android sdk-----------------start-----

# Command line tools only from https://developer.android.com/studio/
ARG SDK_TOOLS_VERSION=4333796

ARG BUILD_TOOLS_VERSION=27.0.3

ARG COMPILE_SDK_VERSION=27

# workspace dir
WORKDIR /workspace_android

# set android env path
ENV ANDROID_HOME /workspace_android/sdk

# install android sdk .....start....
RUN mkdir  sdk && \
    wget http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    unzip -qd sdk sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    rm -f sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https --update) && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "build-tools;${BUILD_TOOLS_VERSION}") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "platform-tools") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "platforms;android-${COMPILE_SDK_VERSION}") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;google;m2repository") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;android;m2repository") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2")

# -----------------------set android sdk-------------------end-----

```

这里基于 jdk8,然后下载android sdk ，进行构建。构建命令：

```
// -t 指定 tag
docker build -t nginx:v1 .

// 登陆 docker hub 
docker login 

// 推送到 docker hub
docker push nginx:v1

```

> 注意，镜像构建是分层的，过多的内容可以分层构建，每一个 `RUN` 操作都是一层，层之间默认隔离的。具体的 `Dockerfile` 的编写 参考：[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)。

通常，如果镜像的构建过程需要下载较多资源(特别是国外资源)，或者不想在自己电脑构建，可以将自己的 `Dockerfile` 放在 [Github](https://github.com/) 或者 [Bitbucket](https://bitbucket.org/) ，然后利用 docker hub 提供的自动构建服务来构建镜像，与相关的仓库关联，然后在构建设置中添加触发的规则。

> 注意：如果需要使镜像 pull 时不添加 版本号，需要添加 tag 为 `latest` 的构建任务，保证改镜像的 tag 中有 `latest`

可参考；[docker-android-compiler](https://hub.docker.com/r/imtianx/docker-android-compiler/)

最后可以在 git 项目中添加 `.gitlab-ci.yml` 文件，指定上面的镜像。如下简单示例：

```
# gitlab ci for android 
image: imtianx/docker-android-compiler

stages:
  - build


before_script:

  - |-
    # Information used for debugging
    echo "/---------------------- JOB INFO ----------------------/"
    echo "CI_JOB_ID ${CI_JOB_ID}"
    echo "CI_JOB_MANUAL ${CI_JOB_MANUAL}"
    echo "CI_JOB_NAME ${CI_JOB_NAME}"
    echo "CI_JOB_STAGE ${CI_JOB_STAGE}"
    echo "/--------------------- RUNNER INFO --------------------/"
    echo "CI_RUNNER_ID ${CI_RUNNER_ID}"
    echo "CI_RUNNER_TAGS ${CI_RUNNER_TAGS}"
    echo "CI_RUNNER_DESCRIPTION ${CI_RUNNER_DESCRIPTION}"
    echo "/---------------------- CPU INFO ----------------------/"
    cat /proc/cpuinfo # To kwow if CPU supports KVM (for Android emulators), the flags category must contain "vmx" or "svm" ; egrep '^flags.*(vmx|svm)' /proc/cpuinfo
    echo "/-------------------- PROJECT INFO --------------------/"
    echo "ANDROID_COMPILE_SDK ${ANDROID_COMPILE_SDK}"
    echo "ANDROID_BUILD_TOOLS ${ANDROID_BUILD_TOOLS}"
    echo "/------------------------------------------------------/"
  
  - chmod +x ./gradlew # Set rights for gradlew project usage

android_build:
  stage: build
  script:
    - ./gradlew clean assembleRelease
  artifacts:
    name: "build_${CI_PROJECT_NAME}_${CI_BUILD_REF_NAME}_${CI_JOB_NAME}_${CI_JOB_ID}"
    when: always
    paths:
      - app/build/outputs/apk/
      - app/build/outputs/mapping/

```

更多gitlab-ci 配置参考 : [TestCIAndroid](https://gitlab.com/imtianx/TestCIAndroid)

> 这里使用 gitlab 官方的，如果是自己搭建的gitlab,需要安装 git-runner,并且对项目进行设置。对于 CI 平台，国外做的比较好还有 [Travis CI](https://www.travis-ci.org/) 和 [CircleCI](https://circleci.com/)，其中[我的博客](https://github.com/imtianx/imtianx.github.io) 是通过 `Travis CI` 来自动构建的。


> 记录一个坑：
> 最近使用 [rancher](https://www.cnrancher.com/) 来管理docker容器，折腾了一上午仍然无法启动 rancher 容器，最后发现 **rancher 容器默认只能用 8080 端口**。

参考资料：

**1.[《Docker 技术入门与实践》](https://github.com/yeasy/docker_practice)**
**2. [Docker Docs](https://docs.docker.com/)**




