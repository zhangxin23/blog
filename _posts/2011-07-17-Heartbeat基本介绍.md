---
layout: post
title: "Heartbeat基本介绍 "
description: " Heartbeat基本介绍"
category: Linux
tags: [Linux, Heartbeat]
---

###1 基本介绍

Heartbeat是High-Availability Linux Project (Linux下的高可用性项目)的产物，是一套提供防止业务主机因不可避免的意外性或计划性宕机问题的高可用性软件。Heartbeat可以从Linux-HA 项目Web 站点免费获得，它提供了所有HA （高可用性）系统所需要的基本功能，如启动和停止资源、监测群集中系统的可用性、在群集中的节点间转移共享IP 地址的所有者等。它通过串行线、以太网接口或同时使用两者来监测特定服务（或多个服务）的运行状况。

Heartbeat实现了HA 功能中的核心功能——心跳，将Heartbeat软件同时安装在两台服务器上，用于监视系统的状态，协调主从服务器的工作，维护系统的可用性。它能侦测服务器应用级系统软件、硬件发生的故障，及时地进行错误隔绝、恢复；通过系统监控、服务监控、IP自动迁移等技术实现在整个应用中无单点故障，简单、经济地确保重要的服务持续高可用性。

Heartbeat采用虚拟IP地址映射技术实现主从服务器的切换对客户端透明的功能。

###2 配置文件
Heartbeat有三个配置文件需要进行配置：authkeys、ha.cf、haresources。下面分别介绍这个三个文件。

####1)       authkeys

#####A 文件内容

	#

	#     Authentication file.  Must be mode 600

	#

	#

	#     Must have exactly one auth directive at thefront.

	#     auth      sendauthentication using this method-id

	#

	#     Then, list the method and key that go withthat method-id

	#

	#     Available methods: crc sha1, md5.  Crc doesn't need/want a key.

	#

	#     You normally only have one authenticationmethod-id listed in this file

	#

	#     Put more than one to make a smoothtransition when changing auth

	#     methods and/or keys.

	#

	#

	#     sha1 is believed to be the"best", md5 next best.

	#

	#     crc adds no security, except from packetcorruption.

	#            Use only on physically securenetworks.

	#

	auth 1

	1 crc

	#2 sha1 HI!

	#3 md5 Hello!



#####B 文件介绍

authkeys文件的权限必须是600。有三种认证模式：crc、sha1、md5，其中crc不需要key。需要选择哪种模式，只要在“auth”字段后填上相应的模式即可，并把相应模式前面的注释井号去掉。

####2)       ha.cf

