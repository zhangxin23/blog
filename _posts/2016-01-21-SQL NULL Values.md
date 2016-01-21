---
layout: post
title: "SQL NULL Values"
description: "SQL NULL Values"
category: MySQL
tags: [MySQL]
---

NULL代表缺失的、未知的数据。表的列值默认是NULL。如果某个表的某个列不是NOT NULL的，那么当我们插入新纪录、更新已存在的记录时，可以不用为此列赋值，这意味着那个列保存为NULL值。

###NULL值特性

	NULL应和其它值区别对待。
	NULL被认为是未知或者不兼容值的占位符。
	NULL不能和0进行比较，它们不相等。
	不能用比较运算符（如=，<等）测试某个field和NULL的关系。
	只能用“IS NULL”和“IS NOT NULL”判断某个field是否为NULL。
