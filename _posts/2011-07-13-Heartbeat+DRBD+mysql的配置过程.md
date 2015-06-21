---
layout: post
title: " Heartbeat+DRBD+mysql的配置过程 "
description: " Heartbeat+DRBD+mysql的配置过程"
category: Linux
tags: [Linux, Heartbeat, DRBD, MySQL]
---

###1 Heartbeat配置过程

测试平台：

    vmware下RHEL-5.4
    test3 eth0 192.168.0.51
    test4 eht0 192.168.0.52

####1.1   安装

注：以下的安装步骤都是在主机上装的，备机上执行相同的步骤。还有一点需要注意，就是不能简单拷贝虚拟机文件，需要在主从机上分别安装。

下列包必须安装：

    flex
    bison
    libnet
    net-snmp-devel
    OpenIPMI
    docbook-style-xsl
    autoconf
    automake
    libtool

还有上面的包需要的一些依赖包需要安装（数量比较多，这里就不一一列出了，用时可以在系统安装盘里找到需要的rpm包）。

添加用户：

    useradd -M hacluster
    groupadd haclient
    usermod -g haclient hacluster
 

先安装Reusable-Cluster-Components-glue-1.0.5.tar.bz2

    ./autogen.sh
    ./configure
    make
    sudo make install

再安装Heartbeat-3-0-STABLE-3.0.3.tar.bz2
        
    ./bootstrap
    ./ConfigureMe configure
    make
    make install

最后安装Cluster-Resource-Agents-agents-1.0.3.tar.bz2

    ./autogen.sh
    ./configure
    make
    make install

在这个安装过程中，需要复制/usr/local/lib里的所有文件到/usr/lib中，如果存在相同的文件，不需要覆盖。

拷贝Heartbeat-3-0-STABLE-3.0.3目录下的authkeys、ha.cf、haresources到/etc/ha.d/中，还需要拷贝/home/heartbeat/Cluster-Resource-Agents-agents-1.0.3/heartbeat目录下的shellfuncs到/etc/ha.d/中。

####1.2   配置

注：下面的配置过程是在主机（test3）上的配置过程，从机上的配置过程一样，除了红色标出的部分，从机上要填主机的IP地址。

配置authkeys

    有三种认证方式，选择其中一种即可。而且要把authkeys的执行权限变为600，命令如下：chmod 600 authkeys

配置ha.cf

    去掉如下行的前面的#号

    debugfile /var/log/ha-debug
    logfile /var/log/ha-log
    keepalive 2
    deadtime 30
    warntime 10
    initdead 120
    udpport 694
    ucast eth0 192.168.0.52
    auto_failback on
    node    test3
    node    test4

配置haresources
在haresources文件末尾填入如下内容：
 
    test3192.168.0.55 httpd
    test3表明哪个机器是主机
    192.168.0.55是虚拟IP地址，即集群对外服务的地址
    httpdheartbeat管理的服务

####1.3   测试

可进行如下几种情况测试：

    1. 主机heartbeat关闭，从机heartbeat是否接管过来。
    2. 主机网卡关闭，从机heartbeat是否接管过来。
    3. 主机关机，从机heartbeat是否接管过来。
    4. 主机恢复正常后，启动heartbeat，如果failback功能打开了，主机是否能夺回控制权。

###2  DRBD配置过程

####2.1 硬盘分区

DRBD需要在主从服务器上分别指定一个硬盘分区，而且两个分区的大小最好相同。本次配置过程中，指定了/dev/hda5分区作为DRBD使用的分区，分区大小是1012M。

####2.2 DRBD的安装
  
    tar –xzvf drbd-8.0.0.tar.gz 
    cd drbd-8.0.0 
    make
    make install

make install执行之后：drbd.ko被安装到/lib/modules/$KernelVersion/kernel/drivers/block下。drbd相关工具(drbdadm,drbdsetup)被安装到/sbin下。并会在/etc/init.d/下建立drbd启动脚本。