#####A 文件内容

	#

	#     There are lots of options in thisfile.  All you have to have is a set

	#     of nodes listed {"node ...} one of{serial, bcast, mcast, or ucast},

	#     and a value for "auto_failback".

	#

	#     ATTENTION: As the configuration file isread line by line,

	#              THE ORDER OF DIRECTIVE MATTERS!

	#

	#     In particular, make sure that the udpport,serial baud rate

	#     etc. are set before the heartbeat media aredefined!

	#     debug and log file directives go intoeffect when they

	#     are encountered.

	#

	#     All will be fine if you keep them orderedas in this example.

	#

	#

	#       Note on logging:

	#       If all of debugfile, logfile andlogfacility are not defined,

	#       logging is the same as use_logd yes. Inother case, they are

	#       respectively effective. if detering thelogging to syslog,

	#       logfacility must be "none".

	#

	#     File to write debug messages to

	debugfile/var/log/ha-debug

	#

	#

	#    File to write other messages to

	#

	logfile    /var/log/ha-log

	#

	#

	#     Facility to use for syslog()/logger

	#

	logfacility     local0

	#

	#

	#     A note on specifying "how long"times below...

	#

	#     The default time unit is seconds

	#            10 means ten seconds

	#

	#     You can also specify them in milliseconds

	#            1500ms means 1.5 seconds

	#

	#

	#     keepalive: how long between heartbeats?

	#

	keepalive 2

	#

	#     deadtime: how long-to-declare-host-dead?

	#

	#            If you set this too low you will getthe problematic

	#            split-brain (or cluster partition)problem.

	#            See the FAQ for how to use warntimeto tune deadtime.

	#

	deadtime 30

	#

	#     warntime: how long before issuing"late heartbeat" warning?

	#     See the FAQ for how to use warntime to tunedeadtime.

	#

	warntime 10

	#

	#

	#     Very first dead time (initdead)

	#

	#     On some machines/OSes, etc. the networktakes a while to come up

	#     and start working right after you've beenrebooted.  As a result

	#     we have a separate dead time for whenthings first come up.

	#     It should be at least twice the normal deadtime.

	#

	initdead 120

	#

	#

	#     What UDP port to use for bcast/ucastcommunication?

	#

	udpport       694

	#

	#     Baud rate for serial ports...

	#

	#baud  19200

	#    

	#     serial      serialportname...

	#serial   /dev/ttyS0   #Linux

	#serial   /dev/cuaa0       #FreeBSD

	#serial/dev/cuad0      # FreeBSD 6.x

	#serial   /dev/cua/a       #Solaris

	#

	#

	#     What interfaces to broadcast heartbeatsover?

	#

	#bcast  eth0             #Linux

	#bcast  eth1 eth2     #Linux

	#bcast  le0         #Solaris

	#bcast  le1 le2          #Solaris

	#

	#     Set up a multicast heartbeat medium

	#     mcast [dev] [mcast group] [port] [ttl][loop]

	#

	#     [dev]            deviceto send/rcv heartbeats on

	#     [mcast group]    multicast group to join (class D multicast address

	#                   224.0.0.0 - 239.255.255.255)

	#     [port]            udpport to sendto/rcvfrom (set this value to the

	#                   same value as"udpport" above)

	#     [ttl]        thettl value for outbound heartbeats.  thiseffects

	#                   how far the multicast packetwill propagate.  (0-255)

	#                   Must be greater than zero.

	#     [loop]           togglesloopback for outbound multicast heartbeats.

	#                   if enabled, an outboundpacket will be looped back and

	#                   received by the interface itwas sent on. (0 or 1)

	#                   Set this value to zero.

	#           

	#

	#mcast eth0225.0.0.1 694 1 0

	#

	#     Set up a unicast / udp heartbeat medium

	#     ucast [dev] [peer-ip-addr]

	#

	#     [dev]            deviceto send/rcv heartbeats on

	#     [peer-ip-addr]   IP address of peer to send packets to

	#

	ucast eth0 10.0.0.1

	#

	#

	#     About boolean values...

	#

	#     Any of the following case-insensitivevalues will work for true:

	#            true, on, yes, y, 1

	#     Any of the following case-insensitivevalues will work for false:

	#            false, off, no, n, 0

	#

	#

	#

	#     auto_failback:  determines whether a resource will

	#     automatically fail back to its"primary" node, or remain

	#     on whatever node is serving it until thatnode fails, or

	#     an administrator intervenes.

	#

	#     The possible values for auto_failback are:

	#            on   -enable automatic failbacks

	#            off   -disable automatic failbacks

	#            legacy  - enable automatic failbacks in systems

	#                   where all nodes do not yetsupport

	#                   the auto_failback option.

	#

	#     auto_failback "on" and"off" are backwards compatible with the old

	#            "nice_failback on"setting.

	#

	#     See the FAQ for information on how toconvert

	#            from "legacy" to"on" without a flash cut.

	#            (i.e., using a "rollingupgrade" process)

	#

	#     The default value for auto_failback is"legacy", which

	#     will issue a warning at startup.  So, make sure you put

	#     an auto_failback directive in your ha.cffile.

	#     (note: auto_failback can be any boolean or"legacy")

	#

	auto_failback on

	#

	#

	#       Basic STONITH support

	#       Using this directive assumes that thereis one stonith

	#       device in the cluster.  Parameters to this device are

	#       read from a configuration file. Theformat of this line is:

	#

	#         stonith <stonith_type><configfile>

	#

	#       NOTE: it is up to you to maintain thisfile on each node in the

	#       cluster!

	#

	#stonith baytech/etc/ha.d/conf/stonith.baytech

	#

	#       STONITH support

	#       You can configure multiple stonithdevices using this directive.

	#       The format of the line is:

	#         stonith_host <hostfrom><stonith_type> <params...>

	#         <hostfrom> is the machine thestonith device is attached

	#              to or * to mean it is accessiblefrom any host.

	#         <stonith_type> is the type ofstonith device (a list of

	#              supported drives is in/usr/lib/stonith.)

	#         <params...> are driver specificparameters.  To see the

	#              format for a particular device,run:

	#           stonith -l -t <stonith_type>

	#

	#

	#     Note that if you put your stonith deviceaccess information in

	#     here, and you make this file publicallyreadable, you're asking

	#     for a denial of service attack ;-)

	#

	#     To get a list of supported stonith devices,run

	#            stonith -L

	#     For detailed information on which stonithdevices are supported

	#     and their detailed configuration options,run this command:

	#            stonith -h

	#

	#stonith_host*     baytech 10.0.0.3mylogin mysecretpassword

	#stonith_hostken3  rps10 /dev/ttyS1 kathy 0

	#stonith_hostkathy rps10 /dev/ttyS1 ken3 0

	#

	#     Watchdog is the watchdog timer.  If our own heart doesn't beat for

	#     a minute, then our machine will reboot.

	#     NOTE: If you are using the softwarewatchdog, you very likely

	#     wish to load the module with the parameter"nowayout=0" or

	#     compile it without CONFIG_WATCHDOG_NOWAYOUTset. Otherwise even

	#     an orderly shutdown of heartbeat willtrigger a reboot, which is

	#     very likely NOT what you want.

	#

	#watchdog/dev/watchdog

	#      

	#     Tell what machines are in the cluster

	#     node     nodename...     -- must match uname -n

	node     test3

	node     test4

	#

	#     Less common options...

	#

	#     Treats 10.10.10.254as a psuedo-cluster-member

	#     Used together with ipfail below...

	#     note: don't use a cluster node as ping node 

	#

	#ping 10.10.10.254

	#

	#     Treats 10.10.10.254and 10.10.10.253 as a psuedo-cluster-member

	#       called group1. If either 10.10.10.254or 10.10.10.253 are up

	#       then group1 is up

	#     Used together with ipfail below...

	#

	#ping_groupgroup1 10.10.10.254 10.10.10.253

	#

	#     HBA ping derective for Fiber Channel

	#     Treats fc-card-name as psudo-cluster-member

	#     used with ipfail below ...

	#

	#     You can obtain HBAAPI fromhttp://hbaapi.sourceforge.net.  You need

	#     to get the library specific to your HBAdirectly from the vender

	#     To install HBAAPI stuff, all You need to dois to compile the common

	#     part you obtained from the sourceforge.This will produce libHBAAPI.so

	#     which you need to copy to /usr/lib. Youneed also copy hbaapi.h to

	#     /usr/include.

	#    

	#     The fc-card-name is the name obtained fromthe hbaapitest program

	#     that is part of the hbaapi package. Runninghbaapitest will produce

	#     a verbose output. One of the first line issimilar to:

	#            Apapter number 0 is named:qlogic-qla2200-0

	#     Here fc-card-name is qlogic-qla2200-0.

	#

	#hbapingfc-card-name

	#

	#

	#     Processes started and stopped withheartbeat.  Restarted unless

	#            they exit with rc=100

	#

	#respawn userid/path/name/to/run

	#respawnhacluster /usr/lib/heartbeat/ipfail

	#

	#     Access control for client api

	#             defaultis no access

	#

	#apiauthclient-name gid=gidlist uid=uidlist

	#apiauth ipfailgid=haclient uid=hacluster

	 

	###########################

	#

	#     Unusual options.

	#

	###########################

	#

	#     hopfudge maximum hop count minus number ofnodes in config

	#hopfudge 1

	#

	#     deadping - dead time for ping nodes

	#deadping 30

	#

	#     hbgenmethod - Heartbeat generation numbercreation method

	#            Normally these are stored on diskand incremented as needed.

	#hbgenmethodtime

	#

	#     realtime - enable/disable realtimeexecution (high priority, etc.)

	#            defaults to on

	#realtime off

	#

	#     debug - set debug level

	#            defaults to zero

	#debug 1

	#

	#     API Authentication - replaces thefifo-permissions-based system of the past

	#

	#

	#     You can put a uid list and/or a gid list.

	#     If you put both, then a process isauthorized if it qualifies under either

	#     the uid list, or under the gid list.

	#

	#     The groupname "default" hasspecial meaning.  If it is specified,then

	#     this will be used for authorizing grouplessclients, and any client groups

	#     not otherwise specified.

	#    

	#     There is a subtle exception to this.  "default" will never be used in the

	#     following cases (actual default authdirectives noted in brackets)

	#             ipfail (uid=HA_CCMUSER)

	#             ccm       (uid=HA_CCMUSER)

	#             ping          (gid=HA_APIGROUP)

	#             cl_status   (gid=HA_APIGROUP)

	#

	#     This is done to avoid creating a gapingsecurity hole and matches the most

	#     likely desired configuration.

	#

	#apiauth ipfailuid=hacluster

	#apiauth ccmuid=hacluster

	#apiauth cmsuid=hacluster

	#apiauth pinggid=haclient uid=alanr,root

	#apiauth defaultgid=haclient

	 

	#    message format in the wire, it can be classicor netstring,

	#     default: classic

	#msgfmt  classic/netstring

	 

	#     Do we use logging daemon?

	#     If logging daemon is used,logfile/debugfile/logfacility in this file

	#     are not meaningful any longer. You shouldcheck the config file for logging

	#     daemon (the default is /etc/logd.cf)

	#     more infomartion can be fould in the manpage.

	#     Setting use_logd to "yes" isrecommended

	#    

	# use_logdyes/no

	#

	#     the interval we  reconnect to logging daemon if the previousconnection failed

	#     default: 60 seconds

	#conn_logd_time60

	#

	#

	#     Configure compression module

	#     It could be zlib or bz2, depending onwhether u have the corresponding

	#     library    inthe system.

	#compression    bz2

	#

	#     Confiugre compression threshold

	#     This value determines the threshold tocompress a message,

	#     e.g. if the threshold is 1, then anymessage with size greater than 1 KB

	#     will be compressed, the default is 2 (KB)

	#compression_threshold2

 

