---
layout: post
title: "hashCode()和equals()的用法"
description: "hashCode()和equals()的用法"
category: java
tags: [java]
---

##使用hashCode()和equals()

hashCode()和equals()定义在Object类中，这个类是所有java类的基类，所以所有的java类都继承这两个方法。

hashCode()方法被用来获取给定对象的唯一整数。这个整数被用来确定对象被存储在HashTable类似的结构中的位置。默认的，Object类的hashCode()方法返回这个对象存储的内存地址的编号。

##重写默认的实现

如果你不重写这两个方法，将几乎不遇到任何问题，但是有的时候程序要求我们必须改变一些对象的默认实现。

来看看这个例子，让我们创建一个简单的类Employee

    public class Employee
    {
        private Integer id;
        private String firstname;
        private String lastName;
        private String department;

        public Integer getId() {
            return id;
        }
        
        public void setId(Integer id) {
            this.id = id;
        }
        
        public String getFirstname() {
            return firstname;
        }
        
        public void setFirstname(String firstname) {
            this.firstname = firstname;
        }
        
        public String getLastName() {
            return lastName;
        }
        
        public void setLastName(String lastName) {
            this.lastName = lastName;
        }
        
        public String getDepartment() {
            return department;
        }
        
        public void setDepartment(String department) {
            this.department = department;
        }
    }

上面的Employee类只是有一些非常基础的属性和getter、setter.现在来考虑一个你需要比较两个employee的情形。

    public class EqualsTest {
        public static void main(String[] args) {
            Employee e1 = new Employee();
            Employee e2 = new Employee();
     
            e1.setId(100);
            e2.setId(100);
            //Prints false in console
            System.out.println(e1.equals(e2));
        }
    }

毫无疑问，上面的程序将输出false，但是，事实上上面两个对象代表的是通过一个employee。真正的商业逻辑希望我们返回true。 
为了达到这个目的，我们需要重写equals方法。 

    public boolean equals(Object o) {
            if(o == null)
            {
                return false;
            }
            if (o == this)
            {
               return true;
            }
            if (getClass() != o.getClass())
            {
                return false;
            }
            Employee e = (Employee) o;
            return (this.getId() == e.getId());
    }

在上面的类中添加这个方法，EauqlsTest将会输出true。
这样就可以了吗？没有，让我们换一种测试方法来看看。 

    import java.util.HashSet;
    import java.util.Set;
     
    public class EqualsTest
    {
        public static void main(String[] args)
        {
            Employee e1 = new Employee();
            Employee e2 = new Employee();
     
            e1.setId(100);
            e2.setId(100);
     
            //Prints 'true'
            System.out.println(e1.equals(e2));
     
            Set<Employee> employees = new HashSet<Employee>();
            employees.add(e1);
            employees.add(e2);
            //Prints two objects
            System.out.println(employees);
        }
    }

上面的程序输出的结果是两个。如果两个employee对象equals返回true，Set中应该只存储一个对象才对，问题在哪里呢？
我们忘掉了第二个重要的方法hashCode()。就像JDK的Javadoc中所说的一样，如果重写equals()方法必须要重写hashCode()方法。我们加上下面这个方法，程序将执行正确。

    @Override
    public int hashCode()
    {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + getId();
        return result;
    }

##使用Apache Commons Lang包重写hashCode()和equals()方法

Apache Commons 包提供了两个非常优秀的类来生成hashCode()和equals()方法。看下面的程序。 

    import org.apache.commons.lang3.builder.EqualsBuilder;
    import org.apache.commons.lang3.builder.HashCodeBuilder;
    public class Employee
    {
        private Integer id;
        private String firstname;
        private String lastName;
        private String department;
        
        public Integer getId() {
            return id;
        }
        
        public void setId(Integer id) {
            this.id = id;
        }

        public String getFirstname() {
            return firstname;
        }

        public void setFirstname(String firstname) {
            this.firstname = firstname;
        }

        public String getLastName() {
            return lastName;
        }

        public void setLastName(String lastName) {
            this.lastName = lastName;
        }

        public String getDepartment() {
            return department;
        }

        public void setDepartment(String department) {
            this.department = department;
        }

        @Override
        public int hashCode()
        {
            final int PRIME = 31;
            return new HashCodeBuilder(getId() % 2 == 0 ? getId() + 1 : getId(), PRIME).toHashCode();
        }

        @Override
        public boolean equals(Object o) {
            if (o == null)
               return false;
            if (o == this)
               return true;
            if (o.getClass() != getClass())
               return false;
            Employee e = (Employee) o;
               return new EqualsBuilder().
                      append(getId(), e.getId()).
                      isEquals();
        }
    }

如果你使用Intellij IDEA或者其他的IDE，IDE也可能会提供生成良好的hashCode()方法和equals()方法。 


##需要注意记住的事情

* 尽量保证使用对象的同一个属性来生成hashCode()和equals()两个方法。
* 任何时候只要a.equals(b)，那么a.hashCode()必须和b.hashCode()相等。
* hashCode和equals两者必须同时重写。
* 如果你使用ORM处理一些对象的话，你要确保在hashCode()和equals()对象中使用getter和setter而不是直接引用成员变量。因为在ORM中有的时候成员变量会被延时加载，这些变量只有当getter方法被调用的时候才真正可用。
