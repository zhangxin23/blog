---
layout: post
title: "mysql index的长度限制"
description: "mysql index的长度限制"
category: mysql
tags: [mysqk, utf8mb4, emoji]
---

在InnoDB Storage Engine中单独一个列的最大的索引长度为767bytes，utf8字符集中，一个字符占3个字节，所以如果列的类型为char，那么要想在此列上建立索引，此列最多只能有255个字符。如果是utf8mb4字符集，一个字符占4个字节，那么要想在此列上建立索引，此列最多包含191个字符。

在MyIASM Storage Engine中单独一个列的最大的key长度为1000bytes，字符个数和上面算法一致。