#####B 文件介绍

	一些选项的解释：

	debugfile /var/log/ha-debug  配置调试文件存储目录

	logfile /var/log/ha-log            配置日志文件存储目录

	keepalive 2             指明心跳的时间间隔

	deadtime 30               连续多长时间联系不上后认为对方宕机，开始切换服务

	warntime 10               连续多长时间联系不上后开始警告提示

	initdead 120               确定peer节点初始化完毕等待的时间

	udpport 694               bcast/ucast通信的端口

	ucast eth0 10.0.0.1      采用eth0端口的UDP单播来通知心跳

	bcast eth0                 采用eth0的UDP广播来发送心跳

	serial/dev/ttyS0            该参数指定心跳线接在哪一个串口上

	baud 19200                该参数指定串口通讯的波特率

	auto_failbackon              指定on时，主机恢复后抢回控制权；指定off时，主机恢复后不用抢回控制权。

	node    test3

	node    test4             node指定集群系统的节点。node后需要填集群系统中节点的主机名。

	respawnroot /usr/lib/heartbeat/ipfail  指定和heartbeat一起启动、关闭的进程

	ping 10.0.0.1           指定ping节点，通过ping网关来监测心跳是否正常，这些节点不是集群的节点，只是为了像ipfail这样的模块检测网络连接是否通畅

	logfacilitylocal0            这个设置heartbeat的日志，这里用的是系统日志

