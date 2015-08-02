---
layout: post
title: "Spring REST实践之REST基本介绍"
description: "Spring REST实践之REST基本介绍"
category: Web
tags: [web, Spring, REST]
---

##REST是什么

REST（REpresentational State Transfer）是一个设计分布式web应用的框架风格，有六个基本原则：

	Client-Server：应用的参独立与者可分为Client和Server，Client和Server可以独立发展和扩展。

	Stateless：Client和Server之间的交互应该是stateless，server不应该记录client的状态，clent必须在请求中包含server可以理解的全部的必须的信息。

	Layered System：Client和Server之间可存在多个分层，例如网关、防火墙、代理等，为了提高扩展性可以透明的增加、更改、删除以及重新安排各个层之间的顺序。

	Cache：Server的响应应该声明是否可以缓存，Client可以缓存能够缓存的响应，以备将来的请求用，这可以减少Server的负载，并提高其性能。

	Uniform Interface：统一接口是Client-Server、内部模块之间交互的基础，系统模块只要遵循接口定义就可以独自更新，而不影响其他模块。统一接口可以分为四个约束：资源标识、资源表现、自描述信息、HATEOAS。

	Code on demand：Client可以通过下载代码扩展其功能，比如javasprit脚本、Silverlight等，这是一个可选约束。

应用程序如果能够遵守上面六个约束，那么它就是Restfulf，但是这六个约束并不是开发技术，而只是一种能够使应用程序更加可扩展、可适配、可重用的指导和最佳实践。理论上，RESTful应用程序可以使用任何协议作为传输协议，但是在实践中一般使用HTTP作为传输协议。

Uniform Interface约束是REST应用的关键属性，可通过资源、资源表示、URIs、HTTP method等抽象技术实现。

##资源

资源是REST应用的基础，可以是任何可被访问和管理的事物，比如视频、博客文章、用户配置文件、图片等。

###标识资源

我们必须能够唯一标识一个资源，才能与它进行交互。Web提供了URI来唯一标识资源，它的语法是：
	
	scheme:scheme-specific-part

scheme可以时http、ftp或者mailto等协议，它决定了URI其余部分的语义。一个URI可以唯一标识一个资源，但是一个资源可以有多个URI进行标识。

###URI模板

在实际开发过程中，我们更多时候使用URI的结构而非URI本身，比如：

	http://blog.example.com/{year}/posts

year部分是一个路径变量，此URI代表year路径变量指定的posts，而year能够轻松被server解析。

##资源表现方式

资源在REST应用中是一个抽象的实体，应能够序列化为一种表现形式，以便和客户端进行交流，这种表现形式可以看做资源实体的一个快照。Client和Server通过资源实体的表现形式交互，而非真正的资源实体。

资源实体的表现形式可以为text-based HTML、XML、JSON formats、binary formats（比如PDFs、
JPEGs、MP4s）等格式。Client和Server之间选定资源表现形式的过程称为内容协商，一般内容协商可通过两种方式：扩展名和Accept Header。

##HTTP方法

可通过HTTP提供的方法对资源进行创建、更新、删除、查询等操作。

###安全性

安全性指不会使资源状态发生改变。

###幂等性

幂等性指一个操作进行多次，资源返回相同的状态。

###GET

GET方法用于资源查询，返回HTTP head和body，head记录了资源的一些元信息，比如是否可以缓存、Content Type等，body中记录了资源某个时间的状态的表现形式，它是安全和幂等的。

###HEAD

当用户只关心资源是否存在或者是否有新版本，不关心资源的实体内容时，可使用HEAD方法进行查询，它只返回HTTP头，相比GET方法更加轻量。同GET方法一样，HEAD方法是安全和幂等的。

###DELETE

DELETE方法用于删除资源，由于删除操作可能比较费时，Server收到DELETE请求后，会首先返回一个确认消息，删除操作可能过段时间才执行，当然了Server可根据具体业务逻辑决定是真正删除资源还是标记一个标签。DELETE方法时非安全和幂等的。

###PUT

PUT方法用于修改资源状态，需要Client发送包含资源全部信息的请求到Server，它是非安全和幂等的。

###POST

POST方法用于创建资源，一般POST方法表示在某种资源集合中创建一个资源，所以URI中资源一般用复数表示。Server会在响应头中用Location表示新创建的资源的URI。它是非安全和非幂等的。

###PATCH

PATCH方法也用于资源的修改，不同于PUT方法的是：它允许只修改资源的部分属性。请求body中要修改的部分信息可以采用以下几种方式：

	{"replace": "title","value": "New Awesome title"}

	{"change" : "name", "from" : "Post Title", "to" : "New Awesome Title"}

	{"name" : "New Awesome Title"}

它是非安全和幂等的。

##HTTP状态值

HTTP状态值是Server告诉Client操作的执行结果。一般100系列的状态值表示Server已经接到请求但是还未执行完毕；200系列的状态值表示请求已被成功执行；300系列状态值表示请求已被执行，但是Client还需另外的操作完成请求；400系列状态值表示请求有格式、语法等错误；500系列状态值表示Server在执行请求过程发生错误。

	100 (Continue)：Indicates that the server has received the first part of the request and the rest
	of the request should be sent.
	
	200 (OK)：Indicates that all went well with the request.
	
	201 (Created)：Indicates that request was completed and a new resource got created.
	
	202 (Accepted)：Indicates that request has been accepted but is still being processed.
	
	204 (No Content)：Indicates that the server has completed the request and has no entity body to send to the client.
	
	301 (Moved Permanently)：Indicates that the requested resource has been moved to a new location and a new URI needs to be used to access the resource.
	
	400 (Bad Request)：Indicates that the request is malformed and the server is not able to
	understand the request.
	
	401 (Unauthorized)：Indicates that the client needs to authenticate before accessing the resource. If the request already contains client’s credentials, then a 401 indicates invalid credentials (e.g., bad password).
	
	403 (Forbidden)：Indicates that the server understood the request but is refusing to fulfill it. This could be because the resource is being accessed from a blacklisted IP address or outside the approved time window.
	
	404 (Not Found)：Indicates that the resource at the requested URI doesn’t exist.
	
	406 (Not Acceptable)：Indicates that the server is capable of processing the request; however, the generated response may not be acceptable to the client. This happens when the client becomes too picky with its accept headers.
	
	500 (Internal Server Error)：Indicates that there was an error on the server while processing the request and that the request can’t be completed.
	
	503 (Service Unavailable)：Indicates that the request can’t be completed, as the server is overloaded or going through scheduled maintenance.

##RMM模型

RMM（The Richardson’s Maturity Model）表示了REST服务的四种级别：

###Level 0

HTTP协议作为传输协议，通过唯一一个URI执行远程调用，使用GET或者POST方法，SOAP-RPC和XML-RPC都属于此类。

###Level 1

Level 1比Level 0更加符合REST的要求，每个资源会有多个URI，但是会通过HTTP的一个方法（比如POST）执行所有的请求。


###Level 2

能够正确使用HTTP的方法和返回值。

###Level 3

Level 3符合HATEOAS的概念，即在响应中包含相关资源的链接，可知道Client下一步该如何操作。

##构建REST API

构建REST API分为如下四步：

	Identify Resources：确定应用程序中的资源实体。

	Identify Endpoints：为每个资源设计一个URI。

	Identify Actions：为每个资源确定HTTP方法。

	Identify Responses：为每个请求确定合适的返回值。