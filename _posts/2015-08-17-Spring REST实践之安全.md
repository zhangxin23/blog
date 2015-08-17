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

XAuth
As REST APIs became popular, the number of third-party applications that use those APIs also grew significantly. These applications need a username and password in order to interact with REST services and perform actions on behalf of users. This poses a huge security problem as third-party applications now have access to usernames and passwords. A security breach in the third-party application can compromise user information. Also, if the user changes his credentials, he needs to remember to go and update all of these third-party applications. Finally, this mechanism doesn’t allow the user to revoke his authorization to the third-party application. The only option for revoking in this case would be to change his password.
The XAuth and OAuth schemes provide a mechanism to access protected resources on a user’s behalf without needing to store passwords. In this approach, a client application would request a username
and password from the user typically by using a login form. The client would then send the username
and password to the server. The server receives the user’s credentials and validates them. On successful validation, a token is returned to the client. The client discards the username and password information and stores the token locally. When accessing a user’s protected resource, the client would include the token in the request. This is typically accomplished using a custom HTTP header such as X-Auth-Token. The longevity of the token is dependent on the implementing service. The token can remain until the server revokes it or the token can expire in a designated period of time.

XAuth security flow.png

Applications such as Twitter allow third-party applications to access their REST API using an XAuth scheme. However, even with XAuth, a third-party application needs to capture a username and password, leaving the possibility of misuse. Considering the simplicity involved in XAuth, it might be a good candidate when the same organization develops the client as well as the REST API.

