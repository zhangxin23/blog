---
layout: post
title: "Random的nextInt用法"
description: "Random的nextInt用法"
category: java
tags: [java, random]
---

因为想当然的认为Random类中nextInt()（注：不带参数），会产生伪随机的正整数，采用如下的方式生成0~99之间的随机数：

	Random random = new Random();
	random.nextInt() % 100;

但是在运行的时候，发现上面的方法有时会产生负数，通过查看Random类的源代码才发现，不带参数的nextInt会产生所有有效的整数，所以当然会有负数产生了。

正确的解法应该是：

	Random random = new Random();
	random.nextInt(100); //100是不包含在内的，只产生0~99之间的数。