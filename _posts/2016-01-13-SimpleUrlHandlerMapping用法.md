---
layout: post
title: "SimpleUrlHandlerMapping用法"
description: "SimpleUrlHandlerMapping用法"
category: Spring MVC
tags: [Sprint MVC]
---

SimpleUrlHandlerMapping是Spring MVC中适用性最强的Handler Mapping类，允许明确指定URL模式和Handler的映射关系。有两种方式声明SimpleUrlHandlerMapping。

###prop key

key是URL模式，属性值是Handler的ID或者名字。

	<beans ...>
	 
		<bean class="org.springframework.web.servlet.handler.SimpleUrlHandlerMapping">
		   <property name="mappings">
			<props>
			   <prop key="/welcome.htm">welcomeController</prop>
			   <prop key="/*/welcome.htm">welcomeController</prop>
			   <prop key="/helloGuest.htm">helloGuestController</prop>
			 </props>
		   </property>
		</bean>
		
		<bean id="welcomeController" 
			class="com.mkyong.common.controller.WelcomeController" />
			
		<bean id="helloGuestController" 
			class="com.mkyong.common.controller.HelloGuestController" />
			
	</beans>

###value

等号左边是URL模式，右边是Handler的ID或者名字。

	<beans ...>
		
		<bean class="org.springframework.web.servlet.handler.SimpleUrlHandlerMapping">
		   <property name="mappings">
			<value>
			   /welcome.htm=welcomeController
			   /*/welcome.htm=welcomeController
			   /helloGuest.htm=helloGuestController
			</value>
		   </property>
		</bean>
		
		<bean id="welcomeController" 
			class="com.mkyong.common.controller.WelcomeController" />
			
		<bean id="helloGuestController" 
			class="com.mkyong.common.controller.HelloGuestController" />
			
	</beans>
