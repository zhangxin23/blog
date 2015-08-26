---
layout: post
title: "Spring REST实践之Error Handling"
description: "Spring REST实践之Error Handling"
category: Web
tags: [web, Spring, REST]
---

##Error Responses

在REST API中，HTTP状态码有非常重要的作用。API开发者应该坚持为每一个请求返回一个正确合适的状态码，而且应该在响应body中包含有用的、细粒度的错误信息。这些细节都可以帮助API使用者更快的定位错误。一般在错误响应体中应该包含如下信息（当然可以根据具体情况定义）：

	timestamp：错误发生的时间（时间戳）
	status：错误相对应的http状态码
	error：http状态码相关的描述
	exception：引起错误的类的详细路径信息
	message：错误相关的更加详细的信息
	path：引起异常的URI

##Input Field Validation

每一个应用程序都应该关注输入域的合法性判断。Spring MVC提供了两种方式验证用户输入，第一种方式是实现org.springframework.validation.Validator接口，将validator注入到controller中，手动调用验证方法执行验证过程；第二种方式是应用JSR 303验证方式（能够在应用程序的任何层执行验证逻辑），JSR 303和JSP 349定义了Bean验证API的规范。利用这些API，用户直接标注相关属性即可，比如@NotNull和@Email标注，相关实现框架会在运行时执行相关限制。Hibernate Validator是JSR 303/349非常流行的实现框架。下面是一些相关验证注解：

	NotNull：声明某个域不能为null
	Null：声明某个域必须为null
	Max：声明某个域必须为整数，而且要小于等于指定的值
	Min：声明某个域必须为整数，而且要大于等于指定的值
	Past：声明某个域必须为过去的日期
	Future：声明某个域必须为未来的日期
	Size：声明某个域必须在min和max指定的范围内，如果域是集合类型，那么限制集合的元素个数；如果域是String类型，那么限制字符串的长度
	Pattern：声明某个域必须符合指定的正则表达式

##Externalizing Error Messages

为了适应国际化/本地化要求，最好能够将错误信息存在外部文件中。要实现此目的，可在classpath下定义多个messages相关的属性文件，用MessageSource的实现类ResourceBundleMessageSource（需要配置它的basename属性为多个属性文件的路径和前缀）读取属性中相关信息，可以通过getMessage方法的第三个参数Locale选取不同语言的错误信息。

##Improving RestExceptionHandler

如果要想自定义标准异常的输出，一个简单的方法是扩展Spring的
ResponseEntityExceptionHandler类（此类中包含了标准异常的处理器），并覆盖相应方法即可。