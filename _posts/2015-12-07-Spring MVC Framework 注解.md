---
layout: post
title: "Spring MVC Framework 注解"
description: "Spring MVC Framework 注解"
category: spring
tags: [spring]
---

###ControllerAdvice

Spring MVC Framework会把@ControllerAdvice注解内部使用@ExceptionHandler、@InitBinder、@ModelAttribute注解的方法应用到所有的 @RequestMapping注解的方法（不过只有当使用@ExceptionHandler最有用，另外两个用处不大）。@ExceptionHandler注解的方法适合作为所有控制器集中处理某些类型异常的地方。

该注解非常简单，大多数时候其实只@ExceptionHandler比较有用，其他两个用到的场景非常少，这样可以把异常处理器应用到所有控制器，而不是@Controller注解的单个控制器。

示例代码：

	@ControllerAdvice  
	public class ControllerAdviceTest {  

		@ModelAttribute  
		public User newUser() {  
			System.out.println("============应用到所有@RequestMapping注解方法，在其执行之前把返回值放入Model");  
			return new User();  
		}

		@InitBinder
		public void initBinder(WebDataBinder binder) {
			System.out.println("============应用到所有@RequestMapping注解方法，在其执行之前初始化数据绑定器");
		}

		@ExceptionHandler(UnauthenticatedException.class)
		@ResponseStatus(HttpStatus.UNAUTHORIZED)
		public String processUnauthenticatedException(NativeWebRequest request, UnauthenticatedException e) {
			System.out.println("===========应用到所有@RequestMapping注解的方法，在其抛出UnauthenticatedException异常时执行");
			return "viewName"; //返回一个逻辑视图名
		}
	}

如果你的spring-mvc配置文件使用如下方式扫描bean

	<context:component-scan base-package="com.sishuok.es" use-default-filters="false">  
		<context:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>  
	</context:component-scan>

需要把@ControllerAdvice包含进来，否则不起作用：

	<context:component-scan base-package="com.sishuok.es" use-default-filters="false">  
		<context:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>  
		<context:include-filter type="annotation" expression="org.springframework.web.bind.annotation.ControllerAdvice"/>  
	</context:component-scan>  

###CookieValue

@CookieValue用于将请求的Cookie数据映射到功能处理方法的参数上。

	public String test(@CookieValue(value="JSESSIONID", defaultValue="") String sessionId)   
 
如上配置将自动将JSESSIONID值入参到sessionId参数上，defaultValue表示Cookie中没有JSESSIONID时默认为空。

	public String test2(@CookieValue(value="JSESSIONID", defaultValue="") Cookie sessionId)         

传入参数类型也可以是javax.servlet.http.Cookie类型。

###ExceptionHandler

当Controller中@RequestMapping标注的方法发生未捕获的异常时，会被类中的@ExceptionHandler标注的方法（此方法处理的类型异常应该同抛出的异常类型相同获取是其子类）处理，或者由全局的@ExceptionHandler标注的方法处理（处理的异常类型要兼容）。

示例：

	@Controller  
	public class AccessController {  

		/** 
		* 异常页面控制 
		*  
		* @param runtimeException 
		* @return 
		*/  
		@ExceptionHandler(RuntimeException.class)  
		public @ResponseBody  
		Map<String,Object> runtimeExceptionHandler(RuntimeException runtimeException) {  
			logger.error(runtimeException.getLocalizedMessage());  

			Map model = new TreeMap();  
			model.put("status", false);  
			return model;
		}

	}

当这个Controller中任何一个用@RequestMapping标注的方法发生异常，一定会被这个方法拦截到。然后，输出日志。封装Map并返回，页面上得到status为false。就这么简单。

###InitBinder

在SpringMVC中，bean中定义了Date，double等类型，如果没有做任何处理的话，日期以及double都无法绑定。解决的办法就是使用spring mvc提供的@InitBinder注解。

