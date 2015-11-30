---
layout: post
title: "java命令行运行jar里的main类"
description: "java命令行运行jar里的main类"
category: java
tags: [java]
---

一般运行包含manifest的jar包，可以使用

	java -jar <jar-file-name>.jar

如果jar里没有 manifest，则可以使用

	java -cp foo.jar full.package.name.ClassName

当main类依赖多个jar时，可以把多个jar打包到一个目录，然后用-Djava.ext.dirs指定该目录，引用依赖的多个jar。

	java -Djava.ext.dirs=<多个jar包的目录> com.test.HelloWordMain

如果用-cp则需要写每一个jar，很麻烦。