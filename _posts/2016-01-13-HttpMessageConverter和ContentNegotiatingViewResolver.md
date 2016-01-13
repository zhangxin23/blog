---
layout: post
title: "HttpMessageConverter和ContentNegotiatingViewResolver"
description: "HttpMessageConverter和ContentNegotiatingViewResolver"
category: Spring MVC
tags: [Spring MVC]
---

###HttpMessageConverter

在SpringMVC中，可以使用@RequestBody和@ResponseBody两个注解，分别完成请求报文到对象和对象到响应报文的转换，HttpMessageConverter完成了这种消息转换机制。

HttpMessageConverte接口定义：

	package org.springframework.http.converter;

	import java.io.IOException;
	import java.util.List;

	import org.springframework.http.HttpInputMessage;
	import org.springframework.http.HttpOutputMessage;
	import org.springframework.http.MediaType;

	public interface HttpMessageConverter<T> {

	    boolean canRead(Class<?> clazz, MediaType mediaType);

	    boolean canWrite(Class<?> clazz, MediaType mediaType);

	    List<MediaType> getSupportedMediaTypes();

	    T read(Class<? extends T> clazz, HttpInputMessage inputMessage)
	            throws IOException, HttpMessageNotReadableException;

	    void write(T t, MediaType contentType, HttpOutputMessage outputMessage)
	            throws IOException, HttpMessageNotWritableException;

	}

HttpMessageConverter接口的定义出现了成对的canRead()，read()和canWrite()，write()方法，MediaType是对请求的Media Type属性的封装。举个例子，当我们声明了下面这个处理方法。

	@RequestMapping(value="/string", method=RequestMethod.POST)
	public @ResponseBody String readString(@RequestBody String string) {
	    return "Read string '" + string + "'";
	}

在SpringMVC进入readString方法前，会根据@RequestBody注解选择适当的HttpMessageConverter实现类来将请求参数解析到String变量中，具体来说是使用了StringHttpMessageConverter类，它的canRead()方法返回true，然后它的read()方法会从请求中读出请求参数，绑定到readString()方法的string变量中。

当SpringMVC执行readString方法后，由于返回值标识了@ResponseBody，SpringMVC将使用StringHttpMessageConverter的write()方法，将结果作为String值写入响应报文，当然，此时canWrite()方法返回true。

将上述过程集中描述的一个类是org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor，这个类同时实现了HandlerMethodArgumentResolver和HandlerMethodReturnValueHandler两个接口。前者是将请求报文绑定到处理方法形参的策略接口，后者则是对处理方法返回值进行处理的策略接口。RequestResponseBodyMethodProcessor这个类，同时充当了方法参数解析和返回值处理两种角色。而在此过程中，以是否有@RequestBody和@ResponseBody为条件，然后分别调用HttpMessageConverter来进行消息的读写。

###ContentNegotiatingViewResolver

主要完成同一资源，多种展现的功能。

####三种指定资源格式的方式

#####Http Request Header: Accept

	GET /test/123 HTTP/1.1
	Accept: application/json  //返回json格式数据

	GET /test/123 HTTP/1.1
	Accept: application/xml  //返回xml格式数据

如果你的资源是通过浏览器访问的，那么由于浏览器的差异，传递到服务器的Accept Header是有差异的，将导致服务器不知道返回何种格式的数据给浏览器。下面是各种浏览器的Accept Header：

	chrome:  
	Accept:application/xml,application/xhtml+xml,textml;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5  
	  
	firefox:  
	Accept:text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8  
	  
	IE8:  
	Accept:image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/x-silverlight, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, */*  

#####使用扩展名

	/test/123.xml  //返回xml格式数据
	/test/123.json  //返回json格式数据

丧失了同一url多种展现的方式，但现在这种在实际环境中是使用最多的，因为更加符合程序员的审美观。

#####使用参数

	/test/123?format=json  //返回json格式数据
	/test/123?format=xml  //返回xml格式数据

现在很多open API是使用这种方式，但可能由于要编写的字符较多，所以较少使用。

####ContentNegotiatingViewResolver配置

内容协商(content negotiation)的工作是由ContentNegotiatingViewResolver来完成的。它的工作模式支持我上面讲的三种，ContentNegotiatingViewResolver是根据客户提交的MimeType(如 text/html,application/xml)来跟服务端的一组viewResover的MimeType相比较，如果符合，即返回viewResover的数据。

ContentNegotiatingViewResolver配置：

	<bean id="contentNegotiationManager"
	      class="org.springframework.web.accept.ContentNegotiationManagerFactoryBean">
	    <property name="favorPathExtension" value="true" />
	    <property name="favorParameter" value="true" />
	    <property name="parameterName" value="format" />
	    <property name="ignoreAcceptHeader" value="false" />
	    <property name="mediaTypes">
	        <value>
	            json=application/json
	            xml=application/xml
	        </value>
	    </property>
	    <property name="defaultContentType" value="text/html" />
	</bean>

	<bean class="org.springframework.web.servlet.view.ContentNegotiatingViewResolver">
	    <property name="contentNegotiationManager" ref="contentNegotiationManager"/>
	    <property name="viewResolvers">
	        <list>
	            <bean class="org.springframework.web.servlet.view.BeanNameViewResolver"/>
	            <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
	                <property name="prefix" value="/WEB-INF/jsp/"/>
	                <property name="suffix" value=".jsp"/>
	            </bean>
	        </list>
	    </property>
	    <property name="defaultViews">
	        <list>
	            <bean class="org.springframework.web.servlet.view.json.MappingJackson2JsonView" />
	        </list>
	    </property>
	</bean>