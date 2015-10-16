---
layout: post
title: "mysql的interval函数用法"
description: "mysql的interval函数用法"
category: mysql
tags: [mysql, interval]
---

Name: 'INTERVAL'
Description:
Syntax:
INTERVAL(N,N1,N2,N3,...)

Returns 0 if N < N1, 1 if N < N2 and so on or -1 if N is NULL. All
arguments are treated as integers. It is required that N1 < N2 < N3 <
... < Nn for this function to work correctly. This is because a binary
search is used (very fast).

URL: http://dev.mysql.com/doc/refman/5.5/en/comparison-operators.html

Examples:

	mysql> SELECT INTERVAL(23, 1, 15, 17, 30, 44, 200);
	        -> 3
	mysql> SELECT INTERVAL(10, 1, 10, 100, 1000);
	        -> 2
	mysql> SELECT INTERVAL(22, 23, 30, 44, 200);
	        -> 0
