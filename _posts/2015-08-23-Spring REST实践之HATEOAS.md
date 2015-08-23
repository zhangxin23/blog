---
layout: post
title: "Spring REST实践之HATEOAS"
description: "Spring REST实践之HATEOAS"
category: Web
tags: [web, Spring, REST, HATEOAS]
---

##HATEOAS

HATEOAS(The Hypermedia As The Engine Of Application Statue)是REST架构的主要约束。“hepermedia”表示任何包含指向图片、电影、文字等资源的链接，Web是超媒体的经典例子。HATEOAS背后的思想其实非常简单，就是响应中包含指向其它资源的链接。客户端可以利用这些链接和服务器交互。

client不用事先知道服务或者工作流中不同步骤，还有client不用再为不同的资源硬编码URI了。而且服务器还可以在不破坏和客户端交互的情况下，更改URI。

非HATEOAS的响应例子是：

	GET /posts/1 HTTP/1.1
	Connection: keep-alive
	Host: blog.example.com
	{
		"id" : 1,
		"body" : "My first blog post",
		"postdate" : "2015-05-30T21:41:12.650Z"
	￼}

而HATEOAS的响应例子则是：

	{
        "id" : 1,
        "body" : "My first blog post",
        "postdate" : "2015-05-30T21:41:12.650Z",
        "links" : [
	        {
			    "rel" : "self",
			    "href" : http://blog.example.com/posts/1,
			    "method" : "GET"
			}
		] 
	}

上面的例子中，每一个在links中的link都包含了三部分：

	href：用户可以用来检索资源或者改变应用状态的URI
	rel：描述href指向的资源和现有资源的关系
	method：和此URI需要的http方法

在rel中“self”表示了自描述的关系。如果一个资源包含其它资源，那么可以按照下面例子组织：

	{
        "id" : 1,
        "body" : "My first blog post",
        "postdate" : "2015-05-30T21:41:12.650Z",
        "self" : "http://blog.example.com/posts/1",
        "author" : "http://blog.example.com/profile/12345",
        "comments" : "http://blog.example.com/posts/1/comments",
        "tags" : "http://blog.example.com/posts/1/tags"
	}

上面的例子和前一个例子有些不同，没有使用links数组。	


##JSON Hypermedia Types

JSON媒体类型没有提供原生的超链接语法，所以为了解决这个问题，有几种JSON超媒体类型被创建出来：

	• HAL—http://stateless.co/hal_specification.html
	• JSON-LD—http://json-ld.org
	• Collection+JSON—http://amundsen.com/media-types/collection/
	• JSON API—http://jsonapi.org/
	• Siren—https://github.com/kevinswiber/siren

HAL是其中最流行的一种，而且被Spring Framework支持。

###HAL

HAL(The Hypertext Application Language)是简单的超媒体类型，由Mike Kelly于2011创建。它同时支持XML和JSON格式。HAL媒体类型定义了一种资源，它是状态的容器、links的集合、嵌套资源的集合。如下图所示：

![HAL resource structure](/images/HAL resource structure.md)

资源状态是用JSON的key/valude形式表达的。如下面所示：

	{
		"id" : 1,
        "body" : "My first blog post",
        "postdate" : "2015-05-30T21:41:12.650Z"
	}

HAL规范中定义，使用_links包含所有的link。如下面例子所示：

	{
        "id" : 1,
        "body" : "My first blog post",
        "postdate" : "2015-05-30T21:41:12.650Z",
        "_links" : {
	        "self": { "href": "http://blog.example.com/posts/1" },
			"comments": { "href": "http://blog.example.com/posts/1/comments",
						  "totalcount" : 20 },
			"tags": { "href": "http://blog.example.com/posts/1/tags" }
		} 
	}

在HAL嵌套资源的情况，如下面例子所示：

	{
        "id" : 1,
        "body" : "My first blog post",
        "postdate" : "2015-05-30T21:41:12.650Z",
        "_links" : {
             "self": { "href": "http://blog.example.com/posts/1" },
             "comments": { "href": "http://blog.example.com/posts/1/comments",
             "totalcount" : 20 },
             "tags": { "href": "http://blog.example.com/posts/1/tags" }
        },
        "_embedded" : {
        	"author" : {
     			"_links" : {
        			"self": { "href": "http://blog.example.com/profile/12345" }
      			},
      			"id" : 12345,
      			"name" : "John Doe",
      			"displayName" : "JDoe"
      		}
		} 
	}

##HATEOAS in Spring

	Spring HATEOAS dependency
	<dependency>
        <groupId>org.springframework.hateoas</groupId>
        <artifactId>spring-hateoas</artifactId>
        <version>0.17.0.RELEASE</version>
	</dependency>

为了简化超链接的嵌入，Spring HATEOAS提供了org. springframework.hateoas.ResourceSupport，一般应由资源类进行扩展。ResourceSupport类为增加/删除链接提供了重载方法，它也包含了getId方法，此方法返回和资源相关的URI。getId的实现依据了REST的一个准则：一个资源的ID就是它的URI。

下面的例子是在Spring中使用HATEOAS的代码：

	import static org.springframework.hateoas.mvc.ControllerLinkBuilder.linkTo;
	import static org.springframework.hateoas.mvc.ControllerLinkBuilder.methodOn;
	@RestController
	public class PollController {
        @RequestMapping(value="/polls", method=RequestMethod.GET)
        public ResponseEntity<Iterable<Poll>> getAllPolls() {
            Iterable<Poll> allPolls = pollRepository.findAll();
            for(Poll p : allPolls) {
                updatePollResourceWithLinks(p);
            	return new ResponseEntity<>(allPolls, HttpStatus.OK);
			}
		}

		@RequestMapping(value="/polls/{pollId}", method=RequestMethod.GET)
        public ResponseEntity<?> getPoll(@PathVariable Long pollId) {
            Poll p = pollRepository.findOne(pollId);
            updatePollResourceWithLinks(p);
            return new ResponseEntity<> (p, HttpStatus.OK);
		}
	        
        private void updatePollResourceWithLinks(Poll poll) {
            poll.add(linkTo(methodOn(PollController.class).getAllPolls()).slash(poll.getPollId()).withSelfRel());
        	poll.add(linkTo(methodOn(VoteController.class).getAllVotes(poll.getPollId())).withRel("votes"));
        	poll.add(linkTo(methodOn(ComputeResultController.class).computeResult(poll.getPollId())).withRel("compute-result"));
		} 
	} 

下图是上面例子的响应：

![response with links](/images/response with links.png)