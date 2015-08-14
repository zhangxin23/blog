---
layout: post
title: "Spring REST实践之Versioning，Paging和Sorting"
description: "Spring REST实践之Versioning，Paging和Sorting"
category: Web
tags: [web, Spring, REST, Swagger]
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



###URI参数版本化

###Accept header版本化

###自定义header版本化


##Paging

##Sorting