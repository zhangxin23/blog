---
layout: post
title: "application/xml和text/xml的区别"
description: "application/xml和text/xml的区别"
category: http
tags: [http]
---

XML有两个MIME类型，application/xml和text/xml，它们之间的区别是：

	text/xml忽略xml文件头中的关于编码的设定（<?xml version=”1.0” encoding=”UTF-8”?>），默认采用us-ascii编码。

	application/xml会依照xml文件头中编码的设定。

推荐使用application/xml。
