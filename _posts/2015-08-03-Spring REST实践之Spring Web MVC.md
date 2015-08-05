---
layout: post
title: "Spring REST实践之Spring Web MVC"
description: "Spring REST实践之Spring Web MVC"
category: Web
tags: [web, Spring, REST]
---

##Spring概要

Spring Framework提供了依赖注入模型和面向切面编程，简化了基础型代码的编写工作以及更好的能够与其它框架和技术整合起来。Spring Framework由data access、instrumentation、messaging、testing、Web
integration等模块组成。开发者可以只关心自己应用程序相关模块。

###依赖注入

依赖注入是Spring Framework的核心，能够降低模块之间的耦合度。为了能够更好的理解依赖注入的概念，举个例子解释一下：考虑网上购物的场景，完成一个订单服务需要与订单仓库组件和用户通知组件交互。在传统的实现方式中，订单服务可以创建订单仓库组件和用户通知组件对象，虽然这么做没有什么错，但是它会导致难于维护、难于测试和高耦合性。利用依赖注入，开发者可以委托Spring Framework管理模块间的依赖关系，所以在上面的场景中，Spring Framework可以创建订单仓库组件和用户通知组件，并注入到订单服务中。这样订单服务就不用创建管理订单仓库组件和用户通知组件，非常方便测试、维护，以及替换订单仓库组件和用户通知组件的实现方式。

###AOP

AOP实现了横切逻辑，像日志、事务、监控、安全都属于横切逻辑。AOP提供了切面在一个集中的地方来完成这些横切逻辑，而不是将这些横切逻辑遍布业务代码各处。Spring Framework采用代理的方式实现AOP，当目标bean被调用时，代理会中断调用并执行横切逻辑，最后才执行目标bean的方法。Spring提供了JDK动态代理和CGLIB代理方式，如果目标对象实现了接口，Spring会使用JDK动态代理创建AOP代理，反之会使用CGLIB代理实现。

##Spring Web MVC概要

Spring Web MVC是基于MVC的架构，提供了丰富的注解和组件。经过近几年的发展，Spring Web MVC支持了试图解析和丰富的数据绑定功能。

###Model View Controller Pattern

![Model View Controller交互图](/images/MVC interaction.png)

###Spring Web MVC Architecture

![Spring Web MVC's architecture](/images/Spring Web MVC's architecture.png)

###Spring Web MVC Components

####Controller

控制器可用@Controller注解声明。

###Model

Model用于保持模型的属性，可用addAttribute和addAttributes方法增加模型的属性。

	public interface Model {
		 
		Model addAttribute(String attributeName, Object attributeValue);
		 
		Model addAttribute(Object attributeValue);
		 
		Model addAllAttributes(Collection<?> attributeValues);
		 
		Model addAllAttributes(Map<String, ?> attributes);

		Model mergeAttributes(Map<String, ?> attributes);
		 
		boolean containsAttribute(String attributeName);
		 
		Map<String, Object> asMap();
	}

###View

Spring Web MVC支持JSP、Velocity、Freemarker和XSLT等视图技术，通过View接口完成这个功能。

View Interface API：
	public interface View
	{
		String getContentType();
		 
		void render(Map<String, ?> model, HttpServletRequest request, HttpServletResponse response) throws Exception;
	}

View Interface的核心功能是负责呈现响应内容，这个功能需要重载render方法实现，getContentType方法返回内容类型。Spring Web MVC内置了MappingJackson2JsonView、XsltView等实现View接口的类。

###@RequestParam

@RequestParam用于绑定请求中的参数到控制器中的参数。

###@RequestMapping

@RequestMapping将一个请求映射到控制器的一个方法。

@RequestMapping的参数：
	Method：Restricts a mapping to a specific HTTP method such as GET, POST, HEAD, OPTIONS, PUT, PATCH, DELETE, TRACE

	Produces：Narrows mapping to media type that is produced by the method
	
	Consumes：Narrows mapping to media type that the method consumes
	
	Headers：Narrows mapping to the headers that should be present name Allows you to assign a name to the mapping
	
	params：Restricts a mapping to the supplied parameter name and value

###Path Variables

@PathVariable能够访问@RequestMapping指定的路径中占位符参数。

###View Resolver

View Resolver能够根据控制器返回的逻辑视图名，选择合适的视图解析器呈现视图。

	public interface ViewResolver
	{
		View resolveViewName(String viewName, Locale locale) throws Exception;
	}

ContentNegotiatingViewResolver、BeanNameViewResolver、InternalResourceViewResolver、TilesViewResolver等实现了ViewResolver接口。

###Exception Handler

	@Controller
	public class HomeController {
		@ExceptionHandler(SQLException.class)
		public Object handleSQLException() {
		
		}
		 
		@RequestMapping("/stream")
		public void streamMovie(HttpServletResponse response) throws SQLException {
		 
		}
	}

@ExceptionHandler注解表示在HomeController控制器中的方法抛出SQLException未处理的异常，都由handleSQLException来进行处理。但是此方式有个缺陷，就是只能处理HomeController及其子类的方法抛出的未处理异常。为解决这个问题，Spring提供了@ControllerAdvice注解，在应用中凡是用@RequestMapping注解标记的方法抛出未处理的异常都可以由@ControllerAdvice注解标注的类中的相应异常处理方法进行处理。

	@ControllerAdvice
	public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {
	 
		@ExceptionHandler(SQLException.class)
		public Object handleSQLException() {

		}
	}

###Interceptors

Interceptors可以执行一些处理器关注的横切点业务。

HandlerInterceptor API
	public interface HandlerInterceptor{
		void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex);

		void postHandle(HttpServletRequest request, HttpServletResponse response, Object
		handler, ModelAndView modelAndView);
		
		boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object
		handler);
	}

HandlerInterceptorAdapter实现HandlerInterceptor接口中的方法的默认实现，自定义的拦截器可以继承HandlerInterceptor类，覆盖自己关注的方法即可。

Spring Web MVC Interceptor例子：

	public class SimpleInterceptor extends HandlerInterceptorAdapter {
		private static final Logger logger = Logger.getLogger(SimpleInterceptor.class);
		 
		public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
			Object handler) throws Exception {
			logger.info("Inside the prehandle");
			 
			return false;
		}
	}

拦截器注册例子：

	@Configuration
	@EnableWebMvc
	@ComponentScan(basePackages = { "com.apress.springrest.web" })
	public class WebConfig extends WebMvcConfigurerAdapter {
	 
		@Override
		public void addInterceptors(InterceptorRegistry registry) {
			registry.addInterceptor(new LocaleChangeInterceptor());
			registry.addInterceptor(new SimpleInterceptor()).addPathPatterns("/auth/**");
		}
	}