示例：

	import org.springframework.beans.propertyeditors.PropertiesEditor;  
	  
	public class DoubleEditor extends PropertiesEditor {    
	    @Override    
	    public void setAsText(String text) throws IllegalArgumentException {    
	        if (text == null || text.equals("")) {    
	            text = "0";    
	        }    
	        setValue(Double.parseDouble(text));    
	    }    
	    
	    @Override    
	    public String getAsText() {    
	        return getValue().toString();    
	    }    
	}

在Controller类中：

	@InitBinder    
	protected void initBinder(WebDataBinder binder) {    
		...
		binder.registerCustomEditor(double.class, new DoubleEditor());
		...
	}

###Mapping

ToDo

###MatrixVariable

@MatrixVariable增强了URI的灵活性，能够满足日益复杂和交互性高的WEB应用。

@MatrixVariable包含value，defaultValue，pathVar和required四个参数。

@MatrixVariable 在Spring MVC中默认是不启用的，启用它需要设置 enable-matrix-variables="true"：

	<annotation-driven enable-matrix-variables="true" />

示例1：

	http://localhost:8080/spring_3_2/matrixvars/stocks;BT.A=276.70,+10.40,+3.91;AZN=236.00,+103.00,+3.29;SBRY=375.50,+7.60,+2.07

	@RequestMapping(value = "/{stocks}", method = RequestMethod.GET)
	public String showPortfolioValues(@MatrixVariable Map<String, List<String>> matrixVars, Model model) {

		logger.info("Storing {} Values which are: {}", new Object[] { matrixVars.size(), matrixVars });

		List<List<String>> outlist = map2List(matrixVars);
		model.addAttribute("stocks", outlist);

		return "stocks";
	}

	private List<List<String>> map2List(Map<String, List<String>> stocksMap) {

		List<List<String>> outlist = new ArrayList<List<String>>();

		Collection<Entry<String, List<String>>> stocksSet = stocksMap.entrySet();

		for (Entry<String, List<String>> entry : stocksSet) {

			List<String> rowList = new ArrayList<String>();

			String name = entry.getKey();
			rowList.add(name);

			List<String> stock = entry.getValue();
			rowList.addAll(stock);
			outlist.add(rowList);
		}

		return outlist;
	}

示例2：

	http://localhost:8080/spring_3_2/matrixvars/stocks;BT.A=276.70,+10.90,+3.91;AZN=236.00,+103.00,+3.29;SBRY=375.50,+7.60,+2.07/account;name=roger;number=105;location=stoke-on-trent,uk

	@RequestMapping(value = "/{stocks}/{account}", method = RequestMethod.GET)
	public String showPortfolioValuesWithAccountInfo(@MatrixVariable(pathVar = "stocks") Map<String, List<String>> stocks, 
							  @MatrixVariable(pathVar = "account") Map<String, List<String>> accounts, Model model) {

		List<List<String>> stocksView = map2List(stocks);
		model.addAttribute("stocks", stocksView);

		List<List<String>> accountDetails = map2List(accounts);
		model.addAttribute("accountDetails", accountDetails);

		return "stocks";
	}

###ModelAttribute

@ModelAttribute能够绑定请求参数到命令对象。

@ModelAttribute有如下三个作用：

	1 绑定请求参数到命令对象：放在功能处理方法的入参上时，用于将多个请求参数绑定到一个命令对象，从而简化绑定流程，而且自动暴露为模型数据用于视图页面展示时使用；
	
	2 暴露表单引用对象为模型数据：放在处理器的一般方法（非功能处理方法）上时，是为表单准备要展示的表单引用对象，如注册时需要选择的所在城市等，而且在执行功能处理方法（@RequestMapping注解的方法）之前，自动添加到模型对象中，用于视图页面展示时使用；
	
	3 暴露@RequestMapping方法返回值为模型数据：放在功能处理方法的返回值上时，是暴露功能处理方法的返回值为模型数据，用于视图页面展示时使用。
 