#####C 配置watchdog

正常情况下，如果你在/etc/ha.d/ha.cf中启用了watchdog支持，heartbeat开关脚本将为你插入这个模块，假设启用了watchdog，现在你应该从内核中移除他，并允许heartbeat在启动时为你添加。使用“#modprobe–r softdog”移除softdog。

当你在/etc/ha.d/ha.cf文件中启用了watchdog选项后，heartbeat将每隔相当于deadtime长的时间写入/dev/watchdog文件。因此出现任何导致hearbeat更新watchdog设备失败的事情，一旦watchdog超时周期（默认一分钟）过期，watchdog将启动内核恐慌。

如果想要watchdog能启动内核恐慌，还需进行如下配置：

编辑/etc/sysctl.conf文件，在文件末尾加入

	kernel.panic_on_oops=1(1表示系统等待重启的时间，单位是秒)

	kernel.panic=1(同上)

然后需要执行“sysctl -p”命令reload配置信息。

配置完后，如果执行”killall -9 heartbeat”命令，会引起系统重启。

#####D ipfail的配置

	ping 10.0.0.1

	respawnhacluster /usr/lib/heartbeat/ipfail

	apiauth ipfailgid=hacluster uid=hacluster

	deadping 5

作用：当ping失败时，会执行ipfail命令，”deadping 5”指定多长时间之后触发ipfail命令。“apiauth ipfailgid=hacluster uid=hacluster“命令配置ipfail命令的gid和uid。

