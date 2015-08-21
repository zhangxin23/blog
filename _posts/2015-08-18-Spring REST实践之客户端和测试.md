---
layout: post
title: "Spring REST实践之客户端和测试"
description: "Spring REST实践之客户端和测试"
category: Web
tags: [web, Spring, REST, Test]
---

##RestTemplate

可参考spring实战来写这部分。

RestTemplate免于编写乏味的样板代码，RestTemplate定义了33个与REST资源交互的方法，涵盖了HTTP动作的各种形式，其实这些方法只有11个独立的方法，而每一个方法都由3个重载的变种。

	delete()：在特定的URL上对资源执行HTTP DELETE操作
	exchange()：在URL上执行特定的HTTP方法，返回包含对象的ResponseEntity，这个对象是从响应体中映射得到的
	execute()：在URL上执行特定的HTTP方法，返回一个从响应体映射得到的对象
	getForEntity()：发送一个HTTP GET请求，返回的ResponseEntity包含了响应体所映射成的对象
	getForObject()：GET资源，返回的请求体将映射为一个对象
	headForHeaders()：发送HTTP HEAD请求，返回包含特定资源URL的HTTP头
	optionsForAllow()：发送HTTP OPTIONS请求，返回对特定URL的Allow头信息
	postForEntity()：POST数据，返回包含一个对象的ResponseEntity，这个对象是从响应体中映射得到
	postForLocation()：POST数据，返回新资源的URL
	postForObject()：POST数据，返回的请求体将匹配为一个对象
	put()：PUT资源到特定的URL

除了TRACE，RestTemplate涵盖了所有的HTTP动作。除此之外，execute()和exchange()提供了较低层次的通用方法来使用任意的HTTP方法。

每个方法都以3种方法进行了重载：

	一个使用java.net.URI作为URL格式，不支持参数化URL
	一个使用String作为URL格式，并使用Map指明URL参数
	一个使用String作为URL格式，并使用可变参数列表指明URL参数

###GET资源

有两种执行GET请求的方法：getForObject()和getForEntity()。3个getObject()方法的签名如下：

	<T> T getForObject(URI url, Class<T> responseType) throws RestClientException;
	<T> T getForObject(String url, Class<T> responseType, Object... uriVariables) throws RestClientException;
	<T> T getForObject(String url, Class<T> responseType, Map<String, ?> uriVariables) throws RestClientException;

类似地，getForEntity()方法的签名如下：

	<T> ResponseEntity<T> getForObject(URI url, Class<T> responseType) throws RestClientException;
	<T> ResponseEntity<T> getForObject(String url, Class<T> responseType, Object... uriVariables) throws RestClientException;
	<T> ResponseEntity<T> getForObject(String url, Class<T> responseType, Map<String, ?> uriVariables) throws RestClientException;

除了返回类型，getForObject()方法就是getForEntity()方法的镜像。实际上，它们的工作方式大同小异。它们都执行根据URL检索资源的GET请求。它们都将资源根据responseType参数匹配为一定的类型。唯一的区别在于getForObject()只返回所请求类型的对象，而getForEntity()方法会返回请求的对象以及响应的额外信息。

	public Spittle[] retrieveSpittlesForSpitter(String username) {
		return new RestTemplate().getForObject("http://localhost:8080/Spitter/{spitter}/spittles", 
			Spittle[].class, username);
	}

	public Spittle[] retrieveSpittlesForSpitter(String username) {
		ResponseEntity<Spittle[]> reponse = new RestTemplate().getForEntity(
			"http://localhost:8080/Spitter/{spitter}/spittles",
			Spittle[].class, username);

		if(reponse.getStatusCode() == HttpStatus.NOT_MODIFIED) {
			throw new NotModifiedException();
		}

		return reponse.getBody();
	}

