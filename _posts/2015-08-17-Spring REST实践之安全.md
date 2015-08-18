---
layout: post
title: "Spring REST实践之安全"
description: "Spring REST实践之安全"
category: Web
tags: [web, Spring, REST]
---

##Securing REST Services

一般有六种方式实现的REST服务的安全：

	Session-based security
	HTTP Basic Authentication
	Digest Authentication
	Certificate based security
	XAuth
	OAuth

###Session-based Security

Session-based Security方式需要server端会话保存用户的身份信息，以便在多个请求中使用。它的流程图如下所示：

![Session-based security flow](/images/Session-based security flow.png)

Spring Security支持此种安全模型，此种方式对于开发者非常有吸引力。但是这种方式违背了REST无状态的约束，而且因为server需要保存client的状态，所以这种方式不是可扩展的。理想情况下，client应该保存自己的状态，而server应该是无状态的。

###HTTP Basic Authentication

当有用户交互时，提供一个login窗口获取username和password是可行的，但是服务之间的交互就不可行了。HTTP Basic Authentication可同时支持交互与非交互模式。在这种方法中，当client发出一个针对保护资源的请求，server会返回一个401(Unauthorized)状态码和“WWW-Authenticate” header。

	GET /protected_resource
	401 Unauthorized
	WWW-Authenticate: Basic realm="Example Realm"

Basic部分表明使用Basic认证，realm指示服务器上一个保护的空间。

客户端收到上面的响应后，用Base64编码"user:password"字符串，并将其放到Authorization header后发送给服务器，如：

	GET /protected_resource
	Authorization: Basic bHxpY26U5lkjfdk
	
服务器解码提交的信息、验证提交的证书。如果认证成功，server结束此请求。

![HTTP Basic authentication flow](/images/HTTP Basic authentication flow.png)

因为client包含了认证的信息，所以server是无状态的。但是client指示简单的对用户名和密码进行加密，因此在not-SSL/TLS链接中，此种方式有可能遭受中间人攻击，窃取密码。

Digest Authentication
The Digest Authentication approach is similar to the Basic authentication model discussed earlier except that the user credentials are sent encrypted. The client submits a request for a protected resource and the server responds with a 401 “Unauthorized” response code and a WWW-Authenticate header. 

###Digest Authentication

Digest Authentication和HTTP Basic Authentication非常相似，除了用户的证书是加密传送的。client提交一个针对包含资源的请求，然后server回复一个401(Unauthorized)状态码和一个WWW-Authenticate header，如下所示：

	GET /protected_resource
	401 Unauthorized
	WWW-Authenticate: Digest realm="Example Realm", nonce="P35kl89sdfghERT10Asdfnbvc", qop="auth"

WWWW-Authenticate指定了认证模式、server产生的特殊词语、qop(quality of protection)。nonce是一个任意的token，用于加密。qop指示语可包含"auth"和"auth-int"两个值：

	A qop value "auth" indicates that the digest is used for authentication purposes
	A value "auth-int" indicates that digest will be used for authentication and request integrity

client接收到响应后，如果qop是auth，client会用下面公式产生digest(摘要)：
	
	hash_value_1 = MD5(username:realm:password)
	has_value_2 = MD5(request_method:request_uri)
	digest = MD5(hash_value_1:nonce:hash_value_2)

如果qop是auth-int，client在产生digest时会包含request body：

	hash_value_1 = MD5(username:realm:password)
	has_value_2 = MD5(request_method:request_uri:MD5(request_body))
	digest = MD5(hash_value_1:nonce:hash_value_2)

server接收到上面经过计算的digest后，会进行认证操作。如果认证成功，server会结束请求过程。

![Digest authentication flow](/images/Digest authentication flow.png)

Digest authentication比HTTP Basic authentication更加安全。但是，在non-SSL/TLS通信中，它还是存在被snooper检索digest、回复请求的可能。解决这个问题的一个方法就是限制server产生的nonces只能使用一次。还有，由于server为了认证必须产生digest，它需要能够访问密码的明文格式。因此server不能使用不可逆的加密算法，而且server会成为系统安全的薄弱环节。

###Certificte-Based Security

Certificated-based security模型需要证书验证参与者的身份。在SSL/TLS为基础的通信中，client通过证书验证server的身份。在这种方式中，当server接收到一个针对保护资源的请求后，会发送自己的证书给client。client确认此证书是可信证书机构颁发的证书后，发送它自己的证书给server。server验证client的证书，当成功验证后，server会将受保护资源的访问权限分给client。

![Certificate-based security flow](/images/Certificate-based security flow.png)

Certificate-based security模型消除了发送共享密码的需求，使得它更加安全。但是，布置和维护证书是非常昂贵的，一般只能在大型系统中使用。

###XAuth

随着REST API变得流行起来，使用API的第三方应用的数量也会显著增长。这些应用需要用户名和密码和REST服务交互，这样存在巨大的风险，因为第三方应用有访问用户名和密码的权限。一种简单的解决方案是第三方应用保存用户信息。如果用户更改了他的凭证，他需要更新所有的第三方应用。而且此种方式不允许用户撤销他对第三方的授权。在这种情况下，只有更改密码才能撤销授权。

XAuth和OAuth提供了用户不用保存密码就能访问受保护资源的方式。在这种方式中，客户端应用可通过login form请求用户名和密码，然后client发送用户名和密码到server，server接收到后，验证client的凭证。如果验证成功，一个token会返回给client。client可以放弃用户名和密码，在本地存储token。当再访问受保护资源时，token会被包含在请求中，可用X-Auth-Token完成此目的。token的有效期由实现决定，token可以一直保存直到server删除它或者token在给定的时间内过期。如果client和REST API都由一个组织开发，那么这种方式可以作为备选方案。

![XAuth security flow](/images/XAuth security flow.png)

###OAuth 2.0

OAuth(Open Authorization)是一个用户不用保存密码就可以访问受保护资源的框架。OAuth在2007年开发出来，于2010年被OAuth2.0取代。OAuth2.0定义了如下四个角色：

	Resource Owner-A：可以给予访问账户或者资源的权限的用户，比如微博的用户。
	Client A：需要获得访问用户资源权限的客户端应用。
	Authorizatin Server：验证用户的身份，并发给client一个可以访问资源的token。
	Resource Server：保存受保护资源的服务器。

OAuth 2.0需要在SSL上完成信息交互。

![OAuth2 security flow](/images/OAuth2 security flow.png)


##spring安全相关

可在POM文件中包含如下依赖：

	<dependency>
	        <groupId>org.springframework.boot</groupId>
	        <artifactId>spring-boot-starter-security</artifactId>
	</dependency>
