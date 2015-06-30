---
layout: post
title: "java Arrays.asList用法"
description: "java Arrays.asList用法"
category: java
tags: [java, Arrays]
---

##java Arrays.asList用法

###用途

Arrays是java容器相关操作的工具类，asList方法将Array转换为list，是Array和List之间的桥梁。

###注意

Arrays.asList返回一个基于参数array的fixed list，即不能对返回的list进行修改操作，如删除操作、增加操作等。如果想获得可修改的List，那么可采用如下方式操作：

	new ArrayList<Integer>(Arrays.asList(arr))
	注：then you create new ArrayList, which is a full, independent copy of the original one. Although here you create the wrapper using Arrays.asList as well, it is used only during the construction of the new ArrayList and is garbage-collected afterwards. The structure of this new ArrayList is completely independent of the original array. It contains the same elements (both the original array and this new ArrayList reference the same integers in memory), but it creates a new, internal array, that holds the references. So when you shuffle it, add, remove elements etc., the original array is unchanged.

	new LinkedList<Integer>(Arrays.asList(arr))
	注：LinkedList支持更快的remove操作。