###PUT资源

	void put(URI url, Object request) throws RestClientException;
	void put(String url, Object request, Object... uriVairables) throws RestClientException;
	void put(String url, Object request, Map<String, ?> uriVariables) throws RestClientException;

	public void updateSpittle(Spittle spittle) throws SpitterException {
		try {
			String url = "http://localhost:8080/Spitter/spittles/" + spittle.getId();
			new RestTemplate().put(new URI(url), spittle);
		} catch(URISyntaxException e) {
			throw new SpitterUpdateException("Unable to update Spittle", e);
		}
	}

	public void updateSpittle(Spittle spittle) throws SpitterException {
		restTemplate.put("http://localhost:8080/Spitter/spittles/{id}",
			spittle, spittle.getId());
	}

	public void updateSpittle(Spittle spittle) throws SpitterException {
		Map<String, String> params = new HashMap<String, String>();
		params.put("id", spittle.getId());
		restTemplate.put("http://localhost:8080/Spitter/spittles/{id}",
			spittle, params);
	}

###DELETE资源

	void delete(String url, Object... uriVariables) throws RestClientException;
	void delete(String url, Map<String, ?> uriVariables) throws RestClientException;
	void delete(URI url) throws RestClientException;

	public void deleteSpittle(long id) {
		try {
			restTemplate.delete(new URI("http://localhost:8080/Spitter/spittles/" + id));
		} catch(URISyntaxException e) {

		}
	}

###POST资源数据

POST请求有postForObject()和postForEntity()两种方法，和GET请求的getForObject()和getForEntity()方法类似。getForLocation()是POST请求所特有的。

	<T> T postForObject(URI url, Object request, Class<T> responseType) throws RestClientException;
	<T> T postForObject(String url, Object request, Class<T> responseType, Object... uriVariables) throws RestClientException;
	<T> T postForObject(String url, Object request, Class<T> responseType, Map<String, ?> uriVariables) throws RestClientException;

上面三个方法中，第一个参数都是资源要POST到的URL，第二个参数是要发送的对象，而第三个参数是预期返回的Java类型。在URL作为String类型的两个版本中，第四个参数指定了URL变量（要么是可变参数列表，要么是一个Map）。

	<T> T postForObject(URI url, Object request, Class<T> responseType) throws RestClientException;
	<T> T postForObject(String url, Object request, Class<T> responseType, Object... uriVariables) throws RestClientException;
	<T> T postForObject(String url, Object request, Class<T> responseType, Map<String, ?> uriVariables) throws RestClientException;

	ResponseEntity<Spitter> response = new RestTemplate().postForEntity("http://localhost:8080/Spitter/spitters",
		spitter, Spitter.class);
	Spitter spitter = response.getBody();
	URI url = response.getHeaders().getLocation();

postForLacation()会在POST请求的请求体中发送一个资源到服务器端，返回的不再是资源对象，而是创建资源的位置。

	URI postForLocation(String url, Object request, Object... uriVariables) throws RestClientException;
	URI postForLocation(String url, Object request, Map<String, ?> uriVariables) throws RestClientException;
	URI postForLocation(URI url, Object request) throws RestClientException;

	public String postSpitter(Spitter spitter) {
		RestTemplate rest = new RestTemplate();
		return rest.postForLocation("http://localhost:8080/Spitter/spitters",
			spitter).toString();
	}

###交换资源

exchange方法可以在发送个服务器端的请求中设置头信息。

	<T> ResponseEntity<T> exchange(URI url, HttpMethod method, HttpEntity<?> requestEntity, Class<T> responseType) throws RestClientException;

	<T> ResponseEntity<T> exchange(String url, HttpMethod method, HttpEntity<?> requestEntity, Class<T> responseType, Object... uriVariables) throws RestClientException;

	<T> ResponseEntity<T> exchange(String url, HttpMethod method, HttpEntity<?> requestEntity, Class<T> responseType, Map<String, ?> uriVariables) throws RestClientException;


	MultiValueMap<String, String> headers = new LinkedMultiValueMap<String, String>();
	headers.add("Accept", "application/json");
	HttpEntity<Object> requestEntity = new HttpEntity<Object>(headers);

	ResponseEntity<Spitter> response = rest.exchange("http://localhost:8080/Spitter/spitters/{spitter}",
		HttpMethod.GET, requestEntity, Spitter.class, spitterId);
		
