---
layout: post
title: "java functional syntax overview"
description: "java functional syntax overview"
category: functional
tags: [functional]
---

###Defining a Functional Interface

	@FunctionalInterface
	public interface TailCall<T> {
		TailCall<T> apply();
		default boolean isComplete() { return false; }
		//...
	}

A functional interface must have one abstract—unimplemented—method. It may have zero or more default or implemented methods. It may also have static methods.

###Creating No-Parameter Lambda Expressions

	lazyEvaluator(() -> evaluate(1), () -> evaluate(2));

The parentheses () around the empty parameters list are required if the lambda expression takes no parameters. The -> separates the parameters from the body of a lambda expression.

###Creating a Single-Parameter Lambda Expression

	friends.forEach((final String name) -> System.out.println(name));

The Java compiler can infer the type of lambda expression based on the context. In some situations where the context is not adequate for it to infer or we want better clarity, we can specify the type in front of the parameter names.

###Inferring a Lambda Expression’s Parameter Type

	friends.forEach((name) -> System.out.println(name));

The Java compiler will try to infer the types for parameters if we don’t provide them. Using inferred types is less noisy and requires less effort, but if we specify the type for one parameter, we have to specify it for all parameters in a lambda expression.

###Dropping Parentheses for a Single-Parameter Inferred Type

	friends.forEach(name -> System.out.println(name));

The parentheses () around the parameter is optional if the lambda expression takes only one parameter and its type is inferred. We could write name -> ... or (name) -> ...; lean toward the first since it’s less noisy.

###Creating a Multi-Parameter Lambda Expression

	friends.stream()
	.reduce((name1, name2) ->
	name1.length() >= name2.length() ? name1 : name2);

The parentheses () around the parameter list are required if the lambda expression takes multiple parameters or no parameters.

###Calling a Method with Mixed Parameters

	friends.stream()
	.reduce("Steve", (name1, name2) ->
	name1.length() >= name2.length() ? name1 : name2);

Methods can have a mixture of regular classes, primitive types, and functional interfaces as parameters. Any parameter of a method may be a functional interface, and we can send a lambda expression or a method reference as an argument in its place.

###Storing a Lambda Expression

	final Predicate<String> startsWithN = name -> name.startsWith("N");

To aid reuse and to avoid duplication, we often want to store lambda expressions in variables.

###Creating a Multiline Lambda Expression

	FileWriterEAM.use("eam2.txt", writerEAM -> {
		writerEAM.writeStuff("how");
		writerEAM.writeStuff("sweet");
	});

We should keep the lambda expressions short, but it’s easy to sneak in a few lines of code. But we have to pay penance by using curly braces {}, and the return keyword is required if the lambda expression is expected to return a value.

###Returning a Lambda Expression

	public static Predicate<String> checkIfStartsWith(final String letter) {
		return name -> name.startsWith(letter);
	}

If a method’s return type is a functional interface, we can return a lambda expression from within its implementation.

###Returning a Lambda Expression from a Lambda Expression

	final Function<String, Predicate<String>> startsWithLetter =
	letter -> name -> name.startsWith(letter);

We can build lambda expressions that themselves return lambda expressions. The implementation of the Function interface here takes in a String letter and returns a lambda expression that conforms to the Predicate interface.

###Lexical Scoping in Closures

	public static Predicate<String> checkIfStartsWith(final String letter) {
		return name -> name.startsWith(letter);
	}

From within a lambda expression we can access variables that are in the enclosing method’s scope. For example, the variable letter in the checkIfStartsWith() is accessed within the lambda expression. Lambda expressions that bind to variables in enclosing scopes are called closures.

###Passing a Method Reference of an Instance Method

	friends.stream().map(String::toUpperCase);

We can replace a lambda expression with a method reference if it directly routes the parameter as a target to a simple method call. The preceding sample code given is equivalent to this:

	friends.stream().map(name -> name.toUpperCase());

###Passing a Method Reference to a static Method

	str.chars().filter(Character::isDigit);

We can replace a lambda expression with a method reference if it directly routes the parameter as an argument to a static method. The preceding sample code is equivalent to this:

	str.chars().filter(ch -> Character.isDigit(ch));

###Passing a Method Reference to a Method on Another Instance

	str.chars().forEach(System.out::println);

We can replace a lambda expression with a method reference if it directly routes the parameter as an argument to a method on another instance; for example, println() on System.out. The preceding sample code is equivalent to this:

	str.chars().forEach(ch -> System.out.println(ch));

###Passing a Reference of a Method That Takes Parameters

	people.stream()
	.sorted(Person::ageDifference)

We can replace a lambda expression with a method reference if it directly routes the first parameter as a target of a method call, and the remaining parameters as this method’s arguments. The preceding sample code is equivalent to this:

	people.stream()
	.sorted((person1, person2) -> person1.ageDifference(person2))

###Using a Constructor Reference

	Supplier<Heavy> supplier = Heavy::new;

Instead of invoking a constructor, we can ask the Java compiler to create the calls to the appropriate constructor from the concise constructor-reference syntax. These work much like method references, except they refer to a constructor and they result in object instantiation. The preceding sample code is equivalent to this:

	Supplier<Heavy> supplier = () -> new Heavy();

###Function Composition

	symbols
	.map(StockUtil::getPrice)
	.filter(StockUtil.isPriceLessThan(500))
	.reduce(StockUtil::pickHigh)
	.get();

We can compose functions to transform objects through a series of operations like in this example. In the functional style of programming, function composition or chaining is a very powerful construct to implement associative operations.