OAuth 2.0
The Open Authorization or OAuth is a framework for accessing protected resources on behalf of a user without storing a password. The OAuth protocol was first introduced in 2007 and was superseded by OAuth 2.0, which was introduced in 2010. In this book, we will be reviewing OAuth 2.0.
OAuth 2.0 defines the following four roles:
• Resource Owner—A resource owner is the user that wants to give access to portions of their account or resources. For example, a resource owner could be a Twitter or a Facebook user.
• Client—A client is an application that wants access to a user’s resources. This could be a third-party app such as Klout (https://klout.com/) that wants to access a user’s Twitter account.
• Authorization Server—An authorization server verifies the user’s identity and grants the client a token to access the user’s resources.
• Resource Server—A resource server hosts protected user resources. For example, this would be Twitter API to access tweets and timelines, and so on.
The interactions between these four roles discussed are depicted in Figure 8-6. OAuth 2.0 requires these interactions to be conducted on SSL.

Before a client can participate in the “OAuth dance” shown in Figure 8-6, it must register itself with
the Authorization Server. For most public APIs such as Facebook and Twitter, this involves filling out an application form and providing information about the client such as application name, base domain, and website. On successful registration, the client will receive a Client ID and a Client secret. The Client ID is used to uniquely identify the Client and is available publicly. These client credentials play an important part in the OAuth interactions, which we will discuss in just a minute.
The OAuth interaction begins with the user expressing interest in using the “Client,” a third-party application. The client requests authorization to access protected resources on the user’s behalf and redirects the user/resource owner to the Authorization server. An example URI that the client can redirect the user to is shown here:
https://oauth2.example.com/authorize?client_id=CLIENT_ID&response_type=auth_code&call_
back=CALL_BACK_URI&scope=read,tweet
The usage of HTTPS is mandatory for any production OAuth 2.0 interactions and, hence, the URI begins with https. The CLIENT_ID is used to provide the client’s identity to the authorization server. The scope parameter provides a comma separated set of scopes/roles that the client needs.
On receiving the request, the authorization server would present the user with an authentication challenge typically via a login form. The user provides his username and password. On successful verification of the user credentials, the authorization server redirects the user to the client application using the CALL_BACK_URI parameter. The authorization server also appends an authorization code to the CALL_BACK_URI parameter value. Here is an example URL that an authorization server might generate:
https://mycoolclient.com/code_callback?auth_code=6F99A74F2D066A267D6D838F88
The client then uses the authorization code to request an Access Token from the authorization server. To achieve this, a client would typically perform a HTTP POST on a URI like this:
https://oauth2.example.com/access_token?client_id=CLIENT_ID&client_secret=CLIENT_SECRET&
auth_code=6F99A74F2D066A267D6D838F88

As you can see, the client provides its credentials as part of the request. The authorization server verifies the client’s identity and authorization code. On successful verification, it returns an access token. Here is an example response in JSON format:
{"access_token"="f292c6912e7710c8"}
On receiving the access token, the client will request a protected resource from the resource server passing in the access token it obtained. The resource server validates the access token and serves the protected resource.

OAuth Client Profiles
One of the strengths of OAuth 2.0 is its support for variety of client profiles such as “Web application,” “Native application,” and “User Agent/Browser application.” The authorization code flow discussed
earlier (often referred to as authorization grant type) is applicable to “Web application” clients that have
a Web-based user interface and a server side backend. This allows the client to store the authorization code in a secure backend and reuse it for future interactions. Other client profiles have their own flows that determine the interaction between the four OAuth 2.0 players.
A pure JavaScript-based application or a native application can’t store authorization codes securely. Hence, for such clients, the callback from the authorization server doesn’t include an authorization code. Instead, an implicit grant type approach is taken and an access token is directly handed over to the client, which is then used for requesting protected resources. Applications falling under this client profile will not have a client secret and are simply identified using the client ID.
OAuth 2.0 also supports an authorization flow, referred to as password grant type, that is similar
to XAuth discussed in the previous section. In this flow, the user supplies his credentials to the client application directly. He is never redirected to the authorization server. The client passes these credentials to the authorization server and receives an access token for requesting protected resources.
OAuth 1.0 introduced several implementation complexities especially around the cryptographic requirements for signing requests with client credentials. OAuth 2.0 simplified this by eliminating signatures and requiring HTTPS for all interactions. However, because many of OAuth 2’s features are optional, the specification has resulted in noninteroperable implementations.


Refresh Tokens versus Access Tokens
The lifetime of access tokens can be limited and clients should be prepared for the possibility of a token no longer working. To prevent the need for the resource owner to repeatedly authenticate, the OAuth 2.0 specification has provided a notion of refresh tokens. An authorization server can optionally issue a refresh token when it generates an access token. The client stores this refresh token, and when an access token expires, it contacts the authorization server for a fresh set of access token as well as refresh token. Specification allows generation of refresh tokens for authorization and password grant type flows. Considering the lack of security with the “implicit grant type,” refresh tokens are prohibited for such client profiles.

Spring Security Overview
To implement security in the QuickPoll application we will be using another popular Spring subproject, namely, Spring Security. Before we move forward with the implementation, let’s understand Spring Security and the different components that make up the framework.

Spring Security, formerly known as Acegi Security, is a framework for securing Java-based applications. It provides an out-of-the-box integration to a variety of authentication systems such as LDAP, Kerberos, OpenID, OAuth, and so on. With minimal configuration, it can be easily extended to work with any custom authentication and authorization systems. The framework also implements security best practices and has inbuilt features to protect against attacks such as CSRF, or Cross Site Request Forgery, and session fixation, and so on.
Spring Security provides a consistent security model that can be used to secure Web URLs and Java methods. The high-level steps involved during the Spring Security Authentication/Authorization process along with components involved are listed here:
1. The process begins with a user requesting a protected resource on a Spring-secured Web application.
2. The request goes through a series of Spring Security filters referred to
as a “filter chain” that identify an org.springframework.security. web.AuthenticationEntryPoint to service the request. The AuthenticationEntryPoint will respond to the client with a request to authentication. This is done, for example, by sending a login page to the user.
3. On receiving authentication information from the user such as a username/ password, a org.springframework.security.core.Authentication object
is created. The Authentication interface is shown in Listing 8-1 and its implementations plays a dual role in Spring Security. They represent a token for an authentication request or a fully authenticated principal after authentication is successfully completed. The isAuthenticated method can be used to determine the current role played by an Authentication instance. In case of
a username/password authentication, the getPrincipal method returns the username and the getCredentials returns the password. The getUserDetails method contains additional information such as IP address, and so on.
Listing 8-1. Authentication API
public interface Authentication extends Principal, Serializable {
}
Object getPrincipal();
Object getCredentials();
Object getDetails();
Collection<? extends GrantedAuthority> getAuthorities();
boolean isAuthenticated();
void setAuthenticated(boolean isAuthenticated) throws
IllegalArgumentException;
4. As a next step, the authentication request token is presented to an org.springframework.security.authentication.AuthenticationManager. The AuthenticationManger as shown in Listing 8-2, contains an authenticate method that takes an authentication request token and returns a fully populated Authentication instance. Spring provides an out-of-the-box implementation of AuthenticationManger called ProviderManager.

Listing 8-2. AuthenticationManager API
          public interface AuthenticationManager {
                  Authentication authenticate(Authentication authentication)
                  throws AuthenticationException;
}
5. In order to perform an authentication, the ProviderManager needs to compare the submitted user information with a backend user store such as LDAP or database. ProviderManager delegates this responsibility to a series of org.springframework.security.authentication.AuthenticationProvider. These AuthenticationProviders use an org.springframework.security.core. userdetails.UserDetailsService to retrieve user information from backend stores. Listing 8-3 shows the UserDetailsService API.
Listing 8-3. UserDetailsService API
public interface UserDetailsService {
                  UserDetails loadUserByUsername(String username)
                  throws UsernameNotFoundException;
}
Implementations of UserDetailsService such as JdbcDaoImpl and LdapUserDetailService will use the passed-in username to retrieve user information. These implementations will also create a set of GrantedAuthority instances that represent roles/authorities the user has in the system.
6. The AuthenticationProvider compares the submitted credentials with
the information in the backend system and on successful verification the org.springframework.security.core.userdetails.UserDetails object is used to build a fully populated Authentication instance.
7. The Authentication instance is then put into an org.springframework. security.core.context.SecurityContextHolder. The SecurityContextHolder as the name suggests simply associates the logged-in user’s context with the current thread of execution so that it is readily available across user requests or operations. In a Web-based application, the logged-in user’s context is typically stored in the user’s HTTP session.
8. Spring Security then performs an authorization check using an org.springframework.security.access.intercept.AbstractSecurity Interceptor and its implementations org.springframework.security.web. access.intercept.FilterSecurityInterceptor and org.springframework. security.access.intercept.aopalliance.MethodSecurityInterceptor. The FilterSecurityInterceptor is used for URL-based authorization and MethodSecurityInterceptor is used for method invocation authorization.
9. The AbstractSecurityInterceptor relies on security configuration and a set of org.springframework.security.access.AccessDecisionManagers to decide if the user is authorized or not. On successful authorization, the user is given access to the protected resource.


<dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
</dependency>


curl -vu user:554cc6c2-67e1-4f1e-8c5b-096609e2d0b1 http://localhost:8080/v3/polls
