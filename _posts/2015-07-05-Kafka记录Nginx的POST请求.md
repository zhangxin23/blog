---
layout: post
title: "Kafka记录Nginx的POST请求"
description: "Kafka记录Nginx的POST请求"
category: Nginx
tags: [Nginx, Kafka, Web, POST]
---

##Kafka记录Nginx的POST请求

最近因为工作原因，需要将Nignx的POST请求数据实时采集到Kafka中。最容易的想到的方案就是通过"tail -f" Nginx的log日志到Kafka的Broker集群中，但是这种方案效率、吞吐量都很低，完全无法满足业务上的需要。所以如果能直接在Nginx中获取到POST请求数据，并调用Kafka的API接口将数据直接写入到Kafka集群中，是最完美的解决方法了。但是此种方案存在一个难点啊，就是要写一个Nginx模块，由于刚开始接触Nginx，这块不是很熟。只能借助万能Google了，输入关键字“Nginx Kafka”，没想到还真找到一个开源的Nginx模块（ngx_kafka_module），心中万分高兴，本来以为拿来就能用呢，通读代码才发现，它只能将POST请求发给一个Broker，不能借助Zookeeper的集群管理功能，让zookeeper自动帮助选一个Broker。没有办法了，只能自己动手修改一下了。首先从了解编写Nginx模块的步骤入手，找到淘宝开源的"Nginx开发从入门到精通"电子书，这里要赞一下，果然是对Nginx有深入了解，要不也不能写出这么深入浅出的书。在了解了编写步骤后，开始在ngx_kafka_module着手进行改造，在ngx_kafka_module里增加了一个“kafka.broker.list”的main配置项和一个全局变量（g_broker_list）用于记录nginx.conf配置文件中kafka.broker.list的值，并在该模块初始化时，用此全局变量设置kafka_conf的“metadata.broker.list”属性，然后用此kafka_conf初始化一个生产者。这样当每来一个POST请求时，就是可通过此生产者将POST消息发送到相应的topic。

由于申请的机器，还未到手，手头没有具体的性能数据，以后补上。