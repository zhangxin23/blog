---
layout: post
title: "Spring REST实践之Versioning，Paging和Sorting"
description: "Spring REST实践之Versioning，Paging和Sorting"
category: Web
tags: [web, Spring, REST]
---

##Versioning

为适应需求的变化以及兼容已有的API，需要创建新版本的API，一般有四种流行的版本化API的方法：

	URI版本化
	URI参数版本化
	Accept header版本化
	自定义header版本化

###URI版本化

在这种方法中，版本信息变成了URI一部分。例如：

	LinkedIn: https://api.linkedin.com/v1/people/~
	Yahoo: https://social.yahooapis.com/v1/user/12345/profile
	SalesForce: http://na1.salesforce.com/services/data/v26.0
	Twitter: https://api.twitter.com/1.1/statuses/user_timeline.json
	Twilio: https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Calls

URI版本化的方式，可以在URI中就可以展示版本信息，方便API的开发和测试，能够通过浏览器访问不同版本的API服务。但是，也会给client生命周期带来复杂性，比如，client保存了存在数据库中的用户资源的引用，为了切换到新版本的API，client必须对资源引用执行复杂的升级操作。

###URI参数版本化

版本作为URI的参数，例如：http://api.example.org/users?v=2，用参数v表示版本二的API。此方式具有与URI版本化一样的优点和缺点。

###Accept header版本化

此方式通过Accept header交互版本信息，因为header中包含了版本信息，所以多个版本的API可以使用同一个URI。为了传递版本信息，需要自定义资源类型，一般自定义的格式为：vnd.product_name.version+ suffix，vnd是自定义资源类型的起始点；product_name是资源的名称，用于区分其他资源类型；version是版本信息；suffix表示资源类型。例如application/vnd.quickpoll.v2+json。

因为不用更改整个API就可以访问资源，Accept header版本化方式变得越来越流行，但是这种方式使通过浏览器测试变得困难。

###自定义header版本化

自定义header版本化，和Accept header方式一样，除了自定义header，而不是使用Accept header。因为HTTP规范提供了通过accept header的标准方式，所以此种方式没有被广泛的采用。

###过期API的处理方式

当有新版本API发布时，会有一些API过期，但是不应该立即过期，应该再维护一段时间，在这段时间里提醒用户应该迁移到新版本的API。

##Paging

REST api的消费者包括桌面应用、web应用、移动应用。出于对带宽和性能的考虑，都不应该直接返回一个大数据集，应该采用分页。有四种分页的方式：page number分页、limit offset分页、cursor-based分页、time-based分页。

###page number分页

在这种风格中，用户指定他们需要的数据的页码。例如：

	http://blog.example.com/posts?page=3
	http://blog.example.com/posts?page=3&size=20
	https://api.github.com/user/repos?page=2&per_page=100

server针对分页返回的响应可以像下面这样：

	{
	 	"data": [
	 		... Blog Data
	 	],
	 	"totalPages": 9,
	 	"currentPageNumber": 2,
	 	"pageSize": 10,
	 	"totalRecords": 90
	}

###limit offset分页

在这种风格中，用户指定limit和offset两个参数，限定他们需要的数据。例如：
	
	http://blog.example.com/posts?limit=10&offset=30

###cursor-based分页

在这种风格中，用户利用指针或者游标导航要访问的数据集。例如：用户发送一个http://blog.example.com/posts请求，server端返回：
	
	{
 		"data" : [
 			... Blog data
 		],
		"cursors" : {
 			"prev" : null,
 			"next" : "123asdf456iamcur"
 		}
	}

用户再访问时，可使用如下URI：http://api.example.com/posts?cursor=123asdf456iamcur

###time-based分页

在这种风格中，用户指定一个时间片用于检索数据。例如：

	https://graph.facebook.com/me/feed?limit=25&until=1364587774
	https://graph.facebook.com/me/feed?limit=25&since=1364849754

##Sorting

Sorting让用户能够决定依据那列队数据集进行排序。一般的排序形式如下所示：

	http://blog.example.com/posts?sortByDesc=createdDate&sortByAsc=title
	http://blog.example.com/posts?sort=createdDate,desc&sort=title,asc
	http://blog.example.com/posts?sort=-createdDate,title