####绑定请求参数到命令对象

如用户登录，我们需要捕获用户登录的请求参数（用户名、密码）并封装为用户对象，此时我们可以使用@ModelAttribute绑定多个请求参数到我们的命令对象。

	public String test1(@ModelAttribute("user") UserModel user)  

它的作用是将该绑定的命令对象以“user”为名称添加到模型对象中供视图页面展示使用。我们此时可以在视图页面使用${user.username}来获取绑定的命令对象的属性。
 
####暴露表单引用对象为模型数据

	@ModelAttribute("cityList")  
	public List<String> cityList() {  
		return Arrays.asList("北京", "山东");  
	}

如上代码会在执行功能处理方法之前执行，并将其自动添加到模型对象中，在功能处理方法中调用Model 入参的containsAttribute("cityList")将会返回true。

	@ModelAttribute("user")  //1  
	public UserModel getUser(@RequestParam(value="username", defaultValue="") String username) {  
		//TODO 去数据库根据用户名查找用户对象  
		UserModel user = new UserModel();  
		user.setRealname("zhang");  
		return user;
	}

	@RequestMapping(value="/model1") //2
	public String test1(@ModelAttribute("user") UserModel user, Model model)

此处我们看到1和2处有同名的命令对象，那Spring Web MVC内部如何处理的呢？

	1 首先执行@ModelAttribute注解的方法，准备视图展示时所需要的模型数据；@ModelAttribute注解方法形式参数规则和@RequestMapping规则一样，如可以有@RequestParam等；
	2 执行@RequestMapping注解方法，进行模型绑定时首先查找模型数据中是否含有同名对象，如果有直接使用，如果没有通过反射创建一个，因此2处的user将使用1处返回的命令对象。即2处的user等于1处的user。
 
####暴露@RequestMapping方法返回值为模型数据

	public @ModelAttribute("user2") UserModel test3(@ModelAttribute("user2") UserModel user)  

大家可以看到返回值类型是命令对象类型，而且通过@ModelAttribute("user2")注解，此时会暴露返回值到模型数据（名字为user2）中供视图展示使用。那哪个视图应该展示呢？此时Spring Web MVC会根据RequestToViewNameTranslator进行逻辑视图名的翻译。
 
此时又有问题了，@RequestMapping注解方法的入参user暴露到模型数据中的名字也是user2，其实我们能猜到：@ModelAttribute注解的返回值会覆盖@RequestMapping注解方法中的@ModelAttribute注解的同名命令对象。
 
####匿名绑定命令参数

	public String test4(@ModelAttribute UserModel user, Model model)  
	或  
	public String test5(UserModel user, Model model)

此时我们没有为命令对象提供暴露到模型数据中的名字，此时的名字是什么呢？Spring Web MVC自动将简单类名（首字母小写）作为名字暴露，如“cn.javass.chapter6.model.UserModel”暴露的名字为“userModel”。

	public @ModelAttribute List<String> test6()  
	或  
	public @ModelAttribute List<UserModel> test7()   

对于集合类型（Collection接口的实现者们，包括数组），生成的模型对象属性名为“简单类名（首字母小写）”+“List”，如List<String>生成的模型对象属性名为“stringList”，List<UserModel>生成的模型对象属性名为“userModelList”。
 
其他情况一律都是使用简单类名（首字母小写）作为模型对象属性名，如Map<String, UserModel>类型的模型对象属性名为“map”。

###PathVariable

@PathVariable用于将请求URL中的模板变量映射到功能处理方法的参数上。

	@RequestMapping(value="/users/{userId}/topics/{topicId}")
	public String test(
	       @PathVariable(value="userId") int userId,
	       @PathVariable(value="topicId") int topicId)

 如请求的URL为“控制器URL/users/123/topics/456”，则自动将URL中模板变量{userId}和{topicId}绑定到通过@PathVariable注解的同名参数上，即入参后userId=123、topicId=456。

