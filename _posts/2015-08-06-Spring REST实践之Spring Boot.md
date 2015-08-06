---
layout: post
title: "Spring REST实践之Spring Boot"
description: "Spring REST实践之Spring Boot"
category: Web
tags: [web, Spring, REST]
---

Spring Boot hosts an Initializr application at http://start.spring.io. The Initializr provides a Web
interface that allows you to enter project information, pick the capabilities needed for your project, and
voilà—it generates the project as a zip file.

The groupId, artifactId, and version elements in the pom.xml file correspond to Maven’s standard
GAV coordinates describing our project. The parent tag indicates that we will be inheriting from the spring-
boot-starter-parent POM. This ensures that our project inherits Spring Boot’s default dependencies
and versions. The dependencies element lists two POM file dependencies: spring-boot-starter-web and
spring-boot-starter-test. Spring Boot uses the term starter POMs to describe such POM files.
These starter POMs are used to pull other dependencies and don’t actually contain any code of their
own. For example, the spring-boot-starter-web pulls Spring MVC dependencies, Tomcat-embedded
container dependencies, and a Jackson dependency for JSON processing. These starter modules play an
important role in providing needed dependencies and simplifying the application’s POM file to just a few
lines.

Spring Boot Starter Modules:
spring-boot-starter Starter that brings in core dependencies necessary for functions such
as auto-configuration support and logging
spring-boot- starter-aop Starter that brings in support for aspect-oriented programming and
AspectJ
spring-boot-starter-test Starter that brings in dependencies such as JUnit, Mockito, and
spring-test necessary for testing
spring-boot-starter-web Starter that brings in MVC dependencies (spring-webmvc) and
embedded servlet container support
spring-boot-starter-data-jpa Starter that adds Java Persistence API support by bringing in spring-
data-jpa, spring-orm and Hibernate dependencies
spring-boot-starter-data-rest Starter that brings in spring-data-rest-webmvc to expose
repositories as REST API
spring-boot-starter-hateoas Starter that brings in spring-hateoas dependencies for HATEOAS
REST services
spring-boot-starter-jdbc Starter for supporting JDBC databases

Finally, the spring-boot-maven-plugin contains goals for packaging the application as an executable
JAR/WAR and running it.

The @SpringBootApplication annotation is a convenient annotation and is equivalent to declaring the
following three annotations:
•	 @Configuration—Marks the annotated class as containing one or more Spring bean
declarations. Spring processes these classes to create bean definitions and instances.
•	 @ComponentScan—This class tells Spring to scan and look for classes annotated with
@Configuration, @Service, @Repository, and so on. By default, Spring scans all the
classes in the package where the @ComponentScan annotated class resides.
•	 @EnableAutoConfiguration—Enables Spring Boot’s auto-configuration behavior.
Based on the dependencies and configuration found in the classpath, Spring Boot
intelligently guesses and creates bean configurations.

The main() method simply delegates the application bootstrapping to SpringApplication’s run()
method. run() takes a HelloWorldRestApplication.class as its argument and instructs Spring to read
annotation metadata from HelloWorldRestApplication and populate ApplicationContext from it.

mvn spring-boot:run

Spring Boot provides a command line interface (CLI) for generating projects, prototyping, and running
Groovy scripts. Before we can start using the CLI, we need to install it.

C:\test>spring init --dependencies web rest-cli
Using service at https://start.spring.io
Project extracted to 'C:\test\rest-cli'


Postman

RESTClient

---------------------------------------------------------------------------------------------

The first convention is to use a base URI for our REST service

The second convention is to name resource endpoints using plural nouns

The third convention advises using a URI hierarchy to represent resources that are related to each other.

the fourth convention recommends using a query parameter(Because we don’t
have any domain objects that can directly help generate this resource representation,).

-------------------------------------------------------------------------------------------------------------------------------

The @RestController is
a convenient yet meaningful annotation and has the same effect as adding both @Controller and
@ResponseBody annotations.

ResponseEntity gives
you full control over the HTTP response, including the response body and response headers.

The @RequestBody annotation tells Spring that the entire request body needs to be
converted to an instance of Poll.Spring uses the incoming Content-Type header to identify a proper message
converter and delegates the actual conversion to it.Spring Boot comes with message converters that support
JSON and XML resource representations.

Spring makes the URI generation process easy
via its ServletUriComponentsBuilder utility class:
URI newPollUri = ServletUriComponentsBuilder
.fromCurrentRequest()
.path("/{id}")
.buildAndExpand(poll.getId())
.toUri();

The fromCurrentRequest method prepares the builder by copying information such as host,
schema, port, and so on from the HttpServletRequest. The path method appends the passed-in path
parameter to the existing path in the builder. In the case of the createPoll method, this would result in
http://localhost:8080/polls/{id}. The buildAndExpand method would build an UriComponents instance
and replaces any path variables ({id} in our case) with passed-in value. Finally, we invoke the toUri method
on the UriComponents class to generate the final URI.