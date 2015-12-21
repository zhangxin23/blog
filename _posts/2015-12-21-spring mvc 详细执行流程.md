---
layout:post
title: "spring mvc 详细执行流程"
description: "spring mvc 详细执行流程"
category: spring mvc
tags:[spring mvc]
---

###名词解释 

	DispatcherServlet：整个spring MVC的前端控制器，由它来接管来自客户端的请求。
	HandlerMapping：DispatcherServlet会通过它来处理客户端请求到各个(Controller)处理器的映射。
	HandlerAdapter：HandlerMapping会根据它来调用Controller里需要被执行的方法。
	HandlerExceptionResolver：spring mvc处理流程中，如果有异常抛出，会交给它来进行异常处理。
	ViewResolver：HandlerAdapter会把Controller中调用返回值最终包装成ModelAndView,ViewResolver会检查其中的view，如果view是一个字符串，它就负责处理这个字符串并返回一个真正的View，如果view是一个真正的View则不会交给它处理。

为什么view即可以是字符串又会是View呢？
View：对应MVC 中的V， 此接口只有一个方法 render，用于视图展现。
ModelAndView：这个类中的view这个属性是 Object 类型的，它可以是一个视图名也可以是一个实际的View，这点通过观察其源码可以发现。

	private Object view;

	public void setViewName(String viewName) {
	　　 this.view = viewName;
	}

	public String getViewName() {
	　　return (this.view instanceof String ? (String) this.view : null);
	}

	public void setView(View view) {
	　　this.view = view;
	}

	public View getView() {
	　　return (this.view instanceof View ? (View) this.view : null);
	}     


HandlerMapping，HandlerAdapter，HandlerExceptionResovler，ViewResolver都有个order属性，因为这些接口每一个都可以注册多个实现，order代表他们的执行顺序，order越小的越先执行，一般先执行的匹配到了后面的就不会执行了。

###流程图

![spring mvc 执行流程图](/images/spring_mvc_exec_flow.png)