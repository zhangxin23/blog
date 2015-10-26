---
layout: post
title: "MySQL select into outfile用法"
description: "MySQL select into outfile用法"
category: mysql
tags: [mysql]
---

##select into outfile用法

    SELECT ... FROM TABLE_A
    INTO OUTFILE "/path/to/file"
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n';

##load data infile用法

    LOAD DATA INFILE "/path/to/file" INTO TABLE table_name;
    注意：如果导出时用到了FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'语句，那么LODA时也要加上同样的分隔限制语句。还要注意编码问题。


##解决select into outfile，不能导出到自定义目录问题

Recent Ubuntu Server Editions (such as 10.04) ship with AppArmor and MySQL's profile might be in enforcing mode by default. You can check this by executing sudo aa-status like so:

    > sudo aa-status
        5 profiles are loaded.
        5 profiles are in enforce mode.
           /usr/lib/connman/scripts/dhclient-script
           /sbin/dhclient3
           /usr/sbin/tcpdump
           /usr/lib/NetworkManager/nm-dhcp-client.action
           /usr/sbin/mysqld
        0 profiles are in complain mode.
        1 processes have profiles defined.
        1 processes are in enforce mode :
           /usr/sbin/mysqld (1089)
        0 processes are in complain mode.

If mysqld is included in enforce mode, then it is the one probably denying the write. Entries would also be written in /var/log/messages when AppArmor blocks the writes/accesses. What you can do is edit /etc/apparmor.d/usr.sbin.mysqld and add /data/ and /data/* near the bottom like so:

    /usr/sbin/mysqld {
        ...
        /var/log/mysql/ r,
        /var/log/mysql/* rw,
        /var/run/mysqld/mysqld.pid w,
        /var/run/mysqld/mysqld.sock w,
        /data/ r,
        /data/* rw,
    }

And then make AppArmor reload the profiles.

    > sudo /etc/init.d/apparmor reload
