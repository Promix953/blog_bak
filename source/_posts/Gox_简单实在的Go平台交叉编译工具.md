---
title: Gox_简单实在的Go平台交叉编译工具
date: 2017-04-08 21:40:59
tags: Golang
---
Gox 是一个简单的，不花俏的Go平台交叉编译工具，它的用处就和标准的 go build 一样。Gox 会并行地为多种平台编译。Gox 同时也提供了一套交叉编译工具链。  
Gox 项目地址：https://github.com/mitchellh/gox  
<!--more-->
# 安装
为了安装 Gox，请使用 go get。我们已经为版本打上了标签，所以可以随便切换标签进行编译：
``` sh
$ go get github.com/mitchellh/gox
...
$ gox -h
...
```
# 用法
在你使用 Gox 之前，你必须先有一套交叉编译工具链。Gox 可以自动帮你完成这个。你需要做的只是运行(每次更新 Go 都要这样做这步)：  
``` sh
$ gox -build-toolchain ...
```
当你完成这个，你可以已经准备好进行交叉编译了。  
如果你知道怎么去使用 go build, 那么你也知道怎么去使用 Gox 了。例如，编译当前的项目，无需提供参数，只需要调用 gox。Gox 就会根据 CPU 的数量并行地为各个平台编译：  
``` sh
$ gox Number of parallel builds: 4
--> darwin/386: github.com/mitchellh/gox
--> darwin/amd64: github.com/mitchellh/gox
--> linux/386: github.com/mitchellh/gox
--> linux/amd64: github.com/mitchellh/gox
--> linux/arm: github.com/mitchellh/gox
--> freebsd/386: github.com/mitchellh/gox
--> freebsd/amd64: github.com/mitchellh/gox
--> openbsd/386: github.com/mitchellh/gox
--> openbsd/amd64: github.com/mitchellh/gox
--> windows/386: github.com/mitchellh/gox
--> windows/amd64: github.com/mitchellh/gox
--> freebsd/arm: github.com/mitchellh/gox
--> netbsd/386: github.com/mitchellh/gox
--> netbsd/amd64: github.com/mitchellh/gox
--> netbsd/arm: github.com/mitchellh/gox
--> plan9/386: github.com/mitchellh/gox
```
或者，你只想编译某个项目和子项目：  
``` sh
$ gox ./... ...
```
或者，你想仅仅为 linux 编译：  
``` sh
$ gox -os="linux" ...
```
或者，你仅仅只想为 64 位的 linux 编译：  
``` sh
$ gox -osarch="linux/amd64" ...
```
还有更多的选项，可以通过 gox -h 查看帮助。
# 和其他交叉编译工具的比较
非常感谢这些工具为我们提供了更多的选择，它们为 go 平台的交叉编译工具提供做了很多方面的贡献.  
  * Dave Cheney的交叉编译器： Gox 可以为多种平台编译，所以也能容易地运行在各种 Go 支持的平台上。但Dave的那个需要一个 shell 来运行。Gox 支持并行地编译，但 Dave 的只是按顺序地编译。Gox 也能非常方便地使用的内置的 arch 系统的内置过滤工具。
  * goxc：它是一个功能丰富的工具，能编译系统项目，上传二进制文件，产生下载页面等；相较之下，Gox 在交叉编译二元文件方面稍稍弱些。但 Gox 能并行地编译项目，而 goxc 不能。Gox 也没有强制指定编译二元文件时输出结果的格式。