###RequestBody

@RequestBody的执行过程： 

	1 该注解用于读取Request请求的body部分数据，使用系统默认配置的HttpMessageConverter进行解析，然后把相应的数据绑定到要返回的对象上；

	2 再把HttpMessageConverter返回的对象数据绑定到 controller中方法的参数上。

适用的HTTP方法：

	1 GET、POST方法， 根据请求头的Content-Type值来判断。

		application/x-www-form-urlencoded， 可选（即非必须，因为这种情况的数据@RequestParam, @ModelAttribute也可以处理，当然@RequestBody也能处理）；
		multipart/form-data, 不能处理（即使用@RequestBody不能处理这种格式的数据）；
		其他格式， 必须（其他格式包括application/json, application/xml等。这些格式的数据，必须使用@RequestBody来处理）；

	2 PUT方法， 根据请求头的Content-Type值来判断:

		application/x-www-form-urlencoded， 必须；
		multipart/form-data, 不能处理；
		其他格式， 必须；
		说明：request的body部分的数据编码格式由header部分的Content-Type指定；

###RequestHeader

@RequestHeader用于将请求的头信息区数据映射到功能处理方法的参数上。

	@RequestMapping(value="/header")  
	public String test(  
	       @RequestHeader("User-Agent") String userAgent,  
	       @RequestHeader(value="Accept") String[] accepts)  
          
如上配置将自动将请求头“User-Agent”值绑到userAgent参数上，并将“Accept”请求头值绑到accepts参数上。

###RequestMapping

RequestMapping是一个用来处理请求地址映射的注解，可用于类或方法上。用于类上，表示类中的所有响应请求的方法都是以该地址作为父路径。

RequestMapping注解有六个属性，下面我们把它分成三类进行说明。

####value和method

value：指定请求的实际地址，指定的地址可以是URI Template 模式（后面将会说明）；
method：指定请求的method类型， GET、POST、PUT、DELETE等；

	@Controller
	@RequestMapping("/appointments")  
	public class AppointmentsController {  

		private AppointmentBook appointmentBook;  

		@Autowired  
		public AppointmentsController(AppointmentBook appointmentBook) {  
			this.appointmentBook = appointmentBook;  
		}  

		@RequestMapping(method = RequestMethod.GET)  
		public Map<String, Appointment> get() {  
			return appointmentBook.getAppointmentsForToday();  
		}  

		@RequestMapping(value="/{day}", method = RequestMethod.GET)  
		public Map<String, Appointment> getForDay(@PathVariable @DateTimeFormat(iso=ISO.DATE) Date day, Model model) {  
			return appointmentBook.getAppointmentsForDay(day);  
		}  

		@RequestMapping(value="/new", method = RequestMethod.GET)  
		public AppointmentForm getNewForm() {  
			return new AppointmentForm();  
		}  

		@RequestMapping(method = RequestMethod.POST)  
		public String add(@Valid AppointmentForm appointment, BindingResult result) {  
			if (result.hasErrors()) {  
				return "appointments/new";  
			}  
			appointmentBook.addAppointment(appointment);  
			return "redirect:/appointments";  
		}  
	}

value的uri值为以下三类：

	1 可以指定为普通的具体值；

	2 可以指定为含有某变量的一类值(URI Template Patterns with Path Variables)；

	3 可以指定为含正则表达式的一类值( URI Template Patterns with Regular Expressions);

	@RequestMapping(value="/owners/{ownerId}", method=RequestMethod.GET)  
	public String findOwner(@PathVariable String ownerId, Model model) {
		Owner owner = ownerService.findOwner(ownerId);    
		model.addAttribute("owner", owner);    
		return "displayOwner";   
	}  

	@RequestMapping("/spring-web/{symbolicName:[a-z-]+}-{version:\d\.\d\.\d}.{extension:\.[a-z]}")  
	public void handle(@PathVariable String version, @PathVariable String extension) {      
			// ...  
		}  
	}