##Testing REST Services

Spring框架提供了spring-test模块，spring-test模块为JNDI，Servlet和Portlet API提供了一系列的注解，工具类和mock对象。此框架同时也提供了跨测试执行过程的缓存应用上下文功能。为了能够在非Spring Boot工程中使用spring-test模块，你需要包含如下依赖：

	<dependency>
	        <groupId>org.springframework</groupId>
	        <artifactId>spring-test</artifactId>
	        <version>4.1.6.RELEASE</version>
	        <scope>test</scope>
	</dependency>

Spring Boot提供了spring-boot-starter-test，它自动在Boot应用中增加了spring-test模块，同时starter POM也包含了JUnit，Mockito和Hamcrest库：

	Mockito是一款流行的mocking框架。它提供了简单的API用于创建和配置mock。
	Hamcrest是一款为创建matcher提供了强大词汇的框架。matcher允许你将一个对象和期望的执行的结果联系起来。Matcher使得断言更加刻度，同时它们也产生有意义的错误信息，当断言失败时。

为了更好地理解spring-test模块，下面是测试用例：

	@RunWith(SpringJUnit4ClassRunner.class)
	@SpringApplicationConfiguration(classes = QuickPollApplication.class)
	@WebAppConfiguration
	public class ExampleTest {
	}
	@Before
	public void setup() { }
	@Test
	public void testSomeThing() {}
	@After
	public void teardown() { }

@RunWith注解用于指定具体测试类，@ContextConfiguration用于为SpringJUnit4ClassRunner指定使用哪个XML配置文件。在上例中，@SpringApplicationConfiguration是提供了附加的Spring Boot特性的特殊的ContextConfiguration版本。@WebAppConfiguration指导Spring创建web应用上下文，即WebApplicationContext。

###Unit Testing REST Controllers

Spring的依赖注入使得单元测试变得非常简单。依赖能够轻松用来模拟事先定义好的行为，因此允许我们孤立的测试代码。

	import static org.junit.Assert.assertEquals;
	import static org.mockito.Mockito.when;
	import static org.mockito.Mockito.times;
	import static org.mockito.Mockito.verify;
	import java.util.ArrayList;
	import com.google.common.collect.Lists;
	import org.junit.Before;
	import org.junit.Test;
	import org.mockito.Mock;
	import org.mockito.MockitoAnnotations;
	import org.springframework.http.HttpStatus;
	import org.springframework.http.ResponseEntity;
	import org.springframework.test.util.ReflectionTestUtils;
	public class PollControllerTestMock {
	    @Mock
	    private PollRepository pollRepository;

        @Before
        public void setUp() throws Exception {
	                MockitoAnnotations.initMocks(this);
		}
        
        @Test
        public void testGetAllPolls() {
	        PollController pollController  = new PollController();
			ReflectionTestUtils.setField(pollController, "pollRepository", pollRepository);
			when(pollRepository.findAll()).thenReturn(new ArrayList<Poll>());
			ResponseEntity<Iterable<Poll>> allPollsEntity = pollController.getAllPolls();
			verify(pollRepository, times(1)).findAll();
			assertEquals(HttpStatus.OK, allPollsEntity.getStatusCode());
			assertEquals(0, Lists.newArrayList(allPollsEntity.getBody()).size());
		}
	}

###Spring MVC Test framework Basics

Spring MVC测试框架包含四个重要的类：MockMvc，MockMvcRequestBuilders，MockMvcResultMatchers和MockMvcBuilders。org.springframework.test.web.servlet.MockMvc类是Spring MVC测试框架的核心，它能够执行HTTP请求。它只包含了perform方法：

	public ResultActions perform(RequestBuilder requestBuilder) throws java.lang.Exception

