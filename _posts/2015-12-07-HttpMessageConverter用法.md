---
layout: post
title: "HttpMessageConverter用法"
description: "HttpMessageConverter用法"
category: spring
tags: [spring]
---

###HttpMessageConverter接口定义

     * Strategy interface that specifies a converter that can convert from and to HTTP requests and responses. 
     * 
     * @author Arjen Poutsma 
     * @author Juergen Hoeller 
     * @since 3.0
     */  
    public interface HttpMessageConverter<T> {  
      
        /** 
         * Indicates whether the given class can be read by this converter. 
         * @param clazz the class to test for readability 
         * @param mediaType the media type to read, can be {@code null} if not specified. 
         * Typically the value of a {@code Content-Type} header. 
         * @return {@code true} if readable; {@code false} otherwise 
         */  
        boolean canRead(Class<?> clazz, MediaType mediaType);  
      
        /** 
         * Indicates whether the given class can be written by this converter. 
         * @param clazz the class to test for writability 
         * @param mediaType the media type to write, can be {@code null} if not specified. 
         * Typically the value of an {@code Accept} header. 
         * @return {@code true} if writable; {@code false} otherwise 
         */  
        boolean canWrite(Class<?> clazz, MediaType mediaType);  
      
        /** 
         * Return the list of {@link MediaType} objects supported by this converter. 
         * @return the list of supported media types 
         */  
        List<MediaType> getSupportedMediaTypes();  
      
        /** 
         * Read an object of the given type form the given input message, and returns it. 
         * @param clazz the type of object to return. This type must have previously been passed to the 
         * {@link #canRead canRead} method of this interface, which must have returned {@code true}. 
         * @param inputMessage the HTTP input message to read from 
         * @return the converted object 
         * @throws IOException in case of I/O errors 
         * @throws HttpMessageNotReadableException in case of conversion errors 
         */  
        T read(Class<? extends T> clazz, HttpInputMessage inputMessage)  
                throws IOException, HttpMessageNotReadableException;  
      
        /** 
         * Write an given object to the given output message. 
         * @param t the object to write to the output message. The type of this object must have previously been 
         * passed to the {@link #canWrite canWrite} method of this interface, which must have returned {@code true}. 
         * @param contentType the content type to use when writing. May be {@code null} to indicate that the 
         * default content type of the converter must be used. If not {@code null}, this media type must have 
         * previously been passed to the {@link #canWrite canWrite} method of this interface, which must have 
         * returned {@code true}. 
         * @param outputMessage the message to write to 
         * @throws IOException in case of I/O errors 
         * @throws HttpMessageNotWritableException in case of conversion errors 
         */  
        void write(T t, MediaType contentType, HttpOutputMessage outputMessage)  
                throws IOException, HttpMessageNotWritableException;  
      
    }  

该接口定义了四个方法，分别是读取数据时的 canRead(), read() 和 写入数据时的canWrite(), write()方法。

###常用的HttpMessageConverter

在使用 <mvc:annotation-driven />标签配置时，默认配置了RequestMappingHandlerAdapter（注意是RequestMappingHandlerAdapter不是AnnotationMethodHandlerAdapter），并为他配置了一下默认的HttpMessageConverter：

    ByteArrayHttpMessageConverter converts byte arrays.  
      
    StringHttpMessageConverter converts strings.  
      
    ResourceHttpMessageConverter converts to/from org.springframework.core.io.Resource for all media types.  
      
    SourceHttpMessageConverter converts to/from a javax.xml.transform.Source.  
      
    FormHttpMessageConverter converts form data to/from a MultiValueMap<String, String>.  
      
    Jaxb2RootElementHttpMessageConverter converts Java objects to/from XML — added if JAXB2 is present on the classpath.  
      
    MappingJacksonHttpMessageConverter converts to/from JSON — added if Jackson is present on the classpath.  
      
    AtomFeedHttpMessageConverter converts Atom feeds — added if Rome is present on the classpath.  
      
    RssChannelHttpMessageConverter converts RSS feeds — added if Rome is present on the classpath.  

    ByteArrayHttpMessageConverter: 负责读取二进制格式的数据和写出二进制格式的数据；

    StringHttpMessageConverter：负责读取字符串格式的数据和写出二进制格式的数据；

    ResourceHttpMessageConverter：负责读取资源文件和写出资源文件数据； 

    FormHttpMessageConverter：负责读取form提交的数据（能读取的数据格式为 application/x-www-form-urlencoded，不能读取multipart/form-data格式数据）；负责写入application/x-www-from-urlencoded和multipart/form-data格式的数据；

    MappingJacksonHttpMessageConverter:  负责读取和写入json格式的数据；

    SouceHttpMessageConverter：负责读取和写入 xml 中javax.xml.transform.Source定义的数据；

    Jaxb2RootElementHttpMessageConverter：负责读取和写入xml 标签格式的数据；

    AtomFeedHttpMessageConverter：负责读取和写入Atom格式的数据；

    RssChannelHttpMessageConverter：负责读取和写入RSS格式的数据；

