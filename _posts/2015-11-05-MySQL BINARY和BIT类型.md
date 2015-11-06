---
layout: post
title: "MySQL BINARY和BIT类型"
description: "MySQL BINARY和BIT类型"
category: mysql
tags: [mysql]
---

###BINARY和VARBINARY类型

BINARY和VARBIANRY类型同CHAR和VARCHAR类型相似，除了BIANARY和VARBINARY类型只包含二进制字符串，即它们只包含byte串而非字符串，它们没有字符集的概念，排序和比较操作都是基于字节的数字值。

BINARY和VARBIANRY类型允许的最大长度同CHAR和VARCHAR一样，除了BINARY和VARBIANRY类型以字节为单位计算长度的，而不是以字符为单位计算长度。

BINARY采用左对齐方式存储，即小于指定长度时，会在右边填充0值，例如：BINARY(3)列，插入‘a\0'时，会变成’a\0\0'值存入。VARBINARY则不用在右边填充0。当在比较的情况下，填充的部分会被忽略掉或者被移除。

###BIT数据类型

BIT数据类型用于存储bit值，能够存储比特长度范围为1~64。

采用 b'value'标记方式指定bit值，其中value是0或者1的序列，例如：b'111'代表7，b'10000000'代表128。

如果设置的0,1串的长度小于BIT(M)的M，那么在左面填充0，例如，将b'101'赋给BIT(6)，那么会存储b'000101'。

	mysql> CREATE TABLE t (b BIT(8));
	mysql> INSERT INTO t SET b = b'11111111';
	mysql> INSERT INTO t SET b = b'1010';
	mysql> INSERT INTO t SET b = b'0101';

直接返回bit是不可读的，如果要变为可读的，可采用"+0"的方式或者用BIN()之类的转换函数， 转换后的值不显示高位0。

	mysql> SELECT b+0, BIN(b+0), OCT(b+0), HEX(b+0) FROM t;

	b+0	BIN(b+0)	OCT(b+0)	HEX(b+0)
	255	11111111	377		FF
	10	1010		12		A
	5	101		5		5   

将bit值赋值给数字或者变量，可使用CAST()函数或者"+0"方式：

	mysql> SET @v1 = 0b1000001;
	mysql> SET @v2 = CAST(0b1000001 AS UNSIGNED), @v3 = 0b1000001+0;
	mysql> SELECT @v1, @v2, @v3;
	
	@v1	@v2	@v3
	A           65	65
