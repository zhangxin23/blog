---
layout: page
title: 
tagline: 
---
{% include zhangxin/setup %}

<p>
&nbsp; Web 后台 Java C C++ Linux MySQL Redis MongoDB ...
</p>
<hr/>
{% for post in site.posts %}
<div class="post">
  <div class="top">
     <time datetime="{{ post.date | xmlschema }}">{{ post.date | date: "%d %b" }}</time>
	 <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
  </div>
  <div class="content">
      {{ post.content | strip_html | truncatewords: 35}}
	  <p><a href="{{ post.url }}">Read more ...</a></p>
  </div>
  <div class="bottom">
      <span>{{post.date | date: "%A %D"}}</span>
  </div>
</div>
{% endfor %}

