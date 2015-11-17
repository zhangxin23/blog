---
layout: post
title: "Java String Top 10问题"
description: "Java String Top 10问题"
category: java
tags: [java, string]
---

###1 如何比较字符串，“==”或者equals()？

”==“用于判断引用是否相等，equals()用于判断值是否相等。除非想判断两个字符串是否为同一个对象，否则最好经常使用equals()。 

###2 敏感信息为何优先选择char[]？

String是不可变的，即创建之后不可改变，它们一直保持不变直到GC收集它们。而char数组是可以改变其中的元素的。如果采用数组存储敏感信息（比如密码）将不会充斥在系统各处。

###3 String能用于switch的case语句吗？

在JDK 7中可以，JDK6之前不能。

	// java 7 only!
	switch (str.toLowerCase()) {
		case "a":
			value = 1;
			break;
		case "b":
			value = 2;
			break;
	}

###4 String如何转换为int？

	int n = Integer.parseInt("0");

###5 如何用空格划分字符串？

	String[] strArray = aString.split("\\s+");

###6 substring()如何工作的？

在JDK 6中，substring()不会创建一个新字符串，而只是返回char数组的窗口。如果想返回一个新的字符串，可采用如下方式：

	str.substring(m, n) + "";

上面的方法有时会使你的代码更快，因为GC能够回收不再使用的原始的字符串，而保留子字符串。

而在JDK 7中，substring()会创建一个新的char数组，不再使用原来的。

###7 String vs StringBuilder vs StringBuffer

String vs StringBuilder：StringBuilder是可改变的，即在创建后可以更改。

StringBuiler vs StringBuffer：StringBuffer是同步的，即是线程安全的，但是会比StringBuiler慢。

###8 如何重复一个字符串？

可以Apache Commons Lang包中的StringUtils类的repeat方法：

	String str = "abcd";
	String repeated = StringUtils.repeat(str,3);
	//abcdabcdabcd

###9 如何将一个String转换为Date？

	String str = "Sep 17, 2013";
	Date date = new SimpleDateFormat("MMMM d, yy", Locale.ENGLISH).parse(str);
	System.out.println(date);
	//Tue Sep 17 00:00:00 EDT 2013

###10 如何计算一个字符串中某个字符出现的次数？

使用apache commons lang包中的StringUtils类。

	int n = StringUtils.countMatches("11112222", "1");
	System.out.println(n);