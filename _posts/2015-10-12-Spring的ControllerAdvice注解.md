---
layout: post
title: "Spring的ControllerAdvice注解"
description: "Spring的ControllerAdvice注解"
category: Spring
tags: [Spring, Java]
---

@ControllerAdvice，是spring3.2提供的新注解，其实现如下所示：

    @Target(ElementType.TYPE)  
    @Retention(RetentionPolicy.RUNTIME)  
    @Documented  
    @Component  
    public @interface ControllerAdvice {  

    }  
 
该注解使用@Component注解，这样当使用<context:component-scan>扫描时可以扫描到。

@ControllerAdvice注解类中使用@ExceptionHandler、@InitBinder、@ModelAttribute注解的方法将应用到所有@RequestMapping注解的方法，不过只有@ExceptionHandler最有用，另外两个用处不大。
 
该注解非常简单，大多数时候其实只@ExceptionHandler比较有用，其他两个用到的场景非常少，这样可以把异常处理器应用到所有控制器。