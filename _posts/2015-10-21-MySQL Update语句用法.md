---
layout: post
title: "MySQL Update语句用法"
description: "MySQL Update语句用法"
category: mysql
tags: [mysql]
---

用一个表的某列值更新另外一个表的某列值的sql语句：

	update tableA a innner join tableB b on a.column_1 = b.column_1 set a.column_2 = b.column_2;

用一个表的某列值更新同一个表的另一列值的sql语句：

	update tableA a innner join tableA b on a.column_1 = b.column_1 set a.column_2 = b.column_2;