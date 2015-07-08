---
layout: post
title: "Restful API设计要点"
description: "Restful API设计要点"
category: Web
tags: [web, restful,]
---

1 Restful API时面向资源，不能面向动作；
2 充分利用http协议的GET, HEAD, OPTION, PUT, POST, DELETE几种方法；
3 GET方法用于获取资源，是幂等和安全的；
4 HEAD方法用于获取头信息，是幂等和安全的
5 OPTION方法用于获取服务器支持的方法，是幂等和安全的；
6 PUT方法用于修改资源，幂等但不安全；
7 POST方法用于增加资源，既不幂等也不安全；
8 DELETE方法用于删除资源，幂等但不安全；