---
layout: post
title: "Spring MVC静态资源处理"
description: "Spring MVC静态资源处理"
category: Spring MVC
tags: [Spring MVC]
---

优雅REST风格的资源URL不希望带 .html 或 .do 等后缀.由于早期的Spring MVC不能很好地处理静态资源，所以在web.xml中配置DispatcherServlet的请求映射，往往使用 *.do 、 *.xhtml等方式。这就决定了请求URL必须是一个带后缀的URL，而无法采用真正的REST风格的URL。

如果将DispatcherServlet请求映射配置为"/"，则Spring MVC将捕获Web容器所有的请求，包括静态资源的请求，Spring MVC会将它们当成一个普通请求处理，因此找不到对应处理器将导致错误。

如何让Spring框架能够捕获所有URL的请求，同时又将静态资源的请求转由Web容器处理，是可将DispatcherServlet的请求映射配置为"/"的前提。由于REST是Spring3.0最重要的功能之一，所以Spring团队很看重静态资源处理这项任务，给出了堪称经典的两种解决方案。

先调整web.xml中的DispatcherServlet的配置，使其可以捕获所有的请求：

	<servlet>
	    <servlet-name>springMVC</servlet-name>
	    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
	    <load-on-startup>1</load-on-startup>
	</servlet>
	<servlet-mapping>
	    <servlet-name>springMVC</servlet-name>
	    <url-pattern>/</url-pattern>
	</servlet-mapping>

通过上面url-pattern的配置，所有URL请求都将被Spring MVC的DispatcherServlet截获。

###采用<mvc:default-servlet-handler />

在springMVC-servlet.xml中配置<mvc:default-servlet-handler />后，会在Spring MVC上下文中定义一个org.springframework.web.servlet.resource.DefaultServletHttpRequestHandler，它会像一个检查员，对进入DispatcherServlet的URL进行筛查，如果发现是静态资源的请求，就将该请求转由Web应用服务器默认的Servlet处理，如果不是静态资源的请求，才由DispatcherServlet继续处理。

一般Web应用服务器默认的Servlet名称是"default"，因此DefaultServletHttpRequestHandler可以找到它。如果你所有的Web应用服务器的默认Servlet名称不是"default"，则需要通过default-servlet-name属性显示指定：

	<mvc:default-servlet-handler default-servlet-name="所使用的Web服务器默认使用的Servlet名称" />

###采用<mvc:resources />

<mvc:default-servlet-handler />将静态资源的处理经由Spring MVC框架交回Web应用服务器处理。而<mvc:resources />更进一步，由Spring MVC框架自己处理静态资源，并添加一些有用的附加值功能。

首先，<mvc:resources />允许静态资源放在任何地方，如WEB-INF目录下、类路径下等，你甚至可以将JavaScript等静态文件打到JAR包中。通过location属性指定静态资源的位置，由于location属性是Resources类型，因此可以使用诸如"classpath:"等的资源前缀指定资源位置。传统Web容器的静态资源只能放在Web容器的根路径下，<mvc:resources />完全打破了这个限制。

其次，<mvc:resources />依据当前著名的Page Speed、YSlow等浏览器优化原则对静态资源提供优化。你可以通过cacheSeconds属性指定静态资源在浏览器端的缓存时间，一般可将该时间设置为一年，以充分利用浏览器端的缓存。在输出静态资源时，会根据配置设置好响应报文头的Expires 和 Cache-Control值。

在接收到静态资源的获取请求时，会检查请求头的Last-Modified值，如果静态资源没有发生变化，则直接返回304相应状态码，提示客户端使用浏览器缓存的数据，而非将静态资源的内容输出到客户端，以充分节省带宽，提高程序性能。

在springMVC-servlet中添加如下配置：

	<mvc:resources location="/,classpath:/META-INF/publicResources/" mapping="/resources/**"/>

以上配置将Web根路径"/"及类路径下"/META-INF/publicResources/"的目录映射为"/resources"路径。假设Web根路径下拥有images、js这两个资源目录，在images下面有bg.gif图片，在js下面有test.js文件，则可以通过"/resources/images/bg.gif"和"/resources/js/test.js"访问这二个静态资源。假设Web根路径还拥有"images/bg1.gif"及"js/test1.js"，则也可以在网页中通过"/resources/images/bg1.gif"及"/resources/js/test1.js"进行引用。
