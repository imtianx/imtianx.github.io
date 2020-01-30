#!/bin/bash

# 使用已部署文件初始化目标
git clone --depth 1 --branch=master https://github.com/imtianx/imtianx.github.io.git .deploy_git

cd .deploy_git

＃从 ../public/ 复制之前删除所有文件
# 这样 git 可以跟踪上次提交中删除的文件
find . -path ./.git -prune -o -exec rm -rf {} \; 2> /dev/null

cd ../

# 部署
hexo clean
hexo deploy