####consumes和produces

consumes：指定处理请求的提交内容类型（Content-Type），例如application/json, text/html;
produces：指定返回的内容类型，仅当request请求头中的(Accept)类型中包含该指定类型才返回；

	@Controller
	@RequestMapping(value = "/pets", method = RequestMethod.POST, consumes="application/json")  
	public void addPet(@RequestBody Pet pet, Model model) {      
		// implementation omitted  
	}  
	方法仅处理请求头中Content-Type为“application/json”类型的请求。


	@Controller  
	@RequestMapping(value = "/pets/{petId}", method = RequestMethod.GET, produces="application/json")  
	@ResponseBody  
	public Pet getPet(@PathVariable String petId, Model model) {      
		// implementation omitted  
	} 
	方法仅处理request请求中Accept头中包含了"application/json"的请求，同时暗示了返回的内容类型为application/json;

####params和headers

params：指定request中必须包含某些参数值是，才让该方法处理。
headers：指定request中必须包含某些指定的header值，才能让该方法处理请求。

	@Controller  
	@RequestMapping("/owners/{ownerId}")  
	public class RelativePathUriTemplateController {  

		@RequestMapping(value = "/pets/{petId}", method = RequestMethod.GET, params="myParam=myValue")  
		public void findPet(@PathVariable String ownerId, @PathVariable String petId, Model model) {      
			// implementation omitted  
		}  
	}
	仅处理请求中包含了名为“myParam”，值为“myValue”的请求；

	@Controller  
	@RequestMapping("/owners/{ownerId}")  
	public class RelativePathUriTemplateController {  

		@RequestMapping(value = "/pets", method = RequestMethod.GET, headers="Referer=http://www.ifeng.com/")  
		public void findPet(@PathVariable String ownerId, @PathVariable String petId, Model model) {      
			// implementation omitted  
		}  
	}  
	仅处理request的header中包含了指定“Refer”请求头和对应值为“http://www.ifeng.com/”的请求；


###RequestParam

@RequestParam用于将请求参数区数据映射到功能处理方法的参数上。

	public String requestparam(@RequestParam String username)  

请求中包含username参数（如/requestparam1?username=zhang），则自动传入。

@RequestParam注解主要以下三个参数：

	value：参数名字，即入参的请求参数名字，如username表示请求的参数区中的名字为username的参数的值将传入；
	required：是否必须，默认是true，表示请求中一定要有相应的参数，否则将报404错误码；
	defaultValue：默认值，表示如果请求中没有同名参数时的默认值，默认值可以是SpEL表达式，如“#{systemProperties['java.vm.version']}”。 
 
请求中有多个同名的参数的处理方法。如给用户授权时，可能授予多个权限，首先看下如下代码：

	public String requestparam7(@RequestParam(value="role") String roleList)

如果请求参数类似于url?role=admin&rule=user，则实际roleList参数入参的数据为“admin,user”，即多个数据之间使用“，”分割；我们应该使用如下方式来接收多个请求参数：

	public String requestparam7(@RequestParam(value="role") String[] roleList)     
	或
	public String requestparam8(@RequestParam(value="list") List<String> list)      

###RequestPart

@RequestPart用于将”multipart/form-data“请求和方法参数绑定。

支持的方法参数类型包括：MultipartFile、其他根据”Content-Type“请求头确定HttpMessageConverter，然后传递进来的参数类型。与其有相似功能的@RequestBody只能解决非multipart类型的请求。

与@RequestParam的区别是：
	
	1 当方法参数不是String时，@RequestParam依赖于已经注册的Converter/PorpertyEditor进行转换；而@RequestPart依赖HttpMessageConverters(会将请求头中"Content-Type"列入考虑因素)；
	2 @RequestParam一般用于name-value格式；而@RequestPart一般用于比较复杂的内容（如JSON、XML)。

###ResponseBody

