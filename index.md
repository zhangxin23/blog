---
layout: page
title: 
tagline: 
---
{% include zhangxin/setup %}

<p>
    <h4>Web, Java, C, C++, Linux, MySQL, Redis, MongoDB ...</h4>
</p>

<hr/>

{% for post in site.posts %}
<div class="post">
    <div class="top">
            {{post.date | date: "%A %D"}}
            <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
    </div>
</div>
{% endfor %}
