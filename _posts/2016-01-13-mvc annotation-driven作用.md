---
layout: post
title: "mvc annotation-driven作用"
description: "mvc annotation-driven作用"
category: Spring MVC
tags: [Spring MVC]
---

<mvc:annotation-driven />会自动注册DefaultAnnotationHandlerMapping与AnnotationMethodHandlerAdapter两个bean，是spring MVC为Controller分发请求所必须的，annotation-driven主要完成了URL到Controller各个Handler的映射。
