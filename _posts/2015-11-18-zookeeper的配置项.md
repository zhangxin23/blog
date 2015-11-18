---
layout: post
title: "zookeeper的配置项"
description: "zookeeper的配置项"
category: zookeeper
tags: [zookeeper]
---

###1 tickTime：CS通信心跳数

Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。tickTime以毫秒为单位。

	tickTime=2000  

###2 initLimit：LF初始通信时限

集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数（tickTime的数量）。
	
	initLimit=5  

###3 syncLimit：LF同步通信时限

集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数（tickTime的数量）。
	
	syncLimit=2  
 
###4 dataDir：数据文件目录

Zookeeper保存数据的目录，默认情况下，Zookeeper将写数据的日志文件也保存在这个目录里。

	dataDir=/home/michael/opt/zookeeper/data  

###5 dataLogDir：日志文件目录

Zookeeper保存日志文件的目录。

	dataLogDir=/home/michael/opt/zookeeper/log  

###6 clientPort：客户端连接端口

客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求。

	clientPort=2333  

###7 服务器名称与地址：集群信息（服务器编号，服务器地址，LF通信端口，选举端口）

这个配置项的书写格式比较特殊，规则如下：

	server.N=YYY:A:B  

其中N表示服务器编号，YYY表示服务器的IP地址，A为LF通信端口，表示该服务器与集群中的leader交换的信息的端口。B为选举端口，表示选举新leader时服务器间相互通信的端口（当leader挂掉时，其余服务器会相互通信，选择出新的leader）。一般来说，集群中每个服务器的A端口都是一样，每个服务器的B端口也是一样。但是当所采用的为伪集群时，IP地址都一样，只能时A端口和B端口不一样。

下面是一个集群的例子：

	server.0=1.2.3.4:2000:6000  
	server.1=1.2.3.5:2000:6000  
	server.2=1.2.3.6:2000:6000  
	server.3=1.2.3.7:2000:6000  

下面是一个伪集群的例子：

	server.0=127.0.0.1:2000:6000  
	server.1=127.0.0.1:2001:6001  
	server.2=127.0.0.1:2002:6002  
	server.3=127.0.0.1:2003:6003  
