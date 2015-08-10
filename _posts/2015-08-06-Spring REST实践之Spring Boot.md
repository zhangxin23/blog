---
layout: post
title: "Spring REST实践之Spring Boot"
description: "Spring REST实践之Spring Boot"
category: Web
tags: [web, Spring, REST]
---

##Spring Boot基本描述
可以利用http://start.spring.io网站的进行Spring Boot的初始化构建。这个初始化构建器允许你输入工程基本信息、挑选工程支持的功能，最后会生成一个zip压缩包供你下载。利用http://start.spring.io网站生成的工程模板中，在pom.xml文件中的parent tag表明此工程继承自spring-boot-starter-parent POM，这样能够保证工程继承Spring Boot的默认依赖以及版本。此POM文件中有两个依赖：spring-boot-starter-web和spring-boot-starter-test。Spring使用starter POM描述这样的POM文件。这些starter POM可引入其它的依赖。例如，spring-boot-starter-web可引入Spring MVC依赖、嵌入式Tomcat容器依赖、Jackson处理依赖。这些starter模块在提供必要依赖和简化应用的POM文件方面起到了重要作用。

##Spring starter模块

spring-boot-starter：引入核心依赖，比如auto-configuration支持和日志。
spring-boot-starter-aop：引入AOP和Aspectj
spring-boot-starter-test：引入JUnit、Mockito、spring-test等测试依赖
spring-boot-starter-web：引入MVC依赖和嵌入式servlet容器。
spring-boot-starter-jpa：通过引入spring-data-jpa、spring-orm和Hibernate依赖，提供Java Persistence API支持。
spring-boot-starter-data-rest：通过引入spring-data-rest-webmvc以REST API形式公布资源仓库。
spring-boot-starter-hateoas：通过引入spring-hateoas依赖支持HATEOAS REST服务。
spring-boot-starter-jdbc：支持JDBC。
spring-boot-maven-plugin：支持将应用程序打包成JAR/WAR可执行格式，并且运行。

##@SpringBootApplication作用
@SpringBootApplication注解是一个简写注解，等同于如下三个注解：

	@Configuration：标注一个类包含一个或者多个spring bean声明。Spring框架会处理这些类，并自动创建bean实例。
	@ComponentScan：此注解告诉Spring扫描，寻找被@Configuration、@Service、@Repository等注解标注的类。默认情况下，Spring会扫描被@ComponentScan标注的类所在包中的所有类。
	@EnableAutoConfiguration：开启auto-configuration功能，Spring Boot会根据类路径发现的依赖和配置关系，猜测、生成bean配置。

main方法中的run方法会指引Spring从工程中读取注解元信息，并以此为基础生成ApplicationContext。

##spring boot运行方式

mvn spring-boot:run

##CLI

Spring Boot提供了CLI（command line interface）生成工程模板，但是需要安装CLI。

##REST工具

Postman

RESTClient

##为资源分配URI的最佳实践

	1. 为REST服务选用一个base URI
	2. 用复数形式命名资源
	3. 用URI层次表明资源的相互关系
	4. 当遇到没有资源实体可以表示某个实体（比如统计投票结果）时，可使用查询参数。


##@ResponseEntity

@RestController同@Controll和ResponseBody两个注解功能一样。@ResponseEntity可以控制HTTP响应，包括response body和response heasers。

##@RequestBody

@RequestBody注解告诉Spring根据Content-Type将request body转换为需要类型的对象。

##URI生成器

可通过如下方式生成URI：

	URI newPollUri = ServletUriComponentsBuilder
	.fromCurrentRequest()
	.path("/{id}")
	.buildAndExpand(poll.getId())
	.toUri();

fromCurrentRequest方法通过从HttpServletRequest复制host、schema、port等信息形成builder。buildAndExpand方法能构建UriComponent实例，并替换URI路径中的占位符。最后调用toUri方法最终形成URI。
