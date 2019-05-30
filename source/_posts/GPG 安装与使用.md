---
title: GPG 安装与使用
date: 2019-05-29 16:06:25
img: http://img.imtianx.cn/2019/logo-gnupg-light-purple-bg.png
categories: [工具软件]
tags: [GPG,Git,加密]
summary: GnuPG（GNU Privacy Guard,GPG）是一种加密软件，它是 PGP 加密软件的满足GPL协议的替代物 。用于加密、数字签章及产生非对称匙对的软件 。用于加密、签名通信内容及管理非对称密码学的密钥。ss
---


## 说明
最近使用 `GitHub` 时无意间看见 `commit` 历史中有些带有 `Verified` 的标识，而有些没有，如下图，
![](http://img.imtianx.cn/2019/github_log_verify.png)

> 经查看发现 `Github` 默认使用了 **GPG** 进行签名(用其自己的 key ),来保证提交信息来自可靠的来源。

[官方说明](https://help.github.com/en/articles/managing-commit-signature-verification)：
> You can sign your work locally using GPG or S/MIME. GitHub will verify these signatures so other people will know that your commits come from a trusted source. GitHub will automatically sign commits you make using the GitHub web interface.

**关于 GPG**
> **[GnuPG](https://gnupg.org/)**（GNU Privacy Guard,GPG）是一种加密软件，它是 PGP 加密软件的满足GPL协议的替代物 。用于加密、数字签章及产生非对称匙对的软件 <!--more-->^[1] 。**用于加密、签名通信内容及管理非对称密码学的密钥**。

这里简记 `GPG` 安装配置到 `Git` 中遇到的相关问题及解决办法。

## 安装及生成密钥
官网为：[https://gnupg.org](https://gnupg.org)，软件包有：
- win: [Gpg4win](http://www.gpg4win.org/)，或者 [Cygwin](http://cygwin.org/) 内置的 `Gnupg`;
- mac : [GPGTools](https://gpgtools.org/)(GUI 界面)；
- linux/unix: 包管理器安装或源码编译。

> 这里以 `brew` 安装 `gnupg` 为例。

**1、安装**
当前安装的软件包为目前最新的：`brew info gpg`

```
 > brew info gpg
gnupg: stable 2.2.15 (bottled)
GNU Pretty Good Privacy (PGP) package
https://gnupg.org/
/usr/local/Cellar/gnupg/2.2.15 (135 files, 11MB) *
  Poured from bottle on 2019-05-29 at 10:17:33
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/gnupg.rb
==> Dependencies
Build: pkg-config ✔
Required: adns ✔, gettext ✔, gnutls ✔, libassuan ✔, libgcrypt ✔, libgpg-error ✔, libksba ✔, libusb ✔, npth ✔, pinentry ✔
==> Analytics
install: 30,935 (30 days), 134,827 (90 days), 517,582 (365 days)
install_on_request: 25,763 (30 days), 108,154 (90 days), 407,474 (365 days)
build_error: 0 (30 days)
> 
```

由于依赖较多，可以给 `brew` 设置镜像源来加速，然后进行安装：

```
brew install gpg
```

> 网上有说安装 `gpg2`,经测试安装的均是 `gnupg`。

**2、生成密钥**
非新使用 `gpg` ,可以使用 `gpg -k` 查看是否有证书，如下为有证书的示例:

```
 > gpg -k
/Users/imtianx/.gnupg/pubring.kbx
---------------------------------
pub   rsa4096 2019-05-28 [SC]
      0A50E2B85C6E124AD0A1701FBFB191F8AFA7E860
uid           [ultimate] imtianx (Signed-off-by imtianx on mbp.) <imtianx@gmail.com>
sub   rsa4096 2019-05-28 [E]
> 
```

如果没有，使用如下命令进行生成：

```
gpg --full-generate-key
```
接着会有如下相关的提示，按照步骤设置信息：
1. 选择加密算法，`回车` 默认 `RSA` 和 `RSA`,或可输入对应的序号选择加密算法；
2. 输入密钥长度，默认 `2048`,最大 `4096`,推荐使用 `4096`,输入然后回车；
3. 密钥有效期，默认 `0` 永不过期；
 
  ```
 0 = 密钥永不过期
 <n> = 密钥在 n 天后过期
 <n>w = 密钥在 n 周后过期
 <n>m = 密钥在 n 月后过期
 <n>y = 密钥在 n 年后过期 
 ```

1. 确认是否正确；
2. 设置个人信息：姓名、邮箱和注释（这个在以后可以进行添加删除等操作）；
3. 确认用户标识，若无需修改，确认后即可生成密钥。

> 由于个人的 `gpg` 未使用过，这里未给出具体的创建信息。

具体的步骤可参考：
- [Github-Generating a new GPG key]()
- [阮一峰-GPG入门教程](http://www.ruanyifeng.com/blog/2013/07/gpg.html)

> 如果想要可视化页面操作，Mac 用户可以直接安装 [GPGTools](https://gpgtools.org/)。

## 常用命令
查看密钥信息，ID 为  `BFB191F8AFA7E860`:
```
 > gpg --list-secret-keys --keyid-format LONG
/Users/imtianx/.gnupg/pubring.kbx
---------------------------------
sec   rsa4096/BFB191F8AFA7E860 2019-05-28 [SC]
      0A50E2B85C6E124AD0A1701FBFB191F8AFA7E860
uid                 [ultimate] imtianx (Signed-off-by imtianx on mbp.) <imtianx@gmail.com>
ssb   rsa4096/B331F00185D28960 2019-05-28 [E]
```
显示公钥内容;
```
gpg --armor --export <gpg_kek_id>
```
输出公钥到文件 `public-key.txt`：
```
gpg --armor --output public-key.txt --export <gpg_kek_id>
```

`gpg` 加密文件：
```
gpg --recipient <gpg_key_id> --output <output_file_name> --encrypt <input_file_name>
```
`gpg` 解密：
```
gpg --output <output_file_name> --decrypt <input_file_name>
```
> 这里需要注意，--output 参数需要放前面。如果未将私钥的密码保存到钥匙串，这里会弹出输入密码窗口。

此外，可以将自己的公钥上传到 GPG server,供他人使用。其他更多命令，可通过 `gpg --help` 查看。

**添加用户标识信息：**
```
gpg --edit-key <gpg_key——id>/<email>
```
进入 `gpg` 后可使用 `help` 查看所有的操作：

```
pg> help
quit        quit this menu
save        save and quit
help        show this help
fpr         show key fingerprint
grip        show the keygrip
list        list key and user IDs
uid         select user ID N
key         select subkey N
check       check signatures
sign        sign selected user IDs [* see below for related commands]
lsign       sign selected user IDs locally
tsign       sign selected user IDs with a trust signature
nrsign      sign selected user IDs with a non-revocable signature
adduid      add a user ID
addphoto    add a photo ID
deluid      delete selected user IDs
addkey      add a subkey
addcardkey  add a key to a smartcard
keytocard   move a key to a smartcard
bkuptocard  move a backup key to a smartcard
delkey      delete selected subkeys
addrevoker  add a revocation key
delsig      delete signatures from the selected user IDs
expire      change the expiration date for the key or selected subkeys
primary     flag the selected user ID as primary
pref        list preferences (expert)
showpref    list preferences (verbose)
setpref     set preference list for the selected user IDs
keyserver   set the preferred keyserver URL for the selected user IDs
notation    set a notation for the selected user IDs
passwd      change the passphrase
trust       change the ownertrust
revsig      revoke signatures on the selected user IDs
revuid      revoke selected user IDs
revkey      revoke key or selected subkeys
enable      enable key
disable     disable key
showphoto   show selected photo IDs
clean       compact unusable user IDs and remove unusable signatures from key
minimize    compact unusable user IDs and remove all signatures from key

* The 'sign' command may be prefixed with an 'l' for local signatures (lsign),
  a 't' for trust signatures (tsign), an 'nr' for non-revocable signatures
  (nrsign), or any combination thereof (ltsign, tnrsign, etc.).
```
> 修改标识比较麻烦，推荐新建，旧的标识如果未使用可以删除，若有使用可以是指撤销。

## Git 配置
对于在 Git 中使用，需要开启签名，设置密钥Id：
```
git config --global user.signingkey <key_id>
// 如果是 gpg2 ，需对应的更换
git config --global gpg.program gpg
// 开启提交签名，或者 commit 时添加 -s 参数
git config --global commit.gpgsign true
```
**未使用 GPGTools，添加到环境变量：**
```
export GPG_TTY=$(tty)
```
> 注意需要在对应的 Git 服务网站（GitHub/Gitlab）添加 GPG 公钥；
> 还有用户信息呢需要对应。

然后在使用的时候，commit 记录就会有校验通过的标识，如下:
![](http://img.imtianx.cn/2019/git_verified.png)

在查看 git log 时可以显示相关的签名信息：
```
git log --show-signature -1
```
输出为：
```
commit 6b05e365de6a28b3054a5e6481c8e214552d2010
gpg: Signature made Tue May 28 15:53:24 2019 CST
gpg:                using RSA key 0A50E2B85C6E124AD0A1701FBFB191F8AFA7E860
gpg: Good signature from "imtianx (Signed-off-by imtianx on mbp.) <imtianx@gmail.com>" [ultimate]
Author: imtianx <imtianx@gmail.com>
Date:   Tue May 28 15:53:24 2019 +0800

    test gpg;
```

可以参考 Gtihub 文档：[Telling Git about your signing key](https://help.github.com/en/articles/telling-git-about-your-signing-key)

> 如有问题可参见 [常见错误](#common_error)



## Sourcetree 配置

与 Git 设置相比，这里较为麻烦。
首先，`Sourcetree` 默认支持 `gpg2`,这里需要设置 gpg2 的软连接否则 sourcetree 无法识别：

```
// 进入 gnupg 安装目录中的bin中
cd /usr/local/Cellar/gnupg/2.2.15/bin
ln -s gpg gpg2
```

然后设置 gpg 目录，如下图：
![](http://img.imtianx.cn/2019/sourcetree_gpg_folder.png)

接着,开启仓库 gpg 设置：
![](http://img.imtianx.cn/2019/sourcetree_pgp_repo.png)

然后，开启签名设置：
![](http://img.imtianx.cn/2019/sourcetree_commit_sign.png)

在首次提交时，未保存私钥密码，会弹出如下弹框:
![](http://img.imtianx.cn/2019/sourcetree_gpg_pwd.png)

最后，开启签名后的提交信息如下：
![](http://img.imtianx.cn/2019/sourcetree_commit_log.png)

到此，整个 `Sourcetree` 的配置完成，遇到较多的问题可能就是 commit 加密失败。

<h2 id='common_error'>常见错误</h2>


<font color="red">1、commit 签名错误：</font>

```
error: gpg failed to sign the data
fatal: failed to write commit object
```

可以在终端输入：

```
export GPG_TTY=$(tty)
```

然后，测试 gpg ,弹出密码框并确认输入后可暂时解决，如下测试示例：

```
echo "test" | gpg --clearsign
```

<font color="red">可以使用下面方式彻底解决，会弹出输入密码弹框</font>

```
brew install pinentry-mac
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent
```

<font color="red">2、agent_genkey 错误</font>

```
gpg: agent_genkey failed: No such file or directory
```

查找该进程并kill 掉：
```
ps axu | grep gpg-agent
kill -9 <process_id>
```

> 如有问题，请留言交流。


[维基教科书-GPG]: https://zh.wikibooks.org/zh-hans/GPG