####3)       haresources

#####A 文件内容

	#

	#     This is a list of resources that move frommachine to machine as

	#     nodes go down and come up in thecluster.  Do not include

	#     "administrative" or fixed IPaddresses in this file.

	#

	# <VERYIMPORTANT NOTE>

	#     The haresources files MUST BE IDENTICAL onall nodes of the cluster.

	#

	#     The node names listed in front of theresource group information

	#     is the name of the preferred node to runthe service.  It is

	#     not necessarily the name of the currentmachine.  If you are running

	#     auto_failback ON (or legacy), then theseservices will be started

	#     up on the preferred nodes - any timethey're up.

	#

	#     If you are running with auto_failback OFF,then the node information

	#     will be used in the case of a simultaneousstart-up, or when using

	#     the hb_standby {foreign,local} command.

	#

	#     BUT FOR ALL OF THESE CASES, the haresourcesfiles MUST BE IDENTICAL.

	#     If your files are different then almostcertainly something

	#     won't work right.

	# </VERYIMPORTANT NOTE>

	#

	#    

	#     We refer to this file when we're coming up,and when a machine is being

	#     taken over after going down.

	#

	#     You need to make this right for yourinstallation, then install it in

	#     /etc/ha.d

	#

	#     Each logical line in the file constitutes a"resource group".

	#     A resource group is a list of resourceswhich move together from

	#     one node to another - in the orderlisted.  It is assumed that there

	#     is no relationship between differentresource groups.  These

	#     resource in a resource group are startedleft-to-right, and stopped

	#     right-to-left.  Long lists of resources can be continued fromline

	#     to line by ending the lines with backslashes("\").

	#

	#     These resources in this file are either IPaddresses, or the name

	#     of scripts to run to "start" or"stop" the given resource.

	#

	#     The format is like this:

	#

	#node-nameresource1 resource2 ... resourceN

	#

	#

	#     If the resource name contains an :: in themiddle of it, the

	#     part after the :: is passed to the resourcescript as an argument.

	#       Multiple arguments are separated by the:: delimeter

	#

	#     In the case of IP addresses, the resourcescript name IPaddr is

	#     implied.

	#

	#     For example, the IP address 135.9.8.7 couldalso be represented

	#     as IPaddr::135.9.8.7

	#

	#     THIS IS IMPORTANT!!     vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	#

	#     The given IP address is directed to aninterface which has a route

	#     to the given address.  This means you have to have a net route

	#     set up outside of the High-Availabilitystructure.  We don't set it

	#     up here -- we key off of it.

	#

	#     The broadcast address for the IP alias thatis created to support

	#     an IP address defaults to the highestaddress on the subnet.

	#

	#     The netmask for the IP alias that iscreated defaults to the same

	#     netmask as the route that it selected in inthe step above.

	#

	#     The base interface for the IPalias that iscreated defaults to the

	#     same netmask as the route that it selectedin in the step above.

	#

	#     If you want to specify that this IP addressis to be brought up

	#     on a subnet with a netmask of255.255.255.0, you would specify

	#     this as IPaddr::135.9.8.7/24 . 

	#

	#     If you wished to tell it that the broadcastaddress for this subnet

	#     was 135.9.8.210, then you would specifythat this way:

	#            IPaddr::135.9.8.7/24/135.9.8.210

	#

	#     If you wished to tell it that the interfaceto add the address to

	#     is eth0, then you would need to specify itthis way:

	#            IPaddr::135.9.8.7/24/eth0

	#

	#       And this way to specify both the broadcastaddress and the

	#       interface:

	#            IPaddr::135.9.8.7/24/eth0/135.9.8.210

	#

	#     The IP addresses you list in this file arecalled "service" addresses,

	#     since they're they're the publiclyadvertised addresses that clients

	#     use to get at highly available services.

	#

	#     For a hot/standby (non load-sharing) 2-nodesystem with only

	#     a single service address,

	#     you will probably only put one system nameand one IP address in here.

	#     The name you give the address to is thename of the default "hot"

	#     system.

	#

	#     Where the nodename is the name of the nodewhich "normally" owns the

	#     resource. If this machine is up, it will always have the resource

	#     it is shown as owning.

	#

	#     The string you put in for nodename mustmatch the uname -n name

	#     of your machine.  Depending on how you have it administered, itcould

	#     be a short name or a FQDN.

	#

	#-------------------------------------------------------------------

	#

	#     Simple case: One service address, defaultsubnet and netmask

	#            No servers that go up and down withthe IP address

	#

	#just.linux-ha.org      135.9.216.110

	#

	#-------------------------------------------------------------------

	#

	#     Assuming the adminstrative addresses are onthe same subnet...

	#     A little more complex case: One serviceaddress, default subnet

	#     and netmask, and you want to start and stophttp when you get

	#     the IP address...

	#

	#just.linux-ha.org      135.9.216.110 http

	#-------------------------------------------------------------------

	#

	#     A little more complex case: Three serviceaddresses, default subnet

	#     and netmask, and you want to start and stophttp when you get

	#     the IP address...

	#

	#just.linux-ha.org      135.9.216.110 135.9.215.111 135.9.216.112 httpd

	#-------------------------------------------------------------------

	#

	#     One service address, with the subnet,interface and bcast addr

	#       explicitly defined.

	#

	#just.linux-ha.org      135.9.216.3/28/eth0/135.9.216.12 httpd

	#

	#-------------------------------------------------------------------

	#

	#       An example where a shared filesystem isto be used.

	#       Note that multiple aguments are passedto this script using

	#       the delimiter '::' to separate eachargument.

	#

	#node1  10.0.0.170 Filesystem::/dev/sda1::/data1::ext2

	#

	#     Regarding the node-names in this file:

	#

	#     They must match the names of the nodeslisted in ha.cf, which in turn

	#     must match the `uname -n` of some node inthe cluster.  So they aren't

	#     virtual in any sense of the word.

#####B 配置方式

haresources文件主要用来指定哪个个节点是主节点、指定虚拟IP、指定heartbeat管理的资源。

格式是：test3 10.0.0.1http,mysql

test3是主机名

10.0.0.1是虚拟IP

http和mysql是需要管理的资源，注意如果要自定义资源，那么必须要写成服务的形式，这样才能由heartbeat进行管理。