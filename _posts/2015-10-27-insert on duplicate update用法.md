---
layout: post
title: "INSERT ON DUPLICATE KEY UPDATE 用法"
description: "INSERT ON DUPLICATE KEY UPDATE 用法"
category: mysql
tags: [mysql]
---

原文地址：http://dev.mysql.com/doc/refman/5.1/en/insert-on-duplicate.html

If you specify ON DUPLICATE KEY UPDATE, and a row is inserted that would cause a duplicate value in a UNIQUE index or PRIMARY KEY, MySQL performs an UPDATE of the old row. For example, if column a is declared as UNIQUE and contains the value 1, the following two statements have similar effect:

	INSERT INTO table (a,b,c) VALUES (1,2,3)
	  ON DUPLICATE KEY UPDATE c=c+1;

	UPDATE table SET c=c+1 WHERE a=1;

(The effects are not identical for an InnoDB table where a is an auto-increment column. With an auto-increment column, an INSERT statement increases the auto-increment value but UPDATE does not.)

The ON DUPLICATE KEY UPDATE clause can contain multiple column assignments, separated by commas.

With ON DUPLICATE KEY UPDATE, the affected-rows value per row is 1 if the row is inserted as a new row, and 2 if an existing row is updated.

If column b is also unique, the INSERT is equivalent to this UPDATE statement instead:

	UPDATE table SET c=c+1 WHERE a=1 OR b=2 LIMIT 1;

If a=1 OR b=2 matches several rows, only one row is updated. In general, you should try to avoid using an ON DUPLICATE KEY UPDATE clause on tables with multiple unique indexes.

You can use the VALUES(col_name) function in the UPDATE clause to refer to column values from the INSERT portion of the INSERT ... ON DUPLICATE KEY UPDATE statement. In other words, VALUES(col_name) in the ON DUPLICATE KEY UPDATE clause refers to the value of col_name that would be inserted, had no duplicate-key conflict occurred. This function is especially useful in multiple-row inserts. The VALUES() function is meaningful only in INSERT ... UPDATE statements and returns NULL otherwise. Example:

	INSERT INTO table (a,b,c) VALUES (1,2,3),(4,5,6)
	  ON DUPLICATE KEY UPDATE c=VALUES(a)+VALUES(b);

That statement is identical to the following two statements:

	INSERT INTO table (a,b,c) VALUES (1,2,3)
	  ON DUPLICATE KEY UPDATE c=3;
	INSERT INTO table (a,b,c) VALUES (4,5,6)
	  ON DUPLICATE KEY UPDATE c=9;

If a table contains an AUTO_INCREMENT column and INSERT ... ON DUPLICATE KEY UPDATE inserts or updates a row, the LAST_INSERT_ID() function returns the AUTO_INCREMENT value. Exception: For updates, LAST_INSERT_ID() is not meaningful prior to MySQL 5.1.12. However, you can work around this by using LAST_INSERT_ID(expr). Suppose that id is the AUTO_INCREMENT column. To make LAST_INSERT_ID() meaningful for updates, insert rows as follows:

	INSERT INTO table (a,b,c) VALUES (1,2,3)
	  ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id), c=3;

The DELAYED option is ignored when you use ON DUPLICATE KEY UPDATE.

An INSERT ... ON DUPLICATE KEY UPDATE on a partitioned table using a storage engine such as MyISAM that employs table-level locks locks all partitions of the table. This does not occur with tables using storage engines such as InnoDB that employ row-level locking. This issue is resolved in MySQL 5.6. See Section 18.5.4, “Partitioning and Table-Level Locking”, for more information.