---
layout: post
title: "Starter Set of Functional Interfaces"
description: "Starter Set of Functional Interfaces"
category: functional
tags: [functional]
---

Java Development Kit 8 has a number of functional interfaces. Here we review the starter set—the interfaces we frequently encounter and need to first get familiar with. All the interfaces we see here are part of the java.util.function package.

###Consumer&lt;T&gt;

####Description

Represents an operation that will accept an input and returns nothing. For this to be useful, it will have to cause side effects.

####Abstract method

accept()

####Default method(s)

andThen()

####Popular usage

As a parameter to the forEach() method

####Primitive specializations

IntConsumer, LongConsumer, DoubleConsumer, …

###Supplier<T>

####Description

A factory that’s expected to return either a new instance or a precreated instance

####Abstract method

get()

####Default method(s)

—

####Popular usage

To create lazy infinite Streams and as the parameter to the Optional class’s orElseGet() method

####Primitive specializations

IntSupplier, LongSupplier, DoubleSupplier, …

###Predicate<T>

####Description

Useful for checking if an input argument satisfies some condition

####Abstract method

test()

####Default method(s)

and(), negate(), and or()

####Popular usage

As a parameter to Stream’s methods, like filter() and anyMatch()

####Primitive specializations

IntPredicate, LongPredicate, DoublePredicate, …

###Function<T, R>

####Description

A transformational interface that represents an operation intended to take in an argument and return an appropriate result

####Abstract method

apply()

####Default method(s)

andThen(), compose()

####Popular usage

As a parameter to Stream’s map() method

####Primitive specializations

IntFunction, LongFunction, DoubleFunction, IntToDoubleFunction, DoubleToIntFunction, …