该注解用于将Controller的方法返回的对象，通过适当的HttpMessageConverter转换为指定格式后，写入到Response对象的body数据区。

当返回的数据不是html标签的页面，而是其他某种格式的数据时（如json、xml等）使用。

###ResponseStatus

标注方法或者异常类应该返回的HTTP Status Code和原因。当handler方法被触发时，Status Code会被应用于HTTP响应，并覆盖被其它方式（比如ResponseEntity或者"redirect:"）设置的状态信息。

包含的参数：

	code  响应状态码
	reason  原因描述
	value  状态码的别名

###RestController

@RestController继承自@Controller。当实现RESTful web服务时，一般都需要@ResponseBody，为了简化，Spring 4.0提供了@Controller的特定版本。下面是@RestController的实现。

	@Target(value=TYPE)  
	@Retention(value=RUNTIME)  
	@Documented  
	@Controller  
	@ResponseBody  
	public @interface RestController  

@RestController等价于@Controller和@ResponseBody两个注解。

###SessionAttributes

@SessionAttributes能够绑定命令对象到session。

有时候我们需要在多次请求之间保持数据，一般情况需要我们明确的调用HttpSession的API来存取会话数据，如多步骤提交的表单。Spring Web MVC提供了@SessionAttributes进行请求间透明的存取会话数据。

	//1、在控制器类头上添加@SessionAttributes注解  
	@SessionAttributes(value = {"user"})    //①  
	public class SessionAttributeController   
	  
	//2、@ModelAttribute注解的方法进行表单引用对象的创建  
	@ModelAttribute("user")    //②  
	public UserModel initUser()   
	  
	//3、@RequestMapping注解方法的@ModelAttribute注解的参数进行命令对象的绑定  
	@RequestMapping("/session1")   //③  
	public String session1(@ModelAttribute("user") UserModel user)  
	  
	//4、通过SessionStatus的setComplete()方法清除@SessionAttributes指定的会话数据  
	@RequestMapping("/session2")   //③  
	public String session(@ModelAttribute("user") UserModel user, SessionStatus status) {  
	    if(true) { //④  
	        status.setComplete();  
	    }  
	    return "success";  
	}

@SessionAttributes(value = {"user"})含义：

	@SessionAttributes(value = {"user"}) 标识将模型数据中的名字为“user” 的对象存储到会话中（默认HttpSession），此处value指定将模型数据中的哪些数据（名字进行匹配）存储到会话中，此外还有一个types属性表示模型数据中的哪些类型的对象存储到会话范围内，如果同时指定value和types属性则那些名字和类型都匹配的对象才能存储到会话范围内。
 
包含@SessionAttributes的执行流程如下所示：

	① 首先根据@SessionAttributes注解信息查找会话内的对象放入到模型数据中；
	
	② 执行@ModelAttribute注解的方法：如果模型数据中包含同名的数据，则不执行@ModelAttribute注解方法进行准备表单引用数据，而是使用①步骤中的会话数据；如果模型数据中不包含同名的数据，执行@ModelAttribute注解的方法并将返回值添加到模型数据中；
	
	③ 执行@RequestMapping方法，绑定@ModelAttribute注解的参数：查找模型数据中是否有@ModelAttribute注解的同名对象，如果有直接使用，否则通过反射创建一个；并将请求参数绑定到该命令对象；
	此处需要注意：如果使用@SessionAttributes注解控制器类之后，③步骤一定是从模型对象中取得同名的命令对象，如果模型数据中不存在将抛出HttpSessionRequiredException Expected session attribute ‘user’(Spring3.1)或HttpSessionRequiredException Session attribute ‘user’ required - not found in session(Spring3.0)异常。
	
	④ 如果会话可以销毁了，如多步骤提交表单的最后一步，此时可以调用SessionStatus对象的setComplete()标识当前会话的@SessionAttributes指定的数据可以清理了，此时当@RequestMapping功能处理方法执行完毕会进行清理会话数据。