####2.3 drbd.conf配置文件

DRBD运行时，会读取配置文件/etc/drbd.conf。这个文件里描述了DRBD设备与硬盘分区的映射关系，和DRBD的一些配置参数。
下面是一个drbd.conf文件的简单示例：
    <主机>主机名为test3，IP地址为192.168.0.51，DRBD分区为/dev/hda5。
    <备机>主机名为test4，IP地址为192.168.0.52，DRBD分区为/dev/hda5。
  
主机test3上的配置文件如下：

    #是否参加DRBD使用者统计。默认是yes。

    global { usage-count yes; }

    common{ syncer { rate 1M; } } #设置主备节点同步时的网络速率最大值，单位是字节。

    resourcer0 {  #一个DRBD设备(即:/dev/drbdX)，叫做一个"资源"。里面包含一个DRBD设备的主备节点的相关信息。

              protocol C; # 使用协议C。表示收到远程主机的写入确认后,则认为写入完成。

    net {

       cram-hmac-alg sha1; #设置主备机之间通信使用的信息算法。

       shared-secret"FooFunFactory";

    }

    on test3 {  #每个主机的说明以"on"开头，后面是主机名。在后面的{}中为这个主机的配置。

       device    /dev/drbd0;  # /dev/drbd0使用的磁盘分区是/dev/hda5

       disk      /dev/hda5;

       address   192.168.0.51:7898;  #设置DRBD的监听端口，用于与另一台主机通信

       meta-disk  internal;

    }

    on test4 {

       device    /dev/drbd0;

       disk      /dev/hda5;

       address   192.168.0.52:7898;

       meta-disk  internal;

    }

    } 

备机test4上的/etc/drbd.conf配置同主机test3。

####2.4 DRBD启动

在启动DRBD之前，需要分别在两台主机的/dev/hda5分区上，创建供DRBD记录信息的数据块。
分别在两台主机上执行:

    drbdadmcreate-md r0（“r0”是在drbd.conf里定义的资源名称。）

现在可以启动DRBD了，分别在两台主机上执行：

    /etc/init.d/drbdstart 或者 service drbd start

 

现在可以查看DRBD的状态，在test3上执行命令：cat /proc/drbd，会输出如下信息：

    version: 8.0.0(api:86/proto:86)

    SVN Revision:2713 build by root@test3, 2010-07-29 17:55:57

    0: cs:Connected st:Secondary/Secondaryds:Inconsistent/Inconsistent C r---

      ns:828 nr:488096 dw:488924 dr:20373 al:0bm:56 lo:0 pe:0 ua:0 ap:0

          resync: used:0/31 hits:30517 misses:36starving:0 dirty:0 changed:36

          act_log: used:0/127 hits:207 misses:0starving:0 dirty:0 changed:0

第一行的st表示两台主机的状态都是”备机”状态。ds是磁盘状态，都是”不一致”状态。这是由于DRBD无法判断哪一方为主机，以哪一方的磁盘数据作为标准数据。所以，我们需要初始化一个主机。

在主机test3上执行：#drbdsetup /dev/drbd0primary –o

在test3上执行，会发现主从机正在同步数据，这个过程比较慢，需要等待一段时间。同步完后，ds会变成UpToDate/UpToDate。这时两台机子全是备机，可以看到st还是Secondary/Secondary。我们需要设置test3为主节点，可以输入如下命令：

    drbdadm primary db

可能第一次设置会出现一下错误：

    State changefailed: (-2) Refusing to be Primary without at least one UpToDate disk

    Command ‘drbdsetup/dev/drbd0 primary’ terminated with exit code 11

可以看到，第一次设置主节点时用 drbdadm 命令会失败，所以先用drbdsetup来做，以后就可以用 drbdadm 了。

    drbdsetup/dev/drbd0 primary –o

再次查看2台服务器的drbd状态，可以看到st:Secondary/Secondary 变成了st:Primary/Secondary。

