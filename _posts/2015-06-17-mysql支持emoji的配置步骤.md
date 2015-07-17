---
layout: post
category: MySQL
title: "mysql对emoji的支持"
tags: [Linux, MySQL, emoji]
---

###步骤：
1. 升级mysql数据库到5.5.3+

2. 修改database、table和column字符集

		alter database DATABASE_NAME character set = utf8mb4 collate = utf8mb4_unicode_ci;
		alter table TABLE_NAME convert to character set utf8mb4 collate utf8mb4_unicode_ci;
		
		#修改表中类型为varchar、char等类型的列，长度或字符个数视情况而定。
		alter table TABLE_NAME change OLD_COLUMN_NAME NEW_COLUMN_NAME varchar(字符个数) character set utf8mb4 collate utf8mb4_unicode_ci;

3. 修改mysql的配置文件my.cnf
	
		[client]
		default-character-set = utf8mb4

		[mysql]
		default-character-set = utf8mb4

		[mysqld]
		character-set-client-handshake = FALSE
		character-set-server = utf8mb4
		collation-server = utf8mb4_unicode_ci
		init_connect='SET NAMES utf8mb4'

4. 重新启动mysql数据库
	
		service mysql restart；

5. 检查mysql数据库字符集
		
		show variables where variable_name like 'character_set_%' or variable_name like 'collation%';

	检查是否有如下输出：
		
		| Variable_name            		| Value                      		|
		|-----------------------------------------|-----------------------------------------|
		| character_set_client     		| utf8mb4                    		|
		| character_set_connection 	| utf8mb4                    		|
		| character_set_database   	| utf8mb4                    		|
		| character_set_filesystem 	| binary                     		|
		| character_set_results    	| utf8mb4                    		|
		| character_set_server     	| utf8mb4                    		|
		| character_set_system     	| utf8                       		|
		| character_sets_dir       		| /usr/share/mysql/charsets/ 	|
		| collation_connection     	| utf8mb4_unicode_ci         	|
		| collation_database       	| utf8mb4_unicode_ci         	|
		| collation_server         		| utf8mb4_unicode_ci         	|


6. 确认mysql-connector-java的版本，网上说只要大于5.1.13就可以，经过测试5.1.26不可以，但是最新版5.1.35（Mar 17, 2015版本）可以，其它版本未测试

7. 检查服务器端的mysql数据库连接字符串，一定要包含charactorEncoding=utf8、useUnicode=true、autoReconnect=true等字段
		
		注：JDBC Connection String的具体配置可参见：http://dev.mysql.com/doc/connector-j/en/connector-j-reference-configuration-properties.html
