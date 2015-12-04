---
layout: post
title: "ControllerAdvicd不起作用的原因"
description: "ControllerAdvice不起作用的原因"
category: spring
tags: [spring]
---

默认情况下，Spring会自动扫描被@Component，@Repository，@Service和@Controller标记的组件，并自动注册为Spring bean。而ControllerAdvice不会被扫描，所以应该通知Spring扫描ControllerAdvice标注的组件。需要在{Servlet-name}-servlet.xml文件中增加如下内容，

	<context:component-scan base-package="com.kingsoft.wps.mail.urlser" use-default-filters="false">
		<context:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
		<context:include-filter type="annotation" expression="org.springframework.stereotype.Service"/>
		<context:include-filter type="annotation" expression="org.springframework.web.bind.annotation.ControllerAdvice" />
	</context:component-scan>
