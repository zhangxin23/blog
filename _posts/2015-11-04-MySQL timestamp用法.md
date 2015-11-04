---
layout: post
title: "MySQL timestamp用法"
description: "MySQL timestamp用法"
category: mysql
tags: [mysql]
---

与timestamp类型相关的类型包括：date类型与datetime类型。date类型只包含日期部分，不包含时间部分，它的格式为'YYYY-MM-DD'，支持的范围为'1000-01-01' to '9999-12-31'。datetime类型包含日期和时间两部分，它的格式为'YYYY-MM-DD HH:MM:SS'，支持的范围为'1000-01-01 00:00:00' to '9999-12-31 23:59:59'。timestamp也包含日期和时间两部分，支持的范围为'1970-01-01 00:00:01' UTC to '2038-01-19 03:14:07' UTC。

MySQL将timestamp值从当前时区转换为UTC存储，查询时再从UTC转换为当前时区的值。

timestamp支持自动初始化和更新到当前日期和时间。下面是自动初始化和更新到当前日期和时间的几种组合方式：

	With both DEFAULT CURRENT_TIMESTAMP and ON UPDATE CURRENT_TIMESTAMP, the column has the current timestamp for its default value and is automatically updated to the current timestamp.
	CREATE TABLE t1 (
	  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	);

	With neither DEFAULT CURRENT_TIMESTAMP nor ON UPDATE CURRENT_TIMESTAMP, it is the same as specifying both DEFAULT CURRENT_TIMESTAMP and ON UPDATE CURRENT_TIMESTAMP.
	CREATE TABLE t1 (
	  ts TIMESTAMP
	);

	With a DEFAULT clause but no ON UPDATE CURRENT_TIMESTAMP clause, the column has the given default value and is not automatically updated to the current timestamp.
	The default depends on whether the DEFAULT clause specifies CURRENT_TIMESTAMP or a constant value. With CURRENT_TIMESTAMP, the default is the current timestamp.
	CREATE TABLE t1 (
	  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);

	With a constant, the default is the given value. In this case, the column has no automatic properties at all.
	CREATE TABLE t1 (
	  ts TIMESTAMP DEFAULT 0
	);

	With an ON UPDATE CURRENT_TIMESTAMP clause and a constant DEFAULT clause, the column is automatically updated to the current timestamp and has the given constant default value.
	CREATE TABLE t1 (
	  ts TIMESTAMP DEFAULT 0 ON UPDATE CURRENT_TIMESTAMP
	);

	With an ON UPDATE CURRENT_TIMESTAMP clause but no DEFAULT clause, the column is automatically updated to the current timestamp. The default is 0 unless the column is defined with the NULL attribute, in which case the default is NULL.
	CREATE TABLE t1 (
	  ts TIMESTAMP ON UPDATE CURRENT_TIMESTAMP      -- default 0
	);
	CREATE TABLE t2 (
	  ts TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP -- default NULL
	);

datetime或者timestamp类型可在末尾包含小数部分，用于表示毫秒数。

无效的date、datetime、timestamp值会转换为'0000-00-00' 或者 '0000-00-00 00:00:00'。

MySQL采用如下规则处理两位数年的情况：

	00-69被转换为2000-2069
	70-99被转换为1970-1999