现在可以把主机上的DRBD设备挂载到一个目录上进行使用。备机的DRBD设备无法被挂载，因为它是用来接收主机数据的，由DRBD负责操作。首先要对主机的DRBD设备创建文件系统。执行下面的命令：

    mkfs.ext3 /dev/drbd0

然后在test3上执行下面的命令：

    cd /mnt
    mkdir drbd0
    mount/dev/drbd0 /mnt/drbd0/
    cd drbd0/
    touch test
    ls
        test  lost+found

 

在test4上执行下面的命令：

    /etc/init.d/drbd stop
        Stopping allDRBD resources.
    mkdir drbd0
    mount/dev/hda5 /mnt/drbd0/
    cd drbd0/
    ls
        test  lost+found

可以看到，在主机test3上产生的文件test，也完整的保存在备机test4的DRBD分区上。这就是DRBD的网络RAID-1功能。在主机上的任何操作，都会被同步到备机的相应磁盘分区上，达到数据备份的效果。

DRBD的主备机切换

有时，你需要将DRBD的主备机互换一下。可以执行下面的操作：在主机上，先要卸载掉DRBD设备。

    umount/dev/drbd0 将主机降级为”备机”。
    drbdadmsecondary r0
    cat/proc/drbd

可以看到两台机子都是备机的状态。

在备机test4上执行如下命令，将它升为主机：

    drbdadmprimary r0
    cat/proc/drbd

可以看到test4变为主机，而test3变为备机。

需要注意的问题：

    1. 把主机变为从机时，需要先卸载主机的drbd设备。
    2. 主机上挂载drbd设备，从机不挂载drbd设备，而且也没有办法挂载，因为它是接受主机数据的，由drbd负责操作。
    3. 想要挂载从机的/dev/hda5设备，需要先关闭drbd，这样才能挂载上。
    4. 当mysql的目录指向/mnt/drbd0时，如果mysql是打开的状态，那么这时是卸载不了/dev/drbd0设备的，需要先关闭mysql，才能卸载/dev/drbd0设备。同样，如果/dev/drbd0设备没有挂载上，那么也不能打开mysql服务。
    5. drbd的版本是和内核版本对应的，故一个版本的内核应选择对应的drbd的版本。

###3   mysql的配置过程
       
为了能够同步主从机上的mysql数据库，需要如下几步操作：

    mkdir/mnt/drbd0/mysql
    cp –R/usr/local/mysql/var /mnt/drbd0/mysql/
    cd/mnt/drbd0/mysql
    chown –R mysql.mysql/mnt/drbd0/mysql/
    vi/etc/init.d/mysql(/etc/rc.d/init.d/mysql)
        datadir=/mnt/drbd0/msql/data

注：不同版本的MySQL数据库的datadir目录可能不同，这里需要根据实际版本的情况进行填写。

###4   Heartbeat+DRBD+mysql

这部操作相对来说，比较简单，只要更改Heartbeat的/etc/ha.d/haresources文件即可。在/etc/ha.d/haresources文件中输入如下一行内容：

    test3192.168.0.55 drbddisk::r0 Filesystem::/dev/drbd0::/mnt/drbd0::ext3 mysql httpd

        test3 表示在test3与test4组成的集群中，test3是主机
        192.168.0.55 虚拟IP，也就是对外服务的IP。
        drbddisk::r0 定义使用的drbd资源
        Filesystem::/dev/drbd0::/mnt/drbd0::ext3定义挂载的文件系统
        mysql 定义Heartbeat控制启动/关闭mysql服务。
        httpd 定义Heartbeat控制启动/关闭httpd服务。

需要注意的问题：
    1. 在启动Heartbeat服务之前，一定要先启动drbd服务。
    2. 用chkconfig --del 命令删除随机启动的mysql与httpd服务。这两个服务的启动与关闭应由heartbeat负责执行。