当使用@RequestBody和@ResponseBody注解时，RequestMappingHandlerAdapter就使用它们来进行读取或者写入相应格式的数据。

###HttpMessageConverter匹配过程：

####@RequestBody注解时： 根据Request对象header部分的Content-Type类型，逐一匹配合适的HttpMessageConverter来读取数据。

spring 3.1源代码如下：

    private Object readWithMessageConverters(MethodParameter methodParam, HttpInputMessage inputMessage, Class paramType) throws Exception {  

        MediaType contentType = inputMessage.getHeaders().getContentType();  
        if (contentType == null) {  
            StringBuilder builder = new StringBuilder(ClassUtils.getShortName(methodParam.getParameterType()));  
            String paramName = methodParam.getParameterName();  
            if (paramName != null) {  
                builder.append(' ');  
                builder.append(paramName);  
            }  
            throw new HttpMediaTypeNotSupportedException("Cannot extract parameter (" + builder.toString() + "): no Content-Type found");  
        }  

        List<MediaType> allSupportedMediaTypes = new ArrayList<MediaType>();  
        if (this.messageConverters != null) {  
            for (HttpMessageConverter<?> messageConverter : this.messageConverters) {  
                allSupportedMediaTypes.addAll(messageConverter.getSupportedMediaTypes());  
                if (messageConverter.canRead(paramType, contentType)) {  
                    if (logger.isDebugEnabled()) {  
                        logger.debug("Reading [" + paramType.getName() + "] as \"" + contentType  + "\" using [" + messageConverter + "]");  
                    }  
                    return messageConverter.read(paramType, inputMessage);  
                }  
            }  
        }  
        throw new HttpMediaTypeNotSupportedException(contentType, allSupportedMediaTypes);  
    }

####@ResponseBody注解时：根据Request对象header部分的Accept属性（逗号分隔），逐一按accept中的类型，去遍历找到能处理的HttpMessageConverter。

spring 3.1 源代码如下：

    private void writeWithMessageConverters(Object returnValue,  HttpInputMessage inputMessage, HttpOutputMessage outputMessage)  
                    throws IOException, HttpMediaTypeNotAcceptableException {  
        List<MediaType> acceptedMediaTypes = inputMessage.getHeaders().getAccept();  
        if (acceptedMediaTypes.isEmpty()) {  
            acceptedMediaTypes = Collections.singletonList(MediaType.ALL);  
        }  
        MediaType.sortByQualityValue(acceptedMediaTypes);  
        Class<?> returnValueType = returnValue.getClass();  
        List<MediaType> allSupportedMediaTypes = new ArrayList<MediaType>();  
        if (getMessageConverters() != null) {  
            for (MediaType acceptedMediaType : acceptedMediaTypes) {  
                for (HttpMessageConverter messageConverter : getMessageConverters()) {  
                    if (messageConverter.canWrite(returnValueType, acceptedMediaType)) {  
                        messageConverter.write(returnValue, acceptedMediaType, outputMessage);  
                        if (logger.isDebugEnabled()) {  
                            MediaType contentType = outputMessage.getHeaders().getContentType();  
                            if (contentType == null) {  
                                contentType = acceptedMediaType;  
                            }  
                            logger.debug("Written [" + returnValue + "] as \"" + contentType +  
                                    "\" using [" + messageConverter + "]");  
                        }  
                        this.responseArgumentUsed = true;  
                        return;  
                    }  
                }  
            }  
            for (HttpMessageConverter messageConverter : messageConverters) {  
                allSupportedMediaTypes.addAll(messageConverter.getSupportedMediaTypes());  
            }  
        }  
        throw new HttpMediaTypeNotAcceptableException(allSupportedMediaTypes);  
    }