RequestBuilder提供了创建GET、POST等请求的抽象接口。为了简化请求的构建，Spring MVC框架提供了org.springframework.test.web. servlet.request.MockHttpServletRequestBuilder实现，而且在此类中提供了helper静态方法集合。

	post("/test_uri")
	 .param("admin", "false")
	 .accept(MediaType.APPLICATION_JSON)
	 .content("{JSON_DATA}");

上例中post方法用来创建POST请求。MockMvcRequestBuilder也提供了创建get、delete和put等请求的方法。param方法属于MockHttpServletRequestBuilder类，用来为请求增加参数。MockHttpServletRequestBuilder类还提供了accept、content和header等用于向请求增加data和metadata的方法。

perform方法返回org.springframework.test.web.servlet.ResultActions对象，此对象可被用来在响应上执行断言操作。

	mockMvc.perform(post("/test_uri"))
       .andExpect(status().isOk())
       .andExpect(content().contentType(MediaType.APPLICATION_JSON))
       .andExpect(content().string("{JSON_DATA}"));

status方法验证响应的状态值。content方法用来杨峥响应体。

MockMvcBuilders类提供了两种方式构建MockMvc对象：

	webAppContextSetup：利用已初始化好的WebApplicationContext构建MockMvc。和上下文相关的配置信息会在MockMvc对象创建以前加载完成。这个技术被用于end-to-end测试。
	standaloneSetup：不用加载任何spring配置构建MockMvc，为测试控制器只加载基本的MVC构件。此技术被用于单元测试。

	import static org.mockito.Mockito.when;
	import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
	import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
	import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
	import static org.springframework.test.web.servlet.setup.MockMvcBuilders.standaloneSetup;
	import org.mockito.InjectMocks;
	import org.mockito.Mock;
	import org.mockito.MockitoAnnotations;
	import org.springframework.boot.test.SpringApplicationConfiguration;
	import org.springframework.mock.web.MockServletContext;
	import org.springframework.test.web.servlet.MockMvc;
	
	@RunWith(SpringJUnit4ClassRunner.class)
	@SpringApplicationConfiguration(classes = QuickPollApplication.class)
	@ContextConfiguration(classes = MockServletContext.class)
	@WebAppConfiguration
	public class PollControllerTest {
        @InjectMocks
        PollController pollController;
        @Mock
        private PollRepository pollRepository;
        private MockMvc mockMvc;
        @Before
        public void setUp() throws Exception {
            MockitoAnnotations.initMocks(this);
            mockMvc = standaloneSetup(pollController).build();
		}
        @Test
        public void testGetAllPolls() throws Exception {
	        when(pollRepository.findAll()).thenReturn(new ArrayList<Poll>());
			mockMvc.perform(get("/v1/polls"))
		        .andExpect(status().isOk())
		        .andExpect(content().string("[]"));
		} 
	}



	import static org.hamcrest.Matchers.hasSize;
	import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
	import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
	import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
	import static org.springframework.test.web.servlet.setup.MockMvcBuilders.webAppContextSetup;
	import org.springframework.boot.test.SpringApplicationConfiguration;
	import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
	import org.springframework.test.context.web.WebAppConfiguration;
	import org.springframework.test.web.servlet.MockMvc;
	import org.springframework.web.context.WebApplicationContext;
	import com.apress.QuickPollApplication;
	
	@RunWith(SpringJUnit4ClassRunner.class)
	@SpringApplicationConfiguration(classes = QuickPollApplication.class)
	@WebAppConfiguration
	public class PollControllerIT {
	    @Inject
	    private WebApplicationContext webApplicationContext;
	    private MockMvc mockMvc;
	    @Before
	    public void setup() {
			mockMvc = webAppContextSetup(webApplicationContext).build();
		}

	@Test
	public void testGetAllPolls() throws Exception {
		mockMvc.perform(get("/v1/polls"))
	        .andExpect(status().isOk())
	        .andExpect(jsonPath("$", hasSize(20)));
	    } 
	}
