---
layout: post
title: "C_INCLUDE_PATH,CPLUS_INCLUDE_PATH和LIBRARY_PATH的用法"
description: "C_INCLUDE_PATH,CPLUS_INCLUDE_PATH和LIBRARY_PATH的用法"
category: C
tags: [C]
---

###C_INCLUDE_PATH,CPLUS_INCLUDE_PATH和LIBRARY_PATH的用法
C_INCLUDE_PATH(for C header files)和CPLUS_INCLUDE_PATH(for C++ header files)的环境变量是指明头文件的搜索路径，此两个环境变量指明的头文件会在-I指定路径之后，系统默认路径之前进行搜索。

LIBRARY_PATH指明库搜索路径，此环境变量指明路径会在-L指定路径之后，系统默认路径之前被搜索。

	$C_INCLUDE_PATH=/opt/example/include
	$export C_INCLUDE_PATH

	$CPLUS_INCLUDE_PATH=/opt/example/include
	$export CPLUS_INCLUDE_PATH

	$LIBRARY_PATH=/opt/example/lib
	$export LIBRARY_PATH