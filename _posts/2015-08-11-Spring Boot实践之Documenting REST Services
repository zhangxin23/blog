---
layout: post
title: "Spring REST实践之Documenting REST Services"
description: "Spring REST实践之Documenting REST Services"
category: Web
tags: [web, Spring, REST, Swagger]
---

##Swagger基本介绍

Swagger是创建交互式REST API文档的规范和框架，它能自动同步REST服务的任何变化，同时为生成API客户端代码提供了一套工具和SDK生成器。Swagger规范由两种文件类型组成：资源文件（包含一系列文件）和一套API声明文件（描述了REST API和可用的操作）。资源文件是API声明文件的根，它描述了一般信息，比如API版本、title、描述、license，同时它也包含了所有可用的API资源。API声明文件描述了带有API操作和请求/响应展现的资源，basePath域提供了API的根URI，resourcePath指定了相对于basePath的资源路径，apis域包含了描述API操作的接口对象，models域包含了和资源相关的模型对象。

Swagger使用JSON作为描述语言。

##集成Swagger

在POM文件中加入如下依赖：

	<dependency>
		<groupId>com.mangofactory</groupId>
		<artifactId>swagger-springmvc</artifactId>
		<version>1.0.2</version>
	</dependency>

然后通过@EnableSwagger注解激活swagger-springmvc。

##Swagger UI

Swagger UI是Swagger的一个子项目，能够利用资源文件和API描述文件为API自动生成友好的、可交互的接口。

在应用中集成Swagger UI的方法是：首先从https://github.com/swagger-api/swagger-ui下载Swagger UI的稳定版本，然后dist文件夹下的内容移动到应用的类路径下（一般放到resoures目录下）。更改index.html文件中的如下内容

	$(function () {
		window.swaggerUi = new SwaggerUi({
		url: "http://localhost:8080/api-docs",
		dom_id: "swagger-ui-container",
		// code removed for brevity
	}

最后通过http://localhost:8080/swagger-ui/index.html启动Swagger UI。


##定制Swagger

可通过在应用中建立一个配置类实现对Swagger的定制。

	import javax.inject.Inject;

	import org.springframework.context.annotation.Bean;
	import org.springframework.context.annotation.Configuration;

	import com.mangofactory.swagger.configuration.SpringSwaggerConfig;
	import com.mangofactory.swagger.models.dto.ApiInfo;
	import com.mangofactory.swagger.models.dto.builder.ApiInfoBuilder;
	import com.mangofactory.swagger.plugin.EnableSwagger;
	import com.mangofactory.swagger.plugin.SwaggerSpringMvcPlugin;

	@Configuration
	@EnableSwagger
	public class SwaggerConfig {

		@Inject
		private SpringSwaggerConfig springSwaggerConfig;
		
		private ApiInfo getApiInfo() {
			
			ApiInfo apiInfo = new ApiInfoBuilder()
					        .title("QuickPoll REST API")
					        .description("QuickPoll Api for creating and managing polls")
					        .termsOfServiceUrl("http://example.com/terms-of-service")
					        .contact("info@example.com")
					        .license("MIT License")
					        .licenseUrl("http://opensource.org/licenses/MIT")
					        .build();
				
			return apiInfo;
		}
		
		@Bean
		public SwaggerSpringMvcPlugin v1APIConfiguration() {
			SwaggerSpringMvcPlugin swaggerSpringMvcPlugin = new SwaggerSpringMvcPlugin(this.springSwaggerConfig);		
			swaggerSpringMvcPlugin
						.apiInfo(getApiInfo()).apiVersion("1.0")
						.includePatterns("/v1/*.*").swaggerGroup("v1");		
			swaggerSpringMvcPlugin.useDefaultResponseMessages(false);		
		    	return swaggerSpringMvcPlugin;
		}
	}

##配置控制器

@API注解标注一个类为Swagger资源，Swagger会扫描标注了@API的类，读取metadata生成资源文件和API描述文件。

	@RestController
	@Api(value = "polls", description = "Poll API")
	public class PollController {
		// Implementation removed for brevity
	}

@ApiOperation注解用于标注API，可以自定义操作信息，比如名字、描述、响应。

	@RequestMapping(value="/polls", method=RequestMethod.POST)
	@ApiOperation(value = "API概要描述", notes="详细描述信息", response = Void.class)
	public ResponseEntity<Void> createPoll(@Valid @RequestBody Poll poll) {
		.......
	}

@ApiResponse注解用于配置状态码和相关响应body。

	RequestMapping(value="/polls", method=RequestMethod.POST)
	@ApiOperation(value = "API概要描述", notes="详细描述信息", response = Void.class)
	@ApiResponses(value = {@ApiResponse(code=201, message="Poll Created Successfully", response=Void.class),
				@ApiResponse(code=500, message="Error creating Poll", response=ErrorDetail.class) } )
	public ResponseEntity<Void> createPoll(@Valid @RequestBody Poll poll) {
		// Content removed for brevity
	}

##配置UI

更改swagger-ui-wrap内容，将相关信息更改为应用相关的信息，如下所示：

	<a id="logo" href="http://localhost:8080">QuickPoll</a>
	<form id='api_selector'>
		<div class='input'><input placeholder="http://example.com/api" id="input_baseUrl" name="baseUrl" type="text"/></div>
		<div class='input'><input placeholder="api_key" id="input_apiKey" name="apiKey" type="text"/></div>
		<div class='input'><a id="explore" href="#">Explore</a></div>
	</form>
