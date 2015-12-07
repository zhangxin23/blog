---
layout: post
title: "Spring @RequestHeader用法"
description: "Spring @RequestHeader用法"
category: spring
tags: [spring]
---

Spring MVC提供了@RequestHeader注解，能够将请求头中的变量值映射到控制器的参数中。下面是一个简单的例子：

	import org.springframework.stereotype.Controller;
	import org.springframework.web.bind.annotation.RequestHeader;
	import org.springframework.web.bind.annotation.RequestMapping;
	//..
	 
	@Controller
	public class HelloController {
	 
		@RequestMapping(value = "/hello.htm")
		public String hello(@RequestHeader(value="User-Agent") String userAgent)

		    //..
		}
	}

在上面的代码片段中，定义了一个映射到/hello.htm的hello控制器方法。同时用@RequestHeader注解将请求头中”User-Agent“的变量与”userAgent“变量绑定。当此某个请求映射到了此控制器方法，Spring会检查请求头中的”User-Agent“变量，并将其与”userAgent“变量绑定。

如果@RequestHeader绑定的变量，在请求头中不存在，Spring会将控制器中的参数初始化为null。如果想给控制器参数提供一个默认值，在@RequestHeader的defaultParameter属性。

	@RequestMapping(value = "/hello.htm")
	public String hello(@RequestHeader(value="User-Agent", defaultValue="foo") String userAgent)
	 